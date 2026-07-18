import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:bits_n_bytes_ui/models/api/user.dart';
import 'package:bits_n_bytes_ui/models/serial/nfc_scan.dart';
import 'package:bits_n_bytes_ui/repositories/user.dart';
import 'package:bits_n_bytes_ui/services/serial_service.dart';
import 'package:bits_n_bytes_ui/services/log_service.dart';

enum LoginStatus { idle, loading, success, notFound, error }

/// Owns the NFC-tap → login flow for the welcome screen. No widgets, no
/// BuildContext, no Navigator — the View watches [status]/[user] and navigates
/// on success.
class WelcomeViewModel extends ChangeNotifier {
  WelcomeViewModel({SerialService? serial, UserRepository? users})
    : _serial = serial ?? SerialService(),
      _users = users ?? UserRepository() {
    // Subscribe to the typed NFC stream exactly ONCE, then arm the reader.
    // rearm() (refresh button / not-found) only re-sends the init command — it
    // never re-subscribes, so one tap can't fire N stacked handlers => N logins.
    _nfcSub = _serial.nfcStream.listen(_onNfc);
    rearm();
  }

  final SerialService _serial;
  final UserRepository _users;
  late final StreamSubscription<NfcScan> _nfcSub;

  LoginStatus _status = LoginStatus.idle;
  LoginStatus get status => _status;

  User? _user;
  User? get user => _user;

  /// Last uuid we acted on — de-dupes a held card and the not-found re-arm loop
  /// so the same card can't fire login over and over.
  int? _lastUuid;

  /// Incremented on every login attempt — lets a test prove that one NFC packet
  /// triggers exactly one login (i.e. the listener isn't stacked).
  @visibleForTesting
  int loginAttempts = 0;

  void _onNfc(NfcScan scan) {
    // Guard the bad-read -> 404 -> rearm -> bad-read storm: skip while a login
    // is already running, and ignore the same card repeating. Only a DIFFERENT
    // card (or the refresh button via refresh()) re-triggers login.
    if (_status == LoginStatus.loading || scan.uuid == _lastUuid) return;
    _lastUuid = scan.uuid;
    LogService.logEvent('NFC decoded uuid: ${scan.uuid}');
    login(scan.uuid);
  }

  /// Manual re-arm (refresh button): clears the de-dupe so the same card can be
  /// retried, then re-arms the reader.
  void refresh() {
    _lastUuid = null;
    rearm();
  }

  /// Gap before the re-arm so the FF doesn't collide with the ACK.
  static const Duration _replyGap = Duration(seconds: 1);

  static final Uint8List _armPacket = Uint8List.fromList([
    0xFF,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
  ]);
  Uint8List _ackPacket(bool valid) =>
      Uint8List.fromList([valid ? 0xF1 : 0xF0, 0, 0, 0, 0, 0, 0, 0]);

  /// (Re-)arm the NFC reader by sending the sync command. Fires immediately so
  /// the reader is armed as soon as the screen mounts / refresh is tapped. The
  /// post-scan reply is scheduled in [login] so the ACK + re-arm stay in sync.
  void rearm() {
    LogService.logEvent('Sending NFC sync command...');
    _serial.sendBinaryTo(SerialService.portNFC, _armPacket);
  }

  Future<void> login(int uuid) async {
    loginAttempts++;
    _status = LoginStatus.loading;
    notifyListeners();

    var isValidUser = false;
    try {
      final user = await _users.findByNfcUuid(uuid);
      if (user != null) {
        _user = user;
        isValidUser = true;
        _status = LoginStatus.success;
        LogService.logEvent('Logged in: ${user.name} (${user.id})');
      } else {
        LogService.logEvent('User not found.');
        _status = LoginStatus.notFound;
      }
    } catch (e) {
      LogService.logEvent('Login error: $e');
      _status = LoginStatus.error;
    }
    // ACK immediately (F1 valid / F0 invalid): the MCU samples its RX right
    // after sending the UID, so the result byte has to land in that window.
    _serial.sendBinaryTo(SerialService.portNFC, _ackPacket(isValidUser));

    // Re-arm only for a not-found card, after replyGap so the FF doesn't
    // collide with the ACK. Tune replyGap to match the MCU's read window.
    if (_status == LoginStatus.notFound) {
      Future.delayed(_replyGap, rearm);
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _nfcSub.cancel();
    super.dispose();
  }
}

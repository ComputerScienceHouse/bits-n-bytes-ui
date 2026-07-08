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

  /// Incremented on every login attempt — lets a test prove that one NFC packet
  /// triggers exactly one login (i.e. the listener isn't stacked).
  @visibleForTesting
  int loginAttempts = 0;

  void _onNfc(NfcScan scan) {
    LogService.logEvent('NFC decoded uuid: ${scan.uuid}');
    login(scan.uuid);
  }

  /// (Re-)arm the NFC reader by sending the init command. Safe to call
  /// repeatedly — it does not touch the listener registration.
  void rearm() {
    LogService.logEvent('Sending NFC initialization command...');
    _serial.sendBinaryTo(
      SerialService.portNFC,
      Uint8List.fromList([0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]),
    );
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
        // Card not in the system — tell the reader to try again.
        LogService.logEvent('User not found — re-arming NFC reader.');
        _status = LoginStatus.notFound;
        rearm();
      }
    } catch (e) {
      LogService.logEvent('Login error: $e');
      _status = LoginStatus.error;
    }

    // Tell the ESP whether the tap resolved to a valid user (0xF1) or not (0xF0).
    _serial.sendBinaryTo(
      SerialService.portNFC,
      Uint8List.fromList([isValidUser ? 0xF1 : 0xF0, 0, 0, 0, 0, 0, 0, 0]),
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _nfcSub.cancel();
    super.dispose();
  }
}

import 'dart:async';

import 'package:bits_n_bytes_ui/models/api/user.dart';
import 'package:bits_n_bytes_ui/models/serial/nfc_scan.dart';
import 'package:bits_n_bytes_ui/repositories/user.dart';
import 'package:bits_n_bytes_ui/services/serial_service.dart';
import 'package:bits_n_bytes_ui/viewmodel/welcome.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

/// The VM now consumes `nfcStream` and calls `sendBinaryTo`; noSuchMethod covers
/// the rest of the interface.
class FakeSerial implements SerialService {
  final _nfc = StreamController<NfcScan>.broadcast();

  @override
  Stream<NfcScan> get nfcStream => _nfc.stream;

  /// Simulate a card tap arriving on the stream.
  void emitNfc(int uuid) => _nfc.add(NfcScan(uuid));

  /// First byte of every binary packet the VM sends (0xFF arm, 0xF1/0xF0 result).
  final List<int> sentFirstBytes = [];

  @override
  void sendBinaryTo(String portName, Uint8List data) =>
      sentFirstBytes.add(data.first);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeUserRepository implements UserRepository {
  User? result;
  bool boom = false;
  int calls = 0;

  @override
  Future<User?> findByNfcUuid(int uuid) async {
    calls++;
    if (boom) throw Exception('network down');
    return result;
  }

  @override
  Future<User> getUser(int id) => throw UnimplementedError();
}

void main() {
  // rearm() reads SerialService.portNFC (a dotenv-backed static), so dotenv must
  // be loaded — but no server is needed now that the repo is faked.
  setUp(() => dotenv.loadFromString(envString: 'NFC_PORT=/dev/fake'));

  test(
    'one NFC event → exactly one login (single stream subscription)',
    () async {
      final serial = FakeSerial();
      final repo = FakeUserRepository()
        ..result = const User(
          id: 42,
          name: 'Ada',
          email: 'a@b.com',
          phone: null,
          recordingEnabled: false,
        );
      final vm = WelcomeViewModel(serial: serial, users: repo);

      // Constructor arms the reader once.
      expect(serial.sentFirstBytes, [0xFF]);

      // Stream events are async, so let each one land before asserting.
      serial.emitNfc(111);
      await Future.delayed(Duration.zero);
      expect(vm.loginAttempts, 1);

      vm.rearm(); // must NOT re-subscribe
      serial.emitNfc(222);
      await Future.delayed(Duration.zero);
      expect(vm.loginAttempts, 2); // one login per event, not stacked

      await Future.delayed(
        const Duration(milliseconds: 20),
      ); // drain the logins
      expect(repo.calls, 2);
    },
  );

  test('login success sets the user and sends the valid-user byte', () async {
    final serial = FakeSerial();
    final repo = FakeUserRepository()
      ..result = const User(id: 42, name: 'Ada', email: 'a@b.com', phone: null);
    final vm = WelcomeViewModel(serial: serial, users: repo);

    await vm.login(42);

    expect(vm.status, LoginStatus.success);
    expect(vm.user?.name, 'Ada');
    expect(serial.sentFirstBytes.last, 0xF1);
  });

  test(
    'unknown card (repo returns null) → notFound + re-arm + invalid byte',
    () async {
      final serial = FakeSerial();
      final repo = FakeUserRepository()..result = null;
      final vm = WelcomeViewModel(serial: serial, users: repo);

      await vm.login(999);

      expect(vm.status, LoginStatus.notFound);
      // Re-armed (0xFF) then reported invalid (0xF0).
      expect(serial.sentFirstBytes, containsAllInOrder([0xFF, 0xFF, 0xF0]));
    },
  );
}

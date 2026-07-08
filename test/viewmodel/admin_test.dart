import 'package:bits_n_bytes_ui/services/serial_service.dart';
import 'package:bits_n_bytes_ui/viewmodel/admin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// AdminViewModel only touches espState; noSuchMethod covers the rest.
class FakeSerial implements SerialService {
  @override
  final ValueNotifier<Map<String, dynamic>?> espState = ValueNotifier(null);

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

void main() {
  test('updates shelves when a packet carries shelf_ids', () {
    final serial = FakeSerial();
    final vm = AdminViewModel(serial: serial);

    serial.espState.value = {
      'shelf_ids': ['MAC_1', 'MAC_2'],
    };

    expect(vm.connectedShelves, ['MAC_1', 'MAC_2']);
  });

  test('a door-only packet (no shelf_ids) does not clobber known shelves', () {
    final serial = FakeSerial();
    final vm = AdminViewModel(serial: serial);

    serial.espState.value = {
      'shelf_ids': ['MAC_1'],
    };
    expect(vm.connectedShelves, ['MAC_1']);

    serial.espState.value = {'doors': true}; // partial packet, no shelf_ids
    expect(vm.connectedShelves, ['MAC_1']); // unchanged
  });

  test('does not notify when the shelf list is unchanged', () {
    final serial = FakeSerial();
    final vm = AdminViewModel(serial: serial);

    var notifications = 0;
    vm.addListener(() => notifications++);

    serial.espState.value = {
      'shelf_ids': ['MAC_1'],
    };
    serial.espState.value = {
      'shelf_ids': ['MAC_1'],
    }; // same content

    expect(notifications, 1);
  });
}

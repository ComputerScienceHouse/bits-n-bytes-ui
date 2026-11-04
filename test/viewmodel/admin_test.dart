import 'package:bits_n_bytes_ui/models/serial/esp_state.dart';
import 'package:bits_n_bytes_ui/services/serial_service.dart';
import 'package:bits_n_bytes_ui/viewmodel/admin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// AdminViewModel touches espState and changeShelfPosition; noSuchMethod covers
/// the rest.
class FakeSerial implements SerialService {
  @override
  final ValueNotifier<Map<String, dynamic>?> espState = ValueNotifier(null);

  /// Records positions pushed to the "hardware" so tests can assert on them.
  final List<ShelfData> pushedPositions = [];

  @override
  void changeShelfPosition(ShelfData shelf) => pushedPositions.add(shelf);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  // shelf_ids arrives as a list of objects (see ShelfData).
  Map<String, dynamic> shelf(String mac, [String pos = 'right']) => {
    'mac_address': mac,
    'position': pos,
  };

  test('updates shelves when a packet carries shelf_ids', () {
    final serial = FakeSerial();
    final vm = AdminViewModel(serial: serial);

    serial.espState.value = {
      'shelf_ids': [shelf('MAC_1'), shelf('MAC_2')],
    };

    expect(vm.connectedShelves.map((s) => s.macAddress), ['MAC_1', 'MAC_2']);
  });

  test('a door-only packet (no shelf_ids) does not clobber known shelves', () {
    final serial = FakeSerial();
    final vm = AdminViewModel(serial: serial);

    serial.espState.value = {
      'shelf_ids': [shelf('MAC_1')],
    };
    expect(vm.connectedShelves.map((s) => s.macAddress), ['MAC_1']);

    serial.espState.value = {'doors': true}; // partial packet, no shelf_ids
    expect(vm.connectedShelves.map((s) => s.macAddress), ['MAC_1']); // unchanged
  });

  test('does not notify when the shelf list is unchanged', () {
    final serial = FakeSerial();
    final vm = AdminViewModel(serial: serial);

    var notifications = 0;
    vm.addListener(() => notifications++);

    serial.espState.value = {
      'shelf_ids': [shelf('MAC_1')],
    };
    serial.espState.value = {
      'shelf_ids': [shelf('MAC_1')],
    }; // same content

    expect(notifications, 1);
  });

  test('splits shelves into left/right columns by position', () {
    final serial = FakeSerial();
    final vm = AdminViewModel(serial: serial);

    serial.espState.value = {
      'shelf_ids': [shelf('MAC_1', 'left'), shelf('MAC_2', 'right')],
    };

    expect(vm.leftShelves.map((s) => s.macAddress), ['MAC_1']);
    expect(vm.rightShelves.map((s) => s.macAddress), ['MAC_2']);
  });

  test('moveShelf flips a shelf to the other column', () {
    final serial = FakeSerial();
    final vm = AdminViewModel(serial: serial);

    serial.espState.value = {
      'shelf_ids': [shelf('MAC_1', 'right')],
    };
    expect(vm.rightShelves.map((s) => s.macAddress), ['MAC_1']);
    expect(vm.leftShelves, isEmpty);

    vm.moveShelf('MAC_1');
    expect(vm.leftShelves.map((s) => s.macAddress), ['MAC_1']);
    expect(vm.rightShelves, isEmpty);
  });

  test('a move survives a later ESP packet (position is operator-owned)', () {
    final serial = FakeSerial();
    final vm = AdminViewModel(serial: serial);

    serial.espState.value = {
      'shelf_ids': [shelf('MAC_1', 'right')],
    };
    vm.moveShelf('MAC_1'); // → left

    // ESP keeps reporting 'right', but the operator's move must stick.
    serial.espState.value = {
      'shelf_ids': [shelf('MAC_1', 'right')],
    };
    expect(vm.leftShelves.map((s) => s.macAddress), ['MAC_1']);
    expect(vm.rightShelves, isEmpty);
  });
}

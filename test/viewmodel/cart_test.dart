import 'dart:async';

import 'package:bits_n_bytes_ui/models/api/item.dart';
import 'package:bits_n_bytes_ui/models/api/user.dart';
import 'package:bits_n_bytes_ui/models/serial/cart_delta.dart';
import 'package:bits_n_bytes_ui/models/serial/esp_state.dart';
import 'package:bits_n_bytes_ui/repositories/item.dart';
import 'package:bits_n_bytes_ui/services/serial_service.dart';
import 'package:bits_n_bytes_ui/viewmodel/cart.dart';
import 'package:flutter_test/flutter_test.dart';

/// CartViewModel now consumes espStream/cartStream + the start* methods;
/// noSuchMethod covers the rest of the SerialService interface.
class FakeSerial implements SerialService {
  final _esp = StreamController<EspState>.broadcast();
  final _cart = StreamController<CartDelta>.broadcast();

  @override
  Stream<EspState> get espStream => _esp.stream;
  @override
  Stream<CartDelta> get cartStream => _cart.stream;

  void emitEsp(EspState e) => _esp.add(e);
  void emitCart(CartDelta d) => _cart.add(d);

  @override
  Future<bool> startListeningESP() async => true;
  @override
  Future<bool> startListeningJetson() async => true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Returns a fixed catalog item (quantity 0, like the real fromJson) so the VM
/// has to set the quantity itself via copyWith.
class FakeItemRepository implements ItemRepository {
  @override
  Future<Item> getItem(int id) async => const Item(
    id: 7,
    name: 'Chips',
    imgUrl: 'http://x/c.png',
    price: 1.5,
    quantity: 0,
  );
}

const _user = User(
  id: 1,
  name: 'Ada',
  email: 'a@b.com',
  phone: null,
  recordingEnabled: false,
);

void main() {
  // Covers both _init() (subscribe after awaiting startListening*) and the
  // async delivery of each broadcast stream event.
  Future<void> settle() => Future.delayed(const Duration(milliseconds: 20));

  test(
    'a cart delta fetches the item and adds it with that quantity',
    () async {
      final serial = FakeSerial();
      final vm = CartViewModel(
        user: _user,
        serial: serial,
        items: FakeItemRepository(),
      );
      await settle(); // let _init subscribe to the streams

      serial.emitCart(const CartDelta(id: 7, quantity: 2));
      await settle(); // deliver the event + let the async fetch land

      expect(vm.cart.length, 1);
      expect(vm.cart.single.id, 7);
      expect(vm.cart.single.quantity, 2); // copyWith overrode the catalog qty
      expect(vm.total, 3.0); // 1.5 * 2
    },
  );

  test('doors:true on the ESP raises the checkout signal', () async {
    final serial = FakeSerial();
    final vm = CartViewModel(
      user: _user,
      serial: serial,
      items: FakeItemRepository(),
    );
    await settle();

    expect(vm.checkoutRequested, isFalse);
    serial.emitEsp(const EspState(doorsClosed: true));
    await settle();
    expect(vm.checkoutRequested, isTrue);
  });
}

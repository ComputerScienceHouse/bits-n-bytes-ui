import 'package:bits_n_bytes_ui/client/twilio.dart';
import 'package:bits_n_bytes_ui/models/api/item.dart';
import 'package:bits_n_bytes_ui/models/api/user.dart';
import 'package:bits_n_bytes_ui/services/serial_service.dart';
import 'package:bits_n_bytes_ui/viewmodel/receipt.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeTwilio implements TwilioService {
  bool result = true;
  int calls = 0;

  @override
  Future<bool> sendSms(User user, List<Item> cart) async {
    calls++;
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

class FakeSerial implements SerialService {
  int clearCartCalls = 0;

  @override
  void clearCart() => clearCartCalls++;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

const _user = User(id: 1, name: 'Ada', email: 'a@b.com', phone: '609');
const _noPhone = User(id: 2, name: 'Bob', email: 'b@b.com', phone: null);
const _cart = [
  Item(id: 1, name: 'Chips', imgUrl: '', price: 2.0, quantity: 3),
];

ReceiptViewModel makeVm({
  User user = _user,
  FakeTwilio? twilio,
  int timeoutSeconds = 999,
}) => ReceiptViewModel(
  user: user,
  cart: _cart,
  twilio: twilio ?? FakeTwilio(),
  serial: FakeSerial(),
  timeoutSeconds: timeoutSeconds,
);

void main() {
  test('total sums price * quantity', () {
    final vm = makeVm();
    expect(vm.total, 6.0);
    vm.dispose();
  });

  test('sendSmsReceipt success → sent (delegates to TwilioService)', () async {
    final twilio = FakeTwilio()..result = true;
    final vm = makeVm(twilio: twilio);

    await vm.sendSmsReceipt();

    expect(vm.smsStatus, SendStatus.sent);
    expect(twilio.calls, 1);
    vm.dispose();
  });

  test('sendSmsReceipt failure → error with a message', () async {
    final vm = makeVm(twilio: FakeTwilio()..result = false);

    await vm.sendSmsReceipt();

    expect(vm.smsStatus, SendStatus.error);
    expect(vm.smsError, isNotNull);
    vm.dispose();
  });

  test('no phone on file → error without calling Twilio', () async {
    final twilio = FakeTwilio();
    final vm = makeVm(user: _noPhone, twilio: twilio);

    await vm.sendSmsReceipt();

    expect(vm.smsStatus, SendStatus.error);
    expect(twilio.calls, 0);
    vm.dispose();
  });

  test('countdown decrements each second and raises timedOut at zero', () {
    fakeAsync((async) {
      final vm = makeVm(timeoutSeconds: 2);

      expect(vm.seconds, 2);
      async.elapse(const Duration(seconds: 1));
      expect(vm.seconds, 1);
      expect(vm.timedOut, isFalse);

      async.elapse(const Duration(seconds: 2));
      expect(vm.timedOut, isTrue);

      vm.dispose();
    });
  });
}

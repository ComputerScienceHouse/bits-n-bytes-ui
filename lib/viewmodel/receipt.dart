import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:bits_n_bytes_ui/client/twilio.dart';
import 'package:bits_n_bytes_ui/models/api/item.dart';
import 'package:bits_n_bytes_ui/models/api/user.dart';
import 'package:bits_n_bytes_ui/services/log_service.dart';
import 'package:bits_n_bytes_ui/services/serial_service.dart';

enum SendStatus { idle, sending, sent, error }

/// Owns the receipt screen's state: the auto-timeout countdown and the SMS
/// receipt send. No widgets/BuildContext/Navigator — it emits [timedOut] and
/// the View navigates. SMS delivery is delegated to [TwilioService] (the widget
/// used to inline the Twilio POST).
class ReceiptViewModel extends ChangeNotifier {
  ReceiptViewModel({
    required this.user,
    required this.cart,
    TwilioService? twilio,
    SerialService? serial,
    int timeoutSeconds = 20,
  }) : _twilio = twilio ?? TwilioService(),
       _serial = serial ?? SerialService(),
       _seconds = timeoutSeconds {
    _startCountdown();
  }

  final User user;
  final List<Item> cart;
  final TwilioService _twilio;
  final SerialService _serial;

  Timer? _timer;
  int _seconds;
  int get seconds => _seconds;

  bool _timedOut = false;
  bool get timedOut => _timedOut;

  SendStatus _smsStatus = SendStatus.idle;
  SendStatus get smsStatus => _smsStatus;
  String? _smsError;
  String? get smsError => _smsError;

  double get total => cart.fold(0.0, (sum, i) => sum + i.price * i.quantity);

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_seconds > 0) {
        _seconds--;
      } else {
        _timer?.cancel();
        _timedOut = true;
      }
      notifyListeners();
    });
  }

  Future<void> sendSmsReceipt() async {
    if (user.phone == null || user.phone!.isEmpty) {
      _smsStatus = SendStatus.error;
      _smsError = 'No phone number on file.';
      notifyListeners();
      return;
    }

    _smsStatus = SendStatus.sending;
    _smsError = null;
    notifyListeners();

    try {
      final ok = await _twilio.sendSms(user, cart);
      _smsStatus = ok ? SendStatus.sent : SendStatus.error;
      if (!ok) _smsError = 'Failed to send. Try again.';
    } catch (e) {
      LogService.logEvent('SMS send error: $e');
      _smsStatus = SendStatus.error;
      _smsError = 'Network error. Try again.';
    }
    notifyListeners();
  }

  /// Clear the cart hardware — call when finishing or on timeout.
  void clearCart() => _serial.clearCart();

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

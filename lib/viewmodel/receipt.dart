import 'dart:async';

import 'package:bits_n_bytes_ui/client/email.dart';
import 'package:bits_n_bytes_ui/models/api/transaction.dart';
import 'package:bits_n_bytes_ui/repositories/transaction.dart';
import 'package:flutter/foundation.dart';

import 'package:bits_n_bytes_ui/client/twilio.dart';
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
    required this.fullTransaction,
    TwilioService? twilio,
    SerialService? serial,
    EmailService? email,
    TransactionRepository? transactions,
    int timeoutSeconds = 20,
  }) : _twilio = twilio ?? TwilioService(),
       _serial = serial ?? SerialService(),
       _email = email ?? EmailService(),
       _transactions = transactions ?? TransactionRepository(),
       _seconds = timeoutSeconds {
    _startCountdown();
  }

  final User user;
  final FullTransaction fullTransaction;
  final TwilioService _twilio;
  final EmailService _email;
  final SerialService _serial;
  final TransactionRepository _transactions;

  Timer? _timer;
  int _seconds;
  int get seconds => _seconds;

  bool _timedOut = false;
  bool get timedOut => _timedOut;

  SendStatus _emailStatus = SendStatus.idle;
  SendStatus get emailStatus => _emailStatus;
  String? _emailError;
  String? get emailError => _emailError;

  SendStatus _smsStatus = SendStatus.idle;
  SendStatus get smsStatus => _smsStatus;
  String? _smsError;

  BigInt _receiptSmsTime = BigInt.zero;
  BigInt _receiptEmailTime = BigInt.zero;

  String? get smsError => _smsError;

  double get total =>
      fullTransaction.items.fold(0.0, (sum, i) => sum + i.price * i.quantity);

  // Timing fields removed — durations are not used.

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

  Future<void> sendEmailReceipt() async {
    if (user.email.isEmpty) {
      _emailStatus = SendStatus.error;
      _emailError = "No email on file";
      notifyListeners();
      return;
    }
    // start email send
    _emailStatus = SendStatus.sending;
    _emailError = null;
    notifyListeners();

    try {
      Stopwatch().start();
      final ok = await _email.sendReceipt(user, fullTransaction.items, total);
      _emailStatus = ok ? SendStatus.sent : SendStatus.error;
      Stopwatch().stop();
      _receiptEmailTime = BigInt.from(Stopwatch().elapsedMilliseconds);
    } catch (e) {
      LogService.logEvent('Email send error: $e');
      _emailStatus = SendStatus.error;
      _emailError = 'Network error. Try again.';
    }
    notifyListeners();
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
      Stopwatch().start();
      final ok = await _twilio.sendSms(user, fullTransaction.items);
      _smsStatus = ok ? SendStatus.sent : SendStatus.error;
      Stopwatch().stop();
      _receiptSmsTime = BigInt.from(Stopwatch().elapsedMilliseconds);
      if (!ok) _smsError = 'Failed to send. Try again.';
    } catch (e) {
      LogService.logEvent('SMS send error: $e');
      _smsStatus = SendStatus.error;
      _smsError = 'Network error. Try again.';
    }
    notifyListeners();
  }

  Future<void> createTransaction() async {
    fullTransaction.transaction.userId = user.id;
    fullTransaction.transaction.sentSms = smsStatus == SendStatus.sent;
    fullTransaction.transaction.sentEmail = emailStatus == SendStatus.sent;
    fullTransaction.transaction.receiptEmailTime = _receiptEmailTime;
    fullTransaction.transaction.receiptSmsTime = _receiptSmsTime;
    // transactionStart handled in cart.dart
    // transactionEnd handlded in door_closed.dart
    // createdAt handled internally
    // canceled handled in cart.dart
    // TODO: add a recordedImageData checkbox in receipt screen so this can be tracked
    await _transactions.create(fullTransaction);
  }

  /// Clear the cart hardware — call when finishing or on timeout.
  void clearCart() => _serial.clearCart();

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

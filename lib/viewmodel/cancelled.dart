import 'dart:async';

import 'package:bits_n_bytes_ui/client/api.dart';
import 'package:bits_n_bytes_ui/models/api/transaction.dart';
import 'package:bits_n_bytes_ui/models/api/user.dart';
import 'package:bits_n_bytes_ui/models/serial/cart_delta.dart';
import 'package:bits_n_bytes_ui/models/serial/esp_state.dart';
import 'package:bits_n_bytes_ui/repositories/transaction.dart';
import 'package:bits_n_bytes_ui/services/log_service.dart';
import 'package:bits_n_bytes_ui/services/serial_service.dart';
import 'package:flutter/material.dart';

class CancelledViewModel extends ChangeNotifier {
  CancelledViewModel({
    required this.user,
    required this.transaction,
    TransactionRepository? transactions,
    SerialService? serial,
    ApiService? api,
  }) : _serial = serial ?? SerialService(),
       _transactions = transactions ?? TransactionRepository(),
       _api = api ?? ApiService() {
    _init();
  }

  final User user;
  final FullTransaction transaction;
  final SerialService _serial;
  final TransactionRepository _transactions;
  final ApiService _api;
  StreamSubscription<CartDelta>? _cartSub;
  StreamSubscription<EspState>? _espSub;

  /// True once every item from the cancelled cart has been put back on the
  /// shelves (the Jetson reports removals as negative-quantity deltas).
  bool get allPutBack => transaction.items.isEmpty;
  bool _navigateWelcome = false;
  bool get navigateWelcome => _navigateWelcome;
  bool _navigateReceipt = false;
  bool get navigateReceipt => _navigateReceipt;

  bool _disposed = false;
  bool _welcomeScheduled = false;

  Future<void> _init() async {
    await _serial.startListeningESP();
    _espSub = _serial.espStream.listen(_onEsp);
    await _serial.startListeningJetson();
    _cartSub = _serial.cartStream.listen(_onCart);
    LogService.logEvent(
      'CancelledViewModel: cart has ${transaction.items.length} items, watching for put-backs.',
    );
    // Cancelled with an empty cart → nothing to put back, so go straight to the
    // timed hand-off instead of waiting on a put-back that will never arrive.
    if (allPutBack) _scheduleWelcome();
  }

  void _onEsp(EspState esp) {
    if (_disposed) return;
    // Doors closed while items are still out → charge the shopper for what they
    // kept (routes on to the receipt flow). The all-put-back case is handled by
    // [_onCart]/[_scheduleWelcome] with a timed hand-off, NOT here — otherwise
    // the steady stream of ESP packets would bounce us to the welcome screen the
    // instant this screen opens.
    if (esp.doorsClosed && !allPutBack) {
      transaction.transaction.transactionEnd = DateTime.now();
      _navigateReceipt = true;
      notifyListeners();
    }
  }

  void _onCart(CartDelta cd) {
    if (_disposed) return;
    final wasAllPutBack = allPutBack;
    final i = transaction.items.indexWhere((item) => item.id == cd.id);
    if (i == -1) {
      // Something not in the cancelled cart — ignore.
      return;
    }
    final newQty = transaction.items[i].quantity + cd.quantity;
    if (newQty <= 0) {
      transaction.items.removeAt(i);
    } else {
      transaction.items[i] = transaction.items[i].copyWith(quantity: newQty);
    }
    // Only rebuild the View when the put-back status actually flips.
    if (allPutBack != wasAllPutBack) {
      notifyListeners(); // flip the UI to the "all put back" success state
      if (allPutBack) _scheduleWelcome();
    }
  }

  /// Every item is back on the shelves: hold the success state for 2s so the
  /// shopper sees the confirmation, then a final 1s beat before handing back to
  /// the welcome screen. Guarded so it only ever runs once.
  Future<void> _scheduleWelcome() async {
    if (_welcomeScheduled) return;
    _welcomeScheduled = true;
    transaction.transaction.transactionEnd = DateTime.now();
    _transactions.create(transaction);
    await Future.delayed(const Duration(seconds: 2));
    if (_disposed) return;
    await Future.delayed(const Duration(seconds: 1));
    if (_disposed) return;
    _navigateWelcome = true;
    notifyListeners();
  }

  /// Staff assistance: ping the Slack workflow and hand back to the welcome
  /// screen so the kiosk is freed up.
  void callForHelp() {
    _api.requestHelp(user);
    _navigateWelcome = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _cartSub?.cancel();
    _espSub?.cancel();
    super.dispose();
  }
}

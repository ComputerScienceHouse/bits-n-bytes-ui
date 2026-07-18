import 'dart:async';
import 'package:bits_n_bytes_ui/client/api.dart';
import 'package:bits_n_bytes_ui/repositories/transaction.dart';
import 'package:flutter/foundation.dart';

import 'package:bits_n_bytes_ui/models/api/item.dart';
import 'package:bits_n_bytes_ui/models/api/user.dart';
import 'package:bits_n_bytes_ui/models/api/transaction.dart';
import 'package:bits_n_bytes_ui/models/serial/cart_delta.dart';
import 'package:bits_n_bytes_ui/models/serial/esp_state.dart';
import 'package:bits_n_bytes_ui/repositories/item.dart';
import 'package:bits_n_bytes_ui/services/log_service.dart';
import 'package:bits_n_bytes_ui/services/serial_service.dart';

/// Owns all cart + serial logic for the cart screen. Pure Dart — no widgets,
/// no BuildContext, no Navigator — so it can be unit-tested with a fake
/// SerialService and it emits a [checkoutRequested] signal instead of
/// navigating itself (the View watches that and drives go_router).
class CartViewModel extends ChangeNotifier {
  CartViewModel({
    required this.user,
    ApiService? api,
    SerialService? serial,
    ItemRepository? items,
    TransactionRepository? transactions,
  }) : _api = api ?? ApiService(),
       _serial = serial ?? SerialService(),
       _items = items ?? ItemRepository(),
       _transactions = transactions ?? TransactionRepository() {
    _init();
  }

  final User user;
  final SerialService _serial;
  final ItemRepository _items;
  final TransactionRepository _transactions;
  final ApiService _api;
  StreamSubscription<EspState>? _espSub;
  StreamSubscription<CartDelta>? _cartSub;

  final FullTransaction fullTransaction = FullTransaction.empty();
  List<Item> get cart => fullTransaction.items;
  double get total => cart.fold(0, (sum, i) => sum + i.price * i.quantity);

  bool _checkoutRequested = false;
  bool get checkoutRequested => _checkoutRequested;

  bool _requestHelp = false;
  bool get requestHelpFromUser => _requestHelp;

  final Stopwatch transactionTime = Stopwatch();

  Future<void> _init() async {
    await _serial.startListeningESP();
    _espSub = _serial.espStream.listen(_onEsp);
    await _serial.startListeningJetson();
    _cartSub = _serial.cartStream.listen(_onCart);
    LogService.logEvent('CartViewModel: hardware streams active.');
  }

  void _onEsp(EspState esp) {
    if (esp.doorsClosed) requestCheckout();
  }

  // Each stream event is one discrete delta — no null-reset hack needed.
  void _onCart(CartDelta delta) => _applyDelta(delta);

  Future<void> _applyDelta(CartDelta cd) async {
    final i = fullTransaction.items.indexWhere((item) => item.id == cd.id);
    if (i != -1) {
      final newQty = fullTransaction.items[i].quantity + cd.quantity;
      if (newQty <= 0) {
        fullTransaction.items.removeAt(i);
      } else {
        fullTransaction.items[i] = fullTransaction.items[i].copyWith(
          quantity: newQty,
        );
      }
      notifyListeners();
    } else if (cd.quantity > 0) {
      await _fetchAndAdd(cd.id, cd.quantity);
    } else {
      LogService.logEvent('Removal ignored: item ${cd.id} not in cart.');
    }
  }

  Future<void> _fetchAndAdd(int id, int quantity) async {
    try {
      final item = await _items.getItem(id);
      // The catalog item's own quantity is meaningless here — override it with
      // the delta the Jetson reported.
      fullTransaction.items.add(item.copyWith(quantity: quantity));
      notifyListeners();
    } catch (e) {
      LogService.logEvent('Error fetching item $id: $e');
    }
  }

  /// Fires the checkout signal (door-closed event OR the manual arrow button).
  void requestCheckout() {
    if (_checkoutRequested) return;
    _checkoutRequested = true;
    notifyListeners();
  }

  void cancelTransaction() async {
    // if (cart.isNotEmpty) {
    //   cart.clear();
    // }
    fullTransaction.transaction.canceled = true;
    await _transactions.create(fullTransaction);
    notifyListeners();
  }

  /// Pings the staff Slack workflow so an attendant can come help. Guarded so a
  /// double-tap can't fan out multiple messages; on failure the guard resets so
  /// the shopper can try again.
  void requestHelp(User user) async {
    if (_requestHelp) return;
    _requestHelp = true;
    notifyListeners();
    try {
      await _api.requestHelp(user);
    } catch (e) {
      _requestHelp = false;
      LogService.logEvent('requestHelp failed: $e');
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _espSub?.cancel();
    _cartSub?.cancel();
    super.dispose();
  }
}

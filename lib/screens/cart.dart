import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:bits_n_bytes_ui/components/app_bar.dart';
import 'package:bits_n_bytes_ui/components/cart_item.dart';
import 'package:bits_n_bytes_ui/models/api/user.dart';
import 'package:bits_n_bytes_ui/viewmodel/cart.dart';

/// Thin View. All cart/serial logic lives in [CartViewModel], which is supplied
/// by a route-scoped `ChangeNotifierProvider` (see the `/cart` route). This
/// widget only renders the VM's state and turns the checkout signal into a
/// go_router navigation.
class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // read (not watch): we want the instance, not a rebuild subscription here.
  late final CartViewModel _vm = context.read<CartViewModel>();
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    // Side-effect subscription: navigate when the VM asks to check out.
    _vm.fullTransaction.transaction.transactionStart = DateTime.now();
    _vm.addListener(_onCheckoutRequested);
  }

  void _onCheckoutRequested() {
    if (_vm.checkoutRequested && !_isNavigating) {
      _isNavigating = true;
      context.go(
        '/doorClosed',
        extra: {'transaction': _vm.fullTransaction, 'user': _vm.user},
      );
    }
  }

  void _onCancelTransaction() {
    _vm.cancelTransaction();
    if (!_isNavigating) {
      _isNavigating = true;
      context.go(
        '/cancelled',
        extra: {'transaction': _vm.fullTransaction, 'user': _vm.user},
      );
    }
  }

  @override
  void dispose() {
    _vm.removeListener(_onCheckoutRequested);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User user = _vm.user;
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BnBAppBar(
                  title: "Cart",
                  children: [
                    IconButton(
                      icon: const Icon(LucideIcons.arrowRight),
                      onPressed: _vm.requestCheckout,
                    ),
                  ],
                ),
                Expanded(
                  // Only this subtree rebuilds when the cart changes.
                  child: ListenableBuilder(
                    listenable: _vm,
                    builder: (context, _) {
                      final cart = _vm.cart;
                      if (cart.isEmpty) {
                        return Center(
                          child: Text(
                            "Welcome ${user.name}\nYour cart is empty...",
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 20),
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: cart.length,
                        itemBuilder: (context, index) => CartItem(
                          key: ValueKey(cart[index].id),
                          item: cart[index],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          _buildSidebar(context, user),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, User user) {
    return Container(
      width: MediaQuery.sizeOf(context).width / 3,
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Theme.of(context).colorScheme.outline,
            width: 0.1,
          ),
        ),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          TextButton.icon(
            onPressed: _onCancelTransaction,
            icon: const Icon(LucideIcons.circleX),
            label: const Text('Cancel Transaction'),
            style: TextButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              foregroundColor: Theme.of(
                context,
              ).colorScheme.onSecondaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.all(
                  Radius.elliptical(15, 15),
                ),
              ),
              padding: EdgeInsets.symmetric(vertical: 30, horizontal: 60),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Logged in as:"),
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Pings the staff Slack workflow. Rebuilds with the VM so
                    // the button reflects the "help requested" state once tapped.
                    ListenableBuilder(
                      listenable: _vm,
                      builder: (context, _) {
                        final requested = _vm.requestHelpFromUser;
                        return TextButton.icon(
                          onPressed: requested
                              ? null
                              : () => _vm.requestHelp(user),
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadiusGeometry.circular(10),
                            ),
                            backgroundColor: requested
                                ? Theme.of(context).colorScheme.secondaryFixed
                                : Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onSurface,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                          ),
                          icon: Icon(
                            requested
                                ? LucideIcons.circleCheck
                                : Icons.support_agent,
                            size: 16,
                          ),
                          label: Text(
                            requested ? 'Help is on the way!' : 'Request Help',
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Center(
                  child: SvgPicture.asset(
                    Theme.of(context).brightness == Brightness.dark
                        ? 'assets/images/dark-lockup.svg'
                        : 'assets/images/lockup.svg',
                    width: 275,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

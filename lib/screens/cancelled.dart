import 'package:bits_n_bytes_ui/models/api/user.dart';
import 'package:bits_n_bytes_ui/viewmodel/cancelled.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CancelledPage extends StatefulWidget {
  const CancelledPage({super.key});

  @override
  State<CancelledPage> createState() => _CancelledPageState();
}

class _CancelledPageState extends State<CancelledPage> {
  late final CancelledViewModel _vm = context.read<CancelledViewModel>();
  User get user => _vm.user;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _vm.addListener(_onNavigateWelcome);
    // Side-effect subscription: navigate when the VM asks to check out.
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onNavigateWelcome() {
    if (_vm.navigateWelcome && !_isNavigating) {
      _isNavigating = true;
      context.go('/');
    } else if (_vm.navigateReceipt && !_isNavigating) {
      _isNavigating = true;
      context.go(
        '/doorClosed',
        extra: {'transaction': _vm.transaction, 'user': _vm.user},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // watch (not read): rebuild when the VM flips allPutBack.
    final putBackAll = context.watch<CancelledViewModel>().allPutBack;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 15.0,
              children: [
                Text(
                  "Transaction Cancelled",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 45,
                    fontFamily: Theme.of(
                      context,
                    ).textTheme.displayLarge?.fontFamily,
                  ),
                ),
                Text(
                  putBackAll
                      ? "Items have been put away and your card will not be charged."
                      : "Please put all items back where you found them",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontFamily: Theme.of(
                      context,
                    ).textTheme.labelSmall?.fontFamily,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(40),
                  child: putBackAll
                      ? SvgPicture.asset('assets/images/putback_done.svg')
                      : SvgPicture.asset('assets/images/putback.svg'),
                ),
                Text(
                  putBackAll
                      ? "Have a good day!"
                      : "This message will resolve when all items are put back",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    fontSize: 15,
                    fontFamily: Theme.of(
                      context,
                    ).textTheme.labelSmall?.fontFamily,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 40.0, bottom: 40.0),
                  child: IntrinsicWidth(
                    child: TextButton(
                      onPressed: () => _vm.callForHelp(),
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(10),
                        ),
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.secondaryContainer,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 100,
                          vertical: 30,
                        ),
                      ),
                      child: Text(
                        'Call for Help',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

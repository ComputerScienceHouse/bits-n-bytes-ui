import 'package:bits_n_bytes_ui/models/api/user.dart';
import 'package:bits_n_bytes_ui/services/log_service.dart';
import 'package:bits_n_bytes_ui/viewmodel/cancelled.dart';
import 'package:bits_n_bytes_ui/widgets/admin_password_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
  DragStartDetails? _dragStartDetails;
  final double _minSwipeDistance = 50.0;

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

  void _checkPassword(String password) {
    if (password == (dotenv.env['ADMIN_PASSWORD'] ?? "1024")) {
      LogService.logEvent("Overriding cancelled screen");
      _isNavigating = true;
      context.go('/');

      Navigator.of(context).pop();
    } else {
      LogService.logEvent("Access Denied");
      Navigator.of(context).pop(); // Just pop the dialog
    }
  }

  void _showPasswordDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withAlpha(128),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, anim1, anim2) {
        // The dialog owns its own controller and disposes it in its own
        // dispose() — which runs only after the exit transition completes — so
        // the animating TextField/VirtualKeyboard never touch a disposed
        // controller while we pop-and-navigate to /admin.
        return AdminPasswordDialog(onSubmit: _checkPassword);
      },
    );
  }

  void _handleDragStart(DragStartDetails details) {
    _dragStartDetails = details;
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_dragStartDetails == null) return;

    final double startY = _dragStartDetails!.globalPosition.dy;
    final double endY = details.globalPosition.dy;
    final double distanceY = endY - startY;

    // A positive distance means swiping DOWN.
    if (distanceY > _minSwipeDistance) {
      LogService.logEvent("Downward swipe detected! Distance: $distanceY");
      _showPasswordDialog();
    }

    _dragStartDetails = null;
  }

  @override
  Widget build(BuildContext context) {
    // watch (not read): rebuild when the VM flips allPutBack.
    final putBackAll = context.watch<CancelledViewModel>().allPutBack;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onVerticalDragStart: _handleDragStart,
      onVerticalDragEnd: _handleDragEnd,
      child: Scaffold(
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
                        : "Please put all items back where you found them!",
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
                            horizontal: 50,
                            vertical: 20,
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
      ),
    );
  }
}

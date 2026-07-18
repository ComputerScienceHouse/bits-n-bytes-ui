import 'package:bits_n_bytes_ui/models/api/user.dart';
import 'package:bits_n_bytes_ui/services/log_service.dart';
import 'package:bits_n_bytes_ui/viewmodel/welcome.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:virtual_keyboard_multi_language/virtual_keyboard_multi_language.dart';

/// Thin View. The NFC-tap → login flow lives in [WelcomeViewModel] (supplied by
/// the route-scoped ChangeNotifierProvider); this widget only renders and turns
/// a successful login into a go_router navigation.
class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  late final WelcomeViewModel _vm = context.read<WelcomeViewModel>();
  DragStartDetails? _dragStartDetails;
  final double _minSwipeDistance = 50.0;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _vm.addListener(_onVmChanged);
  }

  void _onVmChanged() {
    if (_vm.status == LoginStatus.success && _vm.user != null && !_navigated) {
      _navigated = true;
      context.go('/name', extra: _vm.user);
    }
  }

  @override
  void dispose() {
    _vm.removeListener(_onVmChanged);
    super.dispose();
  }

  void _checkPassword(String password) {
    if (password == (dotenv.env['ADMIN_PASSWORD'] ?? "1024")) {
      LogService.logEvent("Access Granted");
      // Pop the dialog route, then route to the admin page.
      Navigator.of(context).pop();
      context.go('/admin');
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
        return _AdminPasswordDialog(onSubmit: _checkPassword);
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
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Welcome",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
            ),
            GestureDetector(
              onTap: () => {
                _vm.refresh,
                // TODO: Add a animation to show refresh of NFC
              }, // Re-arm the NFC reader (and allow retrying the same card).
              child: Icon(
                LucideIcons.refreshCcw,
                color: Theme.of(context).colorScheme.onSurface,
                size: 35,
              ),
            ),
          ],
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onVerticalDragStart: _handleDragStart,
        onVerticalDragEnd: _handleDragEnd,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SvgPicture.asset('assets/images/bnb.svg', width: 400),
              TextButton.icon(
                onPressed: () {
                  // Guest checkout — synthesize a placeholder user.
                  context.go(
                    '/name',
                    extra: User(
                      email: "guest@gmail.com",
                      id: 1,
                      name: "Guest",
                      phone: "6097219292",
                      recordingEnabled: false,
                    ),
                  );
                },
                icon: SizedBox.square(
                  dimension: 20,
                  child: SvgPicture.asset(
                    'assets/images/tap.svg',
                    width: 100,
                    height: 100,
                  ),
                ),
                style: TextButton.styleFrom(
                  fixedSize: const Size(400, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(10),
                  ),
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 72,
                    vertical: 16,
                  ),
                ),
                label: Text(
                  'Tap card to continue',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Admin password entry dialog. Owns its [TextEditingController] so the
/// controller is disposed exactly when this widget unmounts (after the dialog's
/// exit transition), never mid-animation.
class _AdminPasswordDialog extends StatefulWidget {
  const _AdminPasswordDialog({required this.onSubmit});

  /// Called with the entered text when Submit is pressed. The parent decides
  /// whether to pop the dialog and where to navigate.
  final void Function(String password) onSubmit;

  @override
  State<_AdminPasswordDialog> createState() => _AdminPasswordDialogState();
}

class _AdminPasswordDialogState extends State<_AdminPasswordDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        children: [
          const Spacer(),
          AlertDialog(
            title: Text(
              textAlign: TextAlign.start,
              'Enter Admin Password',
              style: TextStyle(
                fontSize: 16,
                fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
              ),
            ),
            content: TextField(
              controller: _controller,
              obscureText: true,
              autofocus: true,
              decoration: const InputDecoration(hintText: "Password"),
              readOnly: true, // Prevent OS keyboard
              showCursor: true,
            ),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
              TextButton(
                child: const Text('Submit'),
                onPressed: () {
                  widget.onSubmit(_controller.text);
                },
              ),
            ],
          ),
          const Spacer(),
          Container(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: VirtualKeyboard(
              height: 200,
              textColor: Colors.white,
              textController: _controller,
              type: VirtualKeyboardType.Alphanumeric,
            ),
          ),
        ],
      ),
    );
  }
}

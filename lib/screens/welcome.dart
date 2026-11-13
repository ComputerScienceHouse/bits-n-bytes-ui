import 'package:bits_n_bytes_ui/models/api/user.dart';
import 'package:bits_n_bytes_ui/services/log_service.dart';
import 'package:bits_n_bytes_ui/viewmodel/welcome.dart';
import 'package:bits_n_bytes_ui/widgets/admin_password_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

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
  bool _isRefreshing = false;
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

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() => _isRefreshing = true);

    try {
      _vm.refresh();
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onVerticalDragStart: _handleDragStart,
      onVerticalDragEnd: _handleDragEnd,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Welcome",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
              ),

              IconButton(
                onPressed: _isRefreshing ? null : _handleRefresh,
                icon: _isRefreshing
                    ? const SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(strokeWidth: 3),
                      )
                    : const Icon(LucideIcons.refreshCcw, size: 35),
              ),
            ],
          ),
        ),
        body: Center(
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

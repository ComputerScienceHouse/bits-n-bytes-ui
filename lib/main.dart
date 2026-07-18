import 'package:bits_n_bytes_ui/models/api/transaction.dart';
import 'package:bits_n_bytes_ui/screens/cancelled.dart';
import 'package:bits_n_bytes_ui/services/log_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show MissingPluginException;
import 'package:device_preview/device_preview.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:keep_screen_on/keep_screen_on.dart';
import 'dart:io' show Platform;

import 'util.dart';
import 'theme.dart';
import 'components/debug_log_overlay.dart';
import 'services/serial_service.dart';
import 'models/api/user.dart';
import 'viewmodel/cart.dart';
import 'viewmodel/welcome.dart';
import 'viewmodel/receipt.dart';
import 'viewmodel/admin.dart';
import 'viewmodel/cancelled.dart';
import 'screens/welcome.dart';
import 'screens/name.dart';
import 'screens/cart.dart';
import 'screens/door_closed.dart';
import 'screens/receipt.dart';
import 'screens/admin.dart';

/// Pulls `{'transaction': ..., 'user': ...}` back out of a go_router `extra`
/// payload. The key must match what the navigating screens write (see
/// CartPage/DoorClosedPage `context.go(..., extra: {'transaction': ...})`).
({FullTransaction fullTransaction, User user}) _cartArgs(GoRouterState state) {
  final args = state.extra as Map<String, dynamic>;
  return (
    fullTransaction: args['transaction'] as FullTransaction,
    user: args['user'] as User,
  );
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      // Welcome's ViewModel (NFC listener + login) is created and disposed with
      // this route, so its serial listener can't leak or stack.
      builder: (context, state) => ChangeNotifierProvider(
        create: (_) => WelcomeViewModel(),
        child: const WelcomePage(),
      ),
    ),
    GoRoute(
      path: '/name',
      builder: (context, state) => NamePage(user: state.extra as User),
    ),
    GoRoute(
      path: '/cart',
      // The cart's ViewModel is created (and disposed) with this route, so
      // CartPage can read it and its serial listeners are scoped to the screen.
      builder: (context, state) => ChangeNotifierProvider(
        create: (_) => CartViewModel(user: state.extra as User),
        child: const CartPage(),
      ),
    ),
    GoRoute(
      path: '/doorClosed',
      builder: (context, state) {
        final a = _cartArgs(state);
        return DoorClosedPage(fullTransaction: a.fullTransaction, user: a.user);
      },
    ),
    GoRoute(
      path: '/receipt',
      builder: (context, state) {
        final a = _cartArgs(state);
        return ChangeNotifierProvider(
          create: (_) => ReceiptViewModel(
            user: a.user,
            fullTransaction: a.fullTransaction,
          ),
          child: const ReceiptPage(),
        );
      },
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => ChangeNotifierProvider(
        create: (_) => AdminViewModel(),
        child: const AdminPage(),
      ),
    ),
    GoRoute(
      path: '/cancelled',
      builder: (context, state) {
        final a = _cartArgs(state);
        return ChangeNotifierProvider(
          create: (_) =>
              CancelledViewModel(user: a.user, transaction: a.fullTransaction),
          child: const CancelledPage(),
        );
      },
    ),
  ],
);

final piScreen = DeviceInfo.genericPhone(
  id: 'pi_screen',
  platform: TargetPlatform.linux,
  name: 'Pi 10.1" Screen (1024x600)',
  screenSize: const Size(1024, 600),
  pixelRatio: 1.0,
);

Future main() async {
  // runApp(const MyApp());

  // WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  if (Platform.isLinux) {
    // Initialize all the connections to the PI
    LogService.init();
    LogService.logEvent("Initialized Logger");
    SerialService().startListeningAll();

    // keep_screen_on / window_manager have no implementation under flutter-pi
    // (DRM/KMS) and throw MissingPluginException there. Awaiting the
    // window_manager throw aborts main() before runApp() -> blank screen.
    // Guard them so the app always renders (they work on `-d linux`, and are
    // skipped on flutter-pi, which is fullscreen anyway).
    try {
      await KeepScreenOn.turnOn();
      await windowManager.ensureInitialized();
      const windowOptions = WindowOptions(fullScreen: true, center: true);
      windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });
    } on MissingPluginException catch (e) {
      LogService.logEvent("Skipping desktop window/screen plugins: $e");
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = createTextTheme(context, "Roboto", "IBM Plex Mono");
    MaterialTheme theme = MaterialTheme(textTheme);

    if (Platform.isMacOS) {
      return DevicePreview(
        enabled: true,
        devices: [piScreen],
        builder: (context) => ValueListenableBuilder<ThemeMode>(
          valueListenable: themeModeNotifier,
          builder: (context, mode, _) => MaterialApp.router(
            routerConfig: _router,
            // device_preview 1.3.1 runtime-asserts that this is true, even
            // though newer Flutter has deprecated/ignores it. Removing it
            // crashes DevicePreview at startup — keep it until device_preview is
            // upgraded.
            // ignore: deprecated_member_use
            useInheritedMediaQuery: true,
            builder: (context, child) => DevicePreview.appBuilder(
              context,
              DebugLogOverlay(child: child ?? const SizedBox.shrink()),
            ),
            locale: DevicePreview.locale(context),
            debugShowCheckedModeBanner: false,
            theme: theme.light(),
            darkTheme: theme.dark(),
            themeMode: mode,
          ),
        ),
      );
    }

    return MouseRegion(
      cursor: (dotenv.env['HIDE_CURSOR'] == 'true')
          ? SystemMouseCursors.none
          : SystemMouseCursors.basic,
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: themeModeNotifier,
        builder: (context, mode, _) => MaterialApp.router(
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
          builder: (context, child) =>
              DebugLogOverlay(child: child ?? const SizedBox.shrink()),
          theme: theme.light(),
          darkTheme: theme.dark(),
          themeMode: mode,
        ),
      ),
    );
  }
}

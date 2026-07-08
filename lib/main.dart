
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:keep_screen_on/keep_screen_on.dart';
import 'dart:io' show Platform;

import 'util.dart';
import 'theme.dart';
import 'services/log_service.dart';
import 'services/serial_service.dart';
import 'models/api/item.dart';
import 'models/api/user.dart';
import 'viewmodel/cart.dart';
import 'viewmodel/welcome.dart';
import 'viewmodel/receipt.dart';
import 'viewmodel/admin.dart';
import 'screens/welcome.dart';
import 'screens/name.dart';
import 'screens/cart.dart';
import 'screens/door_closed.dart';
import 'screens/receipt.dart';
import 'screens/admin.dart';

/// Pulls `{'cart': ..., 'user': ...}` back out of a go_router `extra` payload.
({List<Item> cart, User user}) _cartArgs(GoRouterState state) {
  final args = state.extra as Map<String, dynamic>;
  return (cart: args['cart'] as List<Item>, user: args['user'] as User);
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
        return DoorClosedPage(cart: a.cart, user: a.user);
      },
    ),
    GoRoute(
      path: '/receipt',
      builder: (context, state) {
        final a = _cartArgs(state);
        return ChangeNotifierProvider(
          create: (_) => ReceiptViewModel(user: a.user, cart: a.cart),
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
    /* TODO: Add a CancelledScreen()
    GoRoute(
      path: '/cancelled',
      builder: (context, state) => const CancelledPage(),
    ),
    */
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

  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  if (Platform.isLinux) {
    // Pi-only: keep_screen_on has no macOS/Windows impl (MissingPluginException).
    KeepScreenOn.turnOn();
    // Initialize all the connections to the PI
    LogService.init();
    LogService.logEvent("Initialized Logger");
    SerialService().startListeningAll();

    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      fullScreen: true,
      center: true,
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
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
        builder: (context) => MaterialApp.router(
          routerConfig: _router,
          // device_preview 1.3.1 runtime-asserts that this is true, even though
          // newer Flutter has deprecated/ignores it. Removing it crashes
          // DevicePreview at startup — keep it until device_preview is upgraded.
          // ignore: deprecated_member_use
          useInheritedMediaQuery: true,
          builder: DevicePreview.appBuilder,
          locale: DevicePreview.locale(context),
          debugShowCheckedModeBanner: false,
          theme: theme.light(),
          darkTheme: theme.dark(),
          themeMode: ThemeMode.system,
        ),
      );
    }

    return MouseRegion(
      cursor: (dotenv.env['HIDE_CURSOR'] == 'true') ? SystemMouseCursors.none : SystemMouseCursors.basic,
      child: MaterialApp.router(
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
        theme: theme.light(),
        darkTheme: theme.dark(),
        themeMode: ThemeMode.system,
      ),
    );
  }
}

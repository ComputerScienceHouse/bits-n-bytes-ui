import 'package:bits_n_bytes_ui/components/debug_option.dart';
import 'package:bits_n_bytes_ui/pages/admin.dart';
import 'package:bits_n_bytes_ui/pages/cart.dart';
import 'package:bits_n_bytes_ui/pages/door_closed.dart';
import 'package:bits_n_bytes_ui/pages/name.dart';
import 'package:bits_n_bytes_ui/pages/receipt.dart';
import 'package:flutter/material.dart';
import 'util.dart';
import 'theme.dart';
import 'package:device_preview/device_preview.dart';
import 'pages/welcome.dart';
import 'pages/cart.dart';
import 'theme.dart';
import 'util.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io' show Platform;
import '../services/uart.dart';

final piScreen = DeviceInfo.genericPhone(
  id: 'pi_screen',
  platform: TargetPlatform.linux,
  name: 'Pi 10.1" Screen (1024x600)',
  screenSize: const Size(1024, 600),
  pixelRatio: 1.0,
);

void main() async {
  // runApp(const MyApp());
  WidgetsFlutterBinding.ensureInitialized();  

  if(Platform.isLinux) {
    SerialService().startListening();
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      fullScreen: true,
      center: true
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
    return MouseRegion(
        cursor: SystemMouseCursors.none,
        child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme.light(),
        darkTheme: theme.dark(),
        themeMode: ThemeMode.system,
        home: WelcomePage()
      )
    );
  }
}

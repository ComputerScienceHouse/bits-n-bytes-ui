import 'package:flutter/material.dart';
import 'util.dart';
import 'theme.dart';
import 'package:device_preview/device_preview.dart';
import 'pages/welcome.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io' show Platform;
import '../services/uart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:keep_screen_on/keep_screen_on.dart';

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
  KeepScreenOn.turnOn();
  if (Platform.isLinux) {
    SerialService().startListening('/dev/ttyAMA0', baudRate: 9600);
    // SerialService().startListening('', baudRate: 9600);
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
        builder: (context) => MaterialApp(
          useInheritedMediaQuery: true,
          debugShowCheckedModeBanner: false,
          theme: theme.light(),
          darkTheme: theme.dark(),
          themeMode: ThemeMode.system,
          home: WelcomePage(),
        ),
      );
    }

    return MouseRegion(
      cursor: SystemMouseCursors.none,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme.light(),
        darkTheme: theme.dark(),
        themeMode: ThemeMode.system,
        home: WelcomePage(),
      ),
    );
  }
}

import 'dart:developer';
import 'dart:typed_data';

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

  final ackPayload = Uint8List(7);

  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  KeepScreenOn.turnOn();
  if (Platform.isLinux) {
    SerialService().startListening('/dev/ttyAMA0', baudRate: 9600);
    SerialService().startListening('/dev/ttyUSB1', baudRate: 9600);
    // bool esp32Ready = await SerialService().startListening(
    //   '/dev/ttyUSB0', // <-- Port from your JS script
    //   baudRate: 9600, // <-- Baud rate from your JS script
    //   protocol: SerialProtocol.fixedLengthBinary,
    //   payloadSize: 11, // <-- PAYLOAD_SIZE from your JS script
    // );

    // if (esp32Ready) {
    //   log("Main: ESP32 Port /dev/ttyUSB0 ready. Sending 7-byte ACK...");

    //   // Define the 7-byte ACK [0xFF, 0x00, ..., 0x00]
    //   // This creates a list of 7 zeros: [0, 0, 0, 0, 0, 0, 0]
    //   final ackPayload = Uint8List(7);
    //   // This sets the first byte to 0xFF (255)
    //   ackPayload[0] = 0xFF;

    //   // Send the binary packet
    //   SerialService().sendBinaryTo('/dev/ttyUSB0', ackPayload);
    // } else {
    //   log("Main: FAILED to open ESP32 Port /dev/ttyUSB1.");
    // }

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

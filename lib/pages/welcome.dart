import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:bits_n_bytes_ui/database/models/user.dart';
import 'package:bits_n_bytes_ui/pages/admin.dart';
import 'package:bits_n_bytes_ui/pages/name.dart';
import 'package:flutter/cupertino.dart' hide Size;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:virtual_keyboard_multi_language/virtual_keyboard_multi_language.dart';
import '../services/uart.dart'; // Adjust path if needed
import 'dart:async';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  // StreamSubscription<SerialDataPacket>? _nfcSubscription;
  DragStartDetails? _dragStartDetails;
  final double _minSwipeDistance = 50.0;
  String text = '';
  bool shiftEnabled = false;
  bool isNumericMode = false;
  StreamSubscription<SerialDataPacket>? _nfcSubscription;
  late User user;

  @override
  void initState() {
    _initializeNfcListener();
    super.initState();
  }

  void _initializeNfcListener() async {
    // 1. START the listener (opens the port, creates buffer)
    bool success = await SerialService().startListening(
      SerialService.portNFC,
      protocol: SerialProtocol.fixedLengthBinary,
      // Make sure this payloadSize matches your *expected incoming* packet size
      payloadSize: 7,
    );

    if (!success) {
      log("WelcomePage: FAILED to start listening on $SerialService.portNFC");
      return;
    }

    _nfcSubscription = SerialService().dataStream
        .where((packet) => packet.portName == SerialService.portNFC)
        .listen((packet) {
          if (packet.protocol == SerialProtocol.fixedLengthBinary) {
            log("NFC LISTENER recieved binary data");
            final Uint8List binaryData = packet.data as Uint8List;
            final String hexString = binaryData
                .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
                .join('');
            final ByteData byteData = binaryData.buffer.asByteData(
              binaryData.offsetInBytes,
              binaryData.lengthInBytes,
            );
            final int counter = byteData.getUint32(0);
            log("\n--- Received Packet (ESP32) ---");
            log("Buffer (Hex): $hexString");
            log("Decoded Counter: $counter");
            _handleUserLogin(counter);
          }
        });

    log("Sending NFC initialization command..."); // Added log
    SerialService().sendBinaryTo(
      SerialService.portNFC,
      // --- THIS IS YOUR NEW COMMAND ---
      Uint8List.fromList([0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]),
    );
  }

  _handleUserLogin(int uuid) async {
    log("--- 1. Starting User Login for UUID: $uuid ---");
    final getUserIdUrl = Uri.parse('${dotenv.env['API_URL']}nfc/$uuid');
    log("Fetching Token URL: $getUserIdUrl");

    try {
      final response = await http.get(
        getUserIdUrl,
        headers: {"Authorization": "${dotenv.env['API_AUTH_KEY']}"},
      );

      // --- Detailed Log for First Response ---
      log("--- 2. Token API Response ---");
      log("Status Code: ${response.statusCode}");
      log("Response Body: ${response.body}"); // This shows the actual JSON/text

      if (response.statusCode == 200) {
        // API call was successful
        final Map<String, dynamic> tokenData = jsonDecode(response.body);

        int id = tokenData['assigned_user'];
        log("--- 3. Extracted User ID: $id ---");

        try {
          final getUserUrl = Uri.parse('${dotenv.env['API_URL']}users/$id');
          log("Fetching User URL: $getUserUrl");

          final response = await http.get(
            getUserUrl,
            headers: {"Authorization": "${dotenv.env['API_AUTH_KEY']}"},
          );

          // --- Detailed Log for Second Response ---
          log("--- 4. User API Response ---");
          log("Status Code: ${response.statusCode}");
          log(
            "Response Body: ${response.body}",
          ); // This shows the actual JSON/text

          if (response.statusCode == 200) {
            final Map<String, dynamic> userData = jsonDecode(response.body);
            log("--- 5. User Data Decoded ---");
            log(userData.toString()); // Log the map

            user = User(
              id: userData['id'],
              name: userData['name'],
              email: userData['email'] ?? '',
              phone: userData['phone'],
            );

            log("--- 6. User Object Created ---");
            // You might want to add a toString() method to your User model
            // for a cleaner log, but this will work.
            log("User ID: ${user.id}, Name: ${user.name}");

            SerialService().sendJsonTo('/dev/ttyAMA0', {"doors": true});
            log("--- 7. Sent command to open doors ---");

            if (mounted) {
              // Always check 'mounted' in async functions
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  // Pass the 'user' object you just created
                  builder: (context) => NamePage(user: user),
                ),
              );
              log("--- 8. Navigated to NamePage ---");
            } else {
              log("--- 8. ERROR: Widget not mounted, cannot navigate. ---");
            }
          } else {
            log("--- 4. ERROR: User API call failed (Status != 200) ---");
          }
        } catch (e) {
          log("--- ERROR: Exception fetching user from Database ---");
          log(e.toString());
        }
      } else {
        log("--- 2. ERROR: Token API call failed (Status != 200) ---");
      }
    } catch (e) {
      log("--- ERROR: Exception fetching token ---");
      log(e.toString());
    }
  }

  @override
  void dispose() {
    _nfcSubscription?.cancel();
    super.dispose();
  }

  void _checkPassword(String password) {
    if (password == (dotenv.env['ADMIN_PASSWORD'] ?? "1024")) {
      log("Access Granted");
      // Pop the dialog route
      Navigator.of(context).pop();
      // Push the admin page
      Navigator.of(
        context,
        rootNavigator: true,
      ).pushReplacement(MaterialPageRoute(builder: (c) => const AdminPage()));
    } else {
      log("Access Denied");
      Navigator.of(context).pop(); // Just pop the dialog
    }
  }

  void _showPasswordDialog() {
    // Create a controller for the dialog's text field
    final TextEditingController passwordController = TextEditingController();

    showGeneralDialog(
      context: context,
      // --- 2. THIS PREVENTS TAPPING OUTSIDE TO CLOSE ---
      barrierDismissible: false,
      barrierColor: Colors.black.withAlpha(128), // Standard dimming
      transitionDuration: const Duration(milliseconds: 200), // Fade in
      pageBuilder: (context, anim1, anim2) {
        // --- 3. THIS IS THE NEW DIALOG PAGE ---
        return Material(
          color: Colors.transparent,
          // We use a Column to position the dialog and keyboard
          child: Column(
            children: [
              const Spacer(), // Pushes the dialog to the center
              // This is your dialog widget
              AlertDialog(
                title: Text(
                  textAlign: TextAlign.start,
                  'Enter Admin Password',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.fontFamily,
                  ),
                ),
                content: TextField(
                  controller: passwordController,
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
                      _checkPassword(passwordController.text);
                    },
                  ),
                ],
              ),

              const Spacer(), // Pushes the keyboard to the bottom
              // --- 4. THE KEYBOARD, OUTSIDE THE DIALOG ---
              //    But inside the new dialog "page"
              Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: VirtualKeyboard(
                  height: 200,
                  textColor: Colors.white,
                  textController: passwordController,
                  type: VirtualKeyboardType.Alphanumeric,
                ),
              ),
            ],
          ),
        );
      },
    ).then((_) {
      // Dispose the controller when the dialog route is popped
      passwordController.dispose();
    });
  }

  void _handleDragStart(DragStartDetails details) {
    _dragStartDetails = details;
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_dragStartDetails == null) return; // Swipe didn't start properly

    // Get the Y position where the swipe started
    final double startY = _dragStartDetails!.globalPosition.dy;
    // Get the Y position where the swipe ended
    final double endY = details.globalPosition.dy;

    // Calculate the vertical distance
    final double distanceY = endY - startY;

    // A positive distance means swiping DOWN
    if (distanceY > _minSwipeDistance) {
      log("Downward swipe detected! Distance: $distanceY");
      _showPasswordDialog();
    }

    // Reset for the next swipe
    _dragStartDetails = null;
  }

  void _onKeyPress(VirtualKeyboardKey key) {
    if (key.keyType == VirtualKeyboardKeyType.String) {
      text = text + ((shiftEnabled ? key.capsText : key.text) ?? '');
    } else if (key.keyType == VirtualKeyboardKeyType.Action) {
      switch (key.action) {
        case VirtualKeyboardKeyAction.Backspace:
          if (text.isEmpty) return;
          text = text.substring(0, text.length - 1);
          break;
        case VirtualKeyboardKeyAction.Return:
          text += '\n';
          break;
        case VirtualKeyboardKeyAction.Space:
          text = text + (key.text ?? '');
          break;
        case VirtualKeyboardKeyAction.Shift:
          shiftEnabled = !shiftEnabled;
          break;
        default:
      }
    }
    // Update the screen
    setState(() {});
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
            Icon(CupertinoIcons.info, color: Colors.black, size: 48.0),
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
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      // Pass the 'user' object you just created
                      builder: (context) => NamePage(
                        user: User(
                          email: "sahil.h.patel@gmail.com",
                          id: 1,
                          name: "Sahil",
                          phone: "6097219292",
                        ),
                      ),
                    ),
                  );
                },
                icon: SizedBox.square(
                  dimension: 20,
                  child: Image.asset(
                    'assets/images/tap.png',
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

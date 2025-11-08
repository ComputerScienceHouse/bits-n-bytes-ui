import 'dart:developer';
import 'package:bits_n_bytes_ui/pages/admin.dart';
import 'package:bits_n_bytes_ui/pages/name.dart';
import 'package:dart_periphery/dart_periphery.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:virtual_keyboard_multi_language/virtual_keyboard_multi_language.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
     // Check for a sharp upward swipe
    // primaryVelocity is negative when swiping up.
  DragStartDetails? _dragStartDetails;
  final double _minSwipeDistance = 50.0; // Min pixels to swipe

  String text = '';
  // CustomLayoutKeys _customLayoutKeys;
  // True if shift enabled.
  bool shiftEnabled = false;

  // is true will show the numeric keyboard.
  bool isNumericMode = false;

  @override
  void initState() {
    super.initState();
  }

  void _checkPassword(String password) {
    if (password == "1234") {
      log("Access Granted");
      // Pop the dialog route
      Navigator.of(context).pop();
      // Push the admin page
      Navigator.of(context, rootNavigator: true)
          .push(MaterialPageRoute(builder: (c) => const AdminPage()));
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
                        fontFamily:
                            Theme.of(context).textTheme.bodyMedium?.fontFamily)),
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
              )
              
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
            Text("Welcome", style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600)),
            Icon(
              CupertinoIcons.info,
              color: Colors.black,
              size: 48.0
            )
          ]
        ) 
      ),
      body:
      GestureDetector(
        behavior: HitTestBehavior.translucent,
        onVerticalDragStart: _handleDragStart,
        onVerticalDragEnd: _handleDragEnd,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SvgPicture.asset(
                'assets/images/bnb.svg', 
                width: 400
              ),
              TextButton.icon(
                onPressed: () => {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute<void>(
                        builder: (context) => const NamePage(),
                    )
                  )
                },
                icon: SizedBox.square(
                  dimension: 20,
                  child: 
                  Image.asset(
                    'assets/images/tap.png',
                    width: 100,
                    height: 100,
                  ),
                ),
                style: TextButton.styleFrom(
                  fixedSize: const Size(400, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(10)
                  ),
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 72, vertical: 16),  
                ),
                label: Text('Tap card to continue', style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
        )
      )
    );
  }
}
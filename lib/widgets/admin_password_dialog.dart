import 'package:flutter/material.dart';
import 'package:virtual_keyboard_multi_language/virtual_keyboard_multi_language.dart';

/// Admin password entry dialog. Owns its [TextEditingController] so the
/// controller is disposed exactly when this widget unmounts (after the dialog's
/// exit transition), never mid-animation.
class AdminPasswordDialog extends StatefulWidget {
  const AdminPasswordDialog({super.key, required this.onSubmit});

  final void Function(String password) onSubmit;

  @override
  State<AdminPasswordDialog> createState() => _AdminPasswordDialogState();
}

class _AdminPasswordDialogState extends State<AdminPasswordDialog> {
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

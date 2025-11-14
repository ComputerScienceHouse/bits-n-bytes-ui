import 'dart:io';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../services/uart.dart';
import '../pages/welcome.dart';

class _AdminButton {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  _AdminButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });
}

class AdminControlsGrid extends StatelessWidget {
  const AdminControlsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_AdminButton> buttons = [
      _AdminButton(
        icon: LucideIcons.doorOpen,
        label: 'Open Doors',
        onPressed: () {
          SerialService().sendJsonTo('/dev/ttyAMA0', {"doors": true});
        },
      ),
      _AdminButton(
        icon: LucideIcons.lockOpen,
        label: 'Open Hatch',
        onPressed: () {
          SerialService().sendJsonTo('/dev/ttyAMA0', {"hatch": true});
        },
      ),
      _AdminButton(
        icon: LucideIcons.logOut,
        label: 'Exit App',
        onPressed: () => exit(0),
      ),
      _AdminButton(
        icon: LucideIcons.power,
        label: 'Power Off',
        onPressed: () async {
          try {
            final result = await Process.run('sudo', ['poweroff']);
            if (result.exitCode == 0) {
              log("Power off command executed.");
            } else {
              log("Power off command failed:");
              log("STDOUT: ${result.stdout}");
              log("STDERR: ${result.stderr}");
            }
          } catch (e) {
            log("Error running power off command: $e");
          }
        },
      ),
      _AdminButton(
        icon: LucideIcons.arrowLeft,
        label: 'Back',
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const WelcomePage()),
          );
        },
      ),
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
      ),
      itemCount: buttons.length,
      itemBuilder: (context, index) {
        final button = buttons[index]; // Get the data for this button
        return Center(
          child: TextButton.icon(
            icon: SizedBox.square(dimension: 20, child: Icon(button.icon)),
            label: Text(button.label),
            onPressed: button.onPressed,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.all(40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              minimumSize: const Size(220, 0),
            ),
          ),
        );
      },
    );
  }
}

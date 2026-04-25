import 'package:bits_n_bytes_ui/database/models/user.dart';
import 'package:bits_n_bytes_ui/pages/cart.dart';
import 'package:bits_n_bytes_ui/services/serial_service.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class NamePage extends StatefulWidget {
  final User user;

  const NamePage({super.key, required this.user});

  @override
  State<NamePage> createState() => _NamePageState();
}

class _NamePageState extends State<NamePage> {
  Timer? _timer;
  User get user => widget.user;
  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 1), handleTimeout);
    SerialService().openDoors();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void handleTimeout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => CartPage(user: widget.user)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Welcome ${user.name}',
          style: TextStyle(
            fontSize: 60,
            fontFamily: Theme.of(context).textTheme.displayLarge?.fontFamily,
          ),
        ),
      ),
    );
  }
}

import 'package:bits_n_bytes_ui/pages/cart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';

class NamePage extends StatefulWidget {
  const NamePage({super.key});

  @override
  State<NamePage> createState() => _NamePageState();
}

class _NamePageState extends State<NamePage> {
 String name = "Sahil";
 Timer? _timer;

 @override 
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 1), handleTimeout);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void handleTimeout() {
     Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const CartPage()
      )
    );
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Welcome $name',
          style: TextStyle(
            fontSize: 60,
            fontFamily: Theme.of(context).textTheme.displayLarge?.fontFamily
          ),
        )
      )
    );
  }
}
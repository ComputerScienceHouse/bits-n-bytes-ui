import 'package:bits_n_bytes_ui/pages/receipt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:async';

class DoorClosedPage extends StatefulWidget {
  const DoorClosedPage({super.key});

  @override
  State<DoorClosedPage> createState() => _DoorClosedPageState();
}

class _DoorClosedPageState extends State<DoorClosedPage> {
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
        builder: (context) => const ReceiptPage()
      )
    );
  }

@override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            SvgPicture.asset('assets/images/checkmark.svg'),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Door closed\ntransaction complete',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 45,
                    fontFamily: Theme.of(context).textTheme.displayLarge?.fontFamily
                  ),
                ),
                Text(
                  'Thank you $name!',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ],
        )
      )
    );
  }
}
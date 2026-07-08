import 'package:bits_n_bytes_ui/models/api/item.dart';
import 'package:bits_n_bytes_ui/models/api/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

class DoorClosedPage extends StatefulWidget {
  final User user;
  final List<Item> cart;

  const DoorClosedPage({super.key, required this.cart, required this.user});

  @override
  State<DoorClosedPage> createState() => _DoorClosedPageState();
}

class _DoorClosedPageState extends State<DoorClosedPage> {
  Timer? _timer;
  User get user => widget.user;

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
    if (mounted) {
      context.go('/receipt', extra: {'cart': widget.cart, 'user': user});
    }
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
                    fontFamily: Theme.of(
                      context,
                    ).textTheme.displayLarge?.fontFamily,
                  ),
                ),
                Text('Thank you ${user.name}!', style: TextStyle(fontSize: 20)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

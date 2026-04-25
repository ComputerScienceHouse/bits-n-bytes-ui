import 'dart:async';
import 'dart:convert';
import 'package:bits_n_bytes_ui/components/app_bar.dart';
import 'package:bits_n_bytes_ui/database/models/item.dart';
import 'package:bits_n_bytes_ui/database/models/user.dart';
import 'package:bits_n_bytes_ui/pages/welcome.dart';
import 'package:bits_n_bytes_ui/services/serial_service_real.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ReceiptPage extends StatefulWidget {
  final User user;
  final List<Item> cart;

  const ReceiptPage({super.key, required this.cart, required this.user});

  @override
  State<ReceiptPage> createState() => _ReceiptPageState();

  double get cartTotal {
    return cart.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }
}

class _ReceiptPageState extends State<ReceiptPage> {
  Timer? _timer;
  int _seconds = 20;
  bool _smsSending = false;
  bool _smsSent = false;
  String? _smsError;
  User get user => widget.user;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds > 0) {
        setState(() {
          _seconds--;
        });
      } else {
        _timer?.cancel();
        SerialServiceReal().clearCart();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const WelcomePage()),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _sendSmsReceipt() async {
    final phone = user.phone;
    if (phone == null || phone.isEmpty) {
      setState(() => _smsError = 'No phone number on file.');
      return;
    }

    setState(() {
      _smsSending = true;
      _smsError = null;
    });

    final accountSid = dotenv.env['TWILIO_ACCOUNT_SID'] ?? '';
    final authToken = dotenv.env['TWILIO_AUTH_TOKEN'] ?? '';
    final fromNumber = dotenv.env['TWILIO_FROM_NUMBER'] ?? '';

    final lines = widget.cart
        .map(
          (item) =>
              '${item.name} x${item.quantity}  \$${(item.price * item.quantity).toStringAsFixed(2)}',
        )
        .join('\n');

    final body =
        'Thank you for using Bits n Bytes at Imagine RIT!\n'
        'Your receipt is below:\n'
        '--------------------\n'
        '$lines\n'
        '--------------------\n'
        'Subtotal: \$${widget.cartTotal.toStringAsFixed(2)}\n'
    'Total after Imagine RIT discount: \$0.00';

    try {
      final response = await http.post(
        Uri.parse(
          'https://api.twilio.com/2010-04-01/Accounts/$accountSid/Messages.json',
        ),
        headers: {
          'Authorization':
              'Basic ${base64Encode(utf8.encode('$accountSid:$authToken'))}',
        },
        body: {'From': fromNumber, 'To': phone, 'Body': body},
      );

      if (response.statusCode == 201) {
        setState(() => _smsSent = true);
      } else {
        setState(() => _smsError = 'Failed to send. Try again.');
      }
    } catch (_) {
      setState(() => _smsError = 'Network error. Try again.');
    } finally {
      setState(() => _smsSending = false);
    }
  }

  void handleTimeout() {
    setState(() {
      _seconds--;
    });
    if (_seconds == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: BnBAppBar(title: "Total"),
      body: Row(
        children: [
          // 1. This Expanded takes up all space NOT used by the sidebar.
          Expanded(
            // 2. This Centers the receipt container in the middle
            //    of the 'Expanded' space.
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: kToolbarHeight, bottom: 30),
                child: Container(
                  // 3. I've given the receipt a width.
                  //    Without this, 'Center' would shrink it.
                  //    Adjust this value as needed.
                  width: 450,
                  padding: const EdgeInsets.only(top: kToolbarHeight),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withAlpha(30),
                        spreadRadius: 2,
                        blurRadius: 2,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Text(
                        "Thank you!",
                        style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text("Your transaction is complete."),
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: widget.cart.length,
                          itemBuilder: (context, index) {
                            final item = widget.cart[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24.0,
                                vertical: 8.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${item.name} (x${item.quantity})",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    "\$${(item.price * item.quantity).toStringAsFixed(2)}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 8.0,
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Subtotal:",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                Text(
                                  "\$${widget.cartTotal.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Tax:",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                Text(
                                  "\$0.00",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Total:",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  "\$${widget.cartTotal.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // This is your sidebar, which now correctly takes up 1/3
          // of the screen, leaving the rest for the 'Expanded' widget.
          Container(
            width: MediaQuery.sizeOf(context).width / 3,
            alignment: Alignment.centerRight,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                  width: 0.1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha(50),
                  spreadRadius: 2,
                  blurRadius: 2,
                  offset: const Offset(0, 3),
                ),
              ],
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.only(top: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(
                        top: 0,
                        left: 20,
                        right: 20,
                        bottom: 20,
                      ),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.secondaryContainer.withAlpha(40),
                        ),
                        color: Theme.of(context).colorScheme.secondaryFixed,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            LucideIcons.clock,
                            color: Theme.of(
                              context,
                            ).colorScheme.secondaryContainer,
                          ),
                          const SizedBox(width: 8),
                          RichText(
                            text: TextSpan(
                              style: Theme.of(context).textTheme.bodySmall,
                              children: [
                                TextSpan(
                                  text: "Timing out in ",
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondaryContainer,
                                  ),
                                ),
                                TextSpan(
                                  text: _seconds.toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondaryContainer,
                                  ),
                                ),
                                TextSpan(
                                  text: "s",
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondaryContainer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: (_smsSending || _smsSent)
                          ? null
                          : _sendSmsReceipt,
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(10),
                        ),
                        backgroundColor: _smsSent
                            ? Theme.of(context).colorScheme.secondaryFixed
                            : Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onSurface,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 16,
                        ),
                      ),
                      icon: _smsSending
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              _smsSent
                                  ? LucideIcons.circleCheck
                                  : LucideIcons.messageSquare,
                              size: 16,
                            ),
                      label: Text(
                        _smsSent ? 'Receipt Sent!' : 'Get Text Receipt',
                      ),
                    ),
                    if (_smsError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _smsError!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        SerialServiceReal().clearCart();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute<void>(
                            builder: (context) => const WelcomePage(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(10),
                        ),
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 96,
                          vertical: 16,
                        ),
                      ),
                      child: const Text('Finish Transaction'),
                    ),
                    Container(
                      margin: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Logged in as:"),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                user.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () => {},
                                icon: const Icon(
                                  LucideIcons.squarePen,
                                  size: 14,
                                ),
                                style: TextButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer
                                      .withAlpha(60),
                                  foregroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 0,
                                    horizontal: 0,
                                  ),
                                ),
                                label: const Text(
                                  'Edit',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 20),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border(
                                left: BorderSide(
                                  color: Theme.of(context).colorScheme.outline,
                                  width: 0.1,
                                ),
                              ),
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant.withAlpha(40),
                            ),
                            child: const Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SizedBox(width: 10),
                                Icon(LucideIcons.circleCheck),
                                SizedBox(width: 20),
                                Flexible(
                                  child: Text(
                                    "Press finish or wait for the session to time out.",
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                SizedBox(width: 10),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 159),
                            alignment: AlignmentDirectional.center,
                            child: SvgPicture.asset(
                              'assets/images/lockup.svg',
                              width: 275,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

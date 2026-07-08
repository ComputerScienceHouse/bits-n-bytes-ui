// service interacting with the Twilio API so we can send text messages
import 'dart:convert';
import 'package:bits_n_bytes_ui/models/api/item.dart';
import 'package:bits_n_bytes_ui/models/api/user.dart';
import 'package:bits_n_bytes_ui/services/log_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TwilioService {
  static final client = http.Client();

  final accountSid = dotenv.env['TWILIO_ACCOUNT_SID'] ?? '';
  final authToken = dotenv.env['TWILIO_AUTH_TOKEN'] ?? '';
  final fromNumber = dotenv.env['TWILIO_FROM_NUMBER'] ?? '';

  Future<bool> sendSms(User user, List<Item> cart) async {
    if (user.phone == null) {
      LogService.logEvent(
        "ERROR: User does not have a phone number, please enter a phone number",
      );
      return false;
    }
    final lines = cart
        .map(
          (item) =>
              '${item.name} x${item.quantity}  \$${(item.price * item.quantity).toStringAsFixed(2)}',
        )
        .join('\n');

    final total = cart.fold(
      0.0,
      (total, item) => total + (item.price * item.quantity),
    );

    final body =
        'Thank you for using Bits n Bytes at Imagine RIT!\n'
        'Your receipt is below:\n'
        '--------------------\n'
        '$lines\n'
        '--------------------\n'
        'Subtotal: \$${total.toStringAsFixed(2)}\n'
        'Total after Open Sauce discount: \$0.00';
    try {
      final response = await http.post(
        Uri.parse(
          'https://api.twilio.com/2010-04-01/Accounts/$accountSid/Messages.json',
        ),
        headers: {
          'Authorization':
              'Basic ${base64Encode(utf8.encode('$accountSid:$authToken'))}',
        },
        body: {'From': fromNumber, 'To': user.phone, 'Body': body},
      );
      if (response.statusCode == 201) {
        return true;
      }
      LogService.logEvent(
        'Failed to send sms: ${response.statusCode} ${response.body}',
      );
    } catch (e) {
      LogService.logEvent('Error in sending sms: $e');
      rethrow;
    }
    return false;
  }
}

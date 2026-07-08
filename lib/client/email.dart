// service interacting with SMTP so we can send emails out
import 'dart:convert';
import 'package:bits_n_bytes_ui/models/api/user.dart';
import 'package:bits_n_bytes_ui/services/log_service.dart';
import 'package:bits_n_bytes_ui/models/api/item.dart';
import 'package:jinja/loaders.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:jinja/jinja.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

class EmailService {
  final server = SmtpServer(
    'thoth.csh.rit.edu',
    port: 465,
    ssl: true,
    username: dotenv.env["BNB_EMAIL_USER"],
    password: dotenv.env["BNB_EMAIL_PASSWORD"],
  );

  Environment get environment => Environment(
    // Search the templates dir (was computed but never passed to the loader).
    loader: FileSystemLoader(paths: [templateDir]),
    finalize: (Object? value) {
      // Sanitize function to handle null and esacpe strings
      if (value == null) return '';
      if (value is String) {
        return const HtmlEscape().convert(value);
      }
      return value;
    },
  );

  static final projectDir = Directory.current.parent.parent;
  final templateDir = path.join(projectDir.path, 'templates');

  /// Returns true when the receipt email was accepted by the SMTP server.
  /// (Was `void`, so callers could neither await it nor learn the outcome.)
  Future<bool> sendReceipt(User user, List<Item> cart, double total) async {
    Template template = environment.getTemplate("order_confirmation.html");
    // TODO: Change `items` in order_confirmation.html to `cart`
    String htmlBody = template.render({"cart": cart, "total": total});

    final msg = Message()
      ..from = Address(
        "Bits n' Bytes",
        dotenv.env["BNB_EMAIL_ADDRESS"] ?? "bitsnbytes@csh.rit.edu",
      )
      ..recipients.add(user.email)
      ..subject = "Bits n' Bytes Order Confirmation"
      ..html = htmlBody;

    try {
      final response = await send(msg, server);
      LogService.logEvent("Message sent: $response");
      return true;
    } on MailerException catch (e) {
      LogService.logEvent("Message not sent");
      for (var p in e.problems) {
        LogService.logEvent('Problem: ${p.code}: ${p.msg}');
      }
    } catch (e) {
      LogService.logEvent("Unexpected error with EmailService $e");
    }
    return false;
  }
}

// service interacting with SMTP so we can send emails out
import 'dart:convert';
import 'package:bits_n_bytes_ui/models/api/user.dart';
import 'package:bits_n_bytes_ui/services/log_service.dart';
import 'package:bits_n_bytes_ui/models/api/item.dart';
import 'package:flutter/services.dart' show rootBundle, AssetManifest;
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:jinja/jinja.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Sends [message] over [server]. Matches mailer's top-level `send`, but is a
/// seam so tests can inject a fake sender instead of hitting a real SMTP host.
typedef EmailSendFn =
    Future<dynamic> Function(Message message, SmtpServer server);

/// Loads the email templates as a name→source map (e.g.
/// `{'order_confirmation.html': '...', '_header.html': '...'}`). Injectable so
/// tests can supply templates without touching the asset bundle.
typedef TemplatesLoader = Future<Map<String, String>> Function();

class EmailService {
  /// [sendFn] and [templatesLoader] are injectable for tests; production uses
  /// the real mailer `send` and the bundled asset templates.
  EmailService({EmailSendFn? sendFn, TemplatesLoader? templatesLoader})
    : _send = sendFn ?? _defaultSend,
      _loadTemplates = templatesLoader ?? _defaultLoadTemplates;

  final EmailSendFn _send;
  final TemplatesLoader _loadTemplates;

  static Future<dynamic> _defaultSend(Message message, SmtpServer server) =>
      send(message, server);

  /// Templates ship as assets (see pubspec `assets/templates/`) so they exist
  /// at runtime on every target — flutter-pi runs from a bundle, not the source
  /// tree, so reading them off disk with a FileSystemLoader never worked there.
  static Future<Map<String, String>> _defaultLoadTemplates() async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final keys = manifest.listAssets().where(
      (k) => k.startsWith('assets/templates/') && k.endsWith('.html'),
    );
    final entries = await Future.wait(
      keys.map(
        (k) async =>
            MapEntry(k.split('/').last, await rootBundle.loadString(k)),
      ),
    );
    return Map.fromEntries(entries);
  }

  final server = SmtpServer(
    'thoth.csh.rit.edu',
    port: 465,
    ssl: true,
    username: dotenv.env["BNB_EMAIL_USER"],
    password: dotenv.env["BNB_EMAIL_PASSWORD"],
  );

  /// Jinja environment backed by an in-memory [MapLoader] so `{% include %}`s
  /// between the templates resolve by filename.
  Environment _environmentFor(Map<String, String> templates) => Environment(
    loader: MapLoader(templates),
    // Dart's package:jinja leaves the `format` filter unimplemented (it's
    // commented out in filters.dart), so register it — the templates use
    // `"%.2f" | format(price)` for currency.
    filters: {'format': _formatFilter},
    finalize: (Object? value) {
      // Sanitize: handle null and escape strings.
      if (value == null) return '';
      if (value is String) {
        return const HtmlEscape().convert(value);
      }
      return value;
    },
  );

  /// Minimal stand-in for Python-Jinja's printf-style `format` filter. Supports
  /// the specs our templates use: `%.Nf` (currency), `%d`, `%s`. The piped
  /// format string arrives first, then the value(s): `"%.2f" | format(price)`.
  static String _formatFilter(
    String format, [
    Object? a,
    Object? b,
    Object? c,
  ]) {
    final args = <Object?>[a, b, c];
    var i = 0;
    return format.replaceAllMapped(RegExp(r'%(\.\d+)?[dfs]'), (m) {
      final value = i < args.length ? args[i++] : null;
      final spec = m.group(0)!;
      if (spec.endsWith('f') && value is num) {
        final precision = m.group(1); // e.g. ".2"
        final digits = precision != null
            ? int.parse(precision.substring(1))
            : 6;
        return value.toStringAsFixed(digits);
      }
      if (spec.endsWith('d') && value is num) return value.toInt().toString();
      return '$value';
    });
  }

  /// Returns true when the receipt email was accepted by the SMTP server.
  /// (Was `void`, so callers could neither await it nor learn the outcome.)
  Future<bool> sendReceipt(User user, List<Item> cart, double total) async {
    final templates = await _loadTemplates();
    final template = _environmentFor(
      templates,
    ).getTemplate("order_confirmation.html");
    String htmlBody = template.render({"cart": cart, "total": total});

    final msg = Message()
      ..from = Address(
        dotenv.env["BNB_EMAIL_ADDRESS"] ?? "bitsnbytes@csh.rit.edu",
        "Bits n' Bytes",
      )
      ..recipients.add(user.email)
      ..subject = "Bits n' Bytes Order Confirmation"
      ..html = htmlBody;

    try {
      final response = await _send(msg, server);
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

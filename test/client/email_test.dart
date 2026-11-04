import 'package:bits_n_bytes_ui/client/email.dart';
import 'package:bits_n_bytes_ui/models/api/item.dart';
import 'package:bits_n_bytes_ui/models/api/user.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mailer/mailer.dart';

void main() {
  setUp(() {
    // EmailService's SmtpServer field reads these at construction time.
    dotenv.loadFromString(
      envString:
          'BNB_EMAIL_USER=u\nBNB_EMAIL_PASSWORD=p\nBNB_EMAIL_ADDRESS=bnb@csh.rit.edu',
    );
  });

  const user = User(
    id: 1,
    name: 'Ada',
    email: 'ada@example.com',
    phone: null,
    recordingEnabled: false,
  );
  final cart = [Item(id: 1, name: 'Chips', imgUrl: '', price: 1.5, quantity: 2)];

  // A minimal template with an include (to prove MapLoader resolves partials)
  // and the `format` filter our real templates rely on.
  Future<Map<String, String>> templates() async => {
    'order_confirmation.html':
        'Total: \${{ "%.2f" | format(total) }} '
            'Items: {{ cart | length }} {% include "_footer.html" %}',
    '_footer.html': 'Thanks!',
  };

  test('sendReceipt renders the template, sends, and returns true', () async {
    Message? sent;
    final service = EmailService(
      templatesLoader: templates,
      sendFn: (message, server) async {
        sent = message;
        return 'ok';
      },
    );

    final result = await service.sendReceipt(user, cart, 3.0);

    expect(result, isTrue);
    expect(sent, isNotNull);
    expect(sent!.subject, "Bits n' Bytes Order Confirmation");
    expect(sent!.recipients, contains('ada@example.com'));
    // Template rendered with the passed total + cart, the `format` filter
    // applied ($3.00, not 3.0), and the include resolved.
    expect(sent!.html, contains(r'Total: $3.00'));
    expect(sent!.html, contains('Items: 1'));
    expect(sent!.html, contains('Thanks!'));
  });

  test('sendReceipt returns false when the sender throws', () async {
    final service = EmailService(
      templatesLoader: templates,
      sendFn: (message, server) async => throw Exception('smtp down'),
    );

    expect(await service.sendReceipt(user, cart, 3.0), isFalse);
  });
}

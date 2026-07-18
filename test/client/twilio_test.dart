import 'dart:convert';

import 'package:bits_n_bytes_ui/client/twilio.dart';
import 'package:bits_n_bytes_ui/models/api/item.dart';
import 'package:bits_n_bytes_ui/models/api/user.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  setUp(() {
    dotenv.loadFromString(
      envString:
          'TWILIO_ACCOUNT_SID=AC123\nTWILIO_AUTH_TOKEN=tok\nTWILIO_FROM_NUMBER=+15550000000',
    );
  });

  const user = User(
    id: 1,
    name: 'Ada',
    email: 'ada@example.com',
    phone: '+15551234567',
    recordingEnabled: false,
  );
  final cart = [
    Item(id: 1, name: 'Chips', imgUrl: '', price: 1.5, quantity: 2),
    Item(id: 2, name: 'Soda', imgUrl: '', price: 2.0, quantity: 1),
  ];

  test('sendSms sends nothing and returns false when the user has no phone', () async {
    var called = false;
    final client = MockClient((req) async {
      called = true;
      return http.Response('', 201);
    });
    const noPhone = User(
      id: 1,
      name: 'Ada',
      email: 'ada@example.com',
      phone: null,
      recordingEnabled: false,
    );

    expect(await TwilioService(client: client).sendSms(noPhone, cart), isFalse);
    expect(called, isFalse);
  });

  test('sendSms posts to Twilio with basic auth and returns true on 201', () async {
    late http.Request captured;
    final client = MockClient((req) async {
      captured = req;
      return http.Response('{"sid":"SM1"}', 201);
    });

    final result = await TwilioService(client: client).sendSms(user, cart);

    expect(result, isTrue);
    expect(captured.method, 'POST');
    expect(captured.url.toString(), contains('/Accounts/AC123/Messages.json'));
    expect(captured.bodyFields['From'], '+15550000000');
    expect(captured.bodyFields['To'], '+15551234567');
    expect(captured.bodyFields['Body'], contains('Chips x2'));

    // Authorization is Basic base64("<sid>:<token>").
    final auth = captured.headers['authorization']!;
    expect(auth, startsWith('Basic '));
    expect(utf8.decode(base64Decode(auth.split(' ').last)), 'AC123:tok');
  });

  test('sendSms returns false on a non-201 response', () async {
    final client = MockClient((req) async => http.Response('bad', 400));
    expect(await TwilioService(client: client).sendSms(user, cart), isFalse);
  });

  test('sendSms rethrows when the request throws', () async {
    final client = MockClient((req) async => throw const _Boom());
    expect(
      () => TwilioService(client: client).sendSms(user, cart),
      throwsA(isA<_Boom>()),
    );
  });
}

class _Boom implements Exception {
  const _Boom();
}

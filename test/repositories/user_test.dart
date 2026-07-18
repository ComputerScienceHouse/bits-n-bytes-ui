import 'dart:io';

import 'package:bits_n_bytes_ui/repositories/user.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late HttpServer server;
  int nfcStatus = 200; // flip per test to drive the nfc-lookup response

  setUp(() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((req) async {
      if (req.uri.path.startsWith('/nfc/')) {
        req.response.statusCode = nfcStatus;
        if (nfcStatus == 200) req.response.write('{"assigned_user": 42}');
      } else {
        req.response
          ..statusCode = 200
          ..write('{"id":42,"name":"Ada","email":"ada@example.com"}');
      }
      await req.response.close();
    });
    dotenv.loadFromString(
      envString:
          'API_URL=http://${server.address.host}:${server.port}\nAPI_AUTH_KEY=k',
    );
  });

  tearDown(() async => server.close(force: true));

  test('findByNfcUuid returns the assigned user on 200 → 200', () async {
    nfcStatus = 200;
    final user = await UserRepository().findByNfcUuid(1);
    expect(user?.id, 42);
    expect(user?.name, 'Ada');
  });

  test('findByNfcUuid returns null when the card is unknown (nfc 404)', () async {
    nfcStatus = 404;
    expect(await UserRepository().findByNfcUuid(1), isNull);
  });

  test('findByNfcUuid throws on a server error (nfc 500)', () async {
    nfcStatus = 500;
    expect(
      () => UserRepository().findByNfcUuid(1),
      throwsA(isA<Exception>()),
    );
  });
}

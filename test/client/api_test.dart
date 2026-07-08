import 'dart:io';

import 'package:bits_n_bytes_ui/client/api.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late HttpServer server;
  late List<HttpRequest> received;

  setUp(() async {
    received = [];
    // Local server that records each request and replies with a valid user.
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((req) async {
      received.add(req);
      req.response
        ..statusCode = 200
        ..write('{"id":1,"name":"Ada","email":"ada@example.com"}');
      await req.response.close();
    });

    // Mirror the real .env convention: API_URL includes scheme + trailing slash.
    dotenv.loadFromString(
      envString:
          'API_URL=http://${server.address.host}:${server.port}/\nAPI_AUTH_KEY=UI test-key-123',
    );
  });

  tearDown(() async => server.close(force: true));

  test('getUserById resolves <API_URL>users/<id> with the auth header', () async {
    final user = await ApiService.getUserById(1);

    expect(user.id, 1);
    expect(user.name, 'Ada');
    // Proves the Uri.parse fix: a real path, not a FormatException.
    expect(received.single.uri.path, '/users/1');
    expect(received.single.headers.value('authorization'), 'UI test-key-123');
  });

  test('getItemById resolves <API_URL>items/<id>', () async {
    // Item.fromJson needs id/name/price; thumb_img maps to imgUrl.
    server.close(force: true);
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((req) async {
      received.add(req);
      req.response
        ..statusCode = 200
        ..write('{"id":7,"name":"Chips","price":1.5,"thumb_img":"http://x/c.png"}');
      await req.response.close();
    });
    dotenv.loadFromString(
      envString:
          'API_URL=http://${server.address.host}:${server.port}/\nAPI_AUTH_KEY=UI test-key-123',
    );

    final item = await ApiService.getItemById(7);

    expect(item.id, 7);
    expect(item.imgUrl, 'http://x/c.png');
    expect(received.single.uri.path, '/items/7');
  });
}

import 'dart:io';

import 'package:bits_n_bytes_ui/repositories/item.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late HttpServer server;
  late List<HttpRequest> received;

  setUp(() async {
    received = [];
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
          'API_URL=http://${server.address.host}:${server.port}\nAPI_AUTH_KEY=k',
    );
  });

  tearDown(() async => server.close(force: true));

  test('getItem delegates to the API and maps the returned item', () async {
    final item = await ItemRepository().getItem(7);

    expect(item.id, 7);
    expect(item.name, 'Chips');
    expect(item.price, 1.5);
    // The API returns `thumb_img`; Item.fromJson maps it to imgUrl.
    expect(item.imgUrl, 'http://x/c.png');

    expect(received.length, 1);
    expect(received.single.method, 'GET');
  });

  test('getItem rethrows when the backend errors', () async {
    server.close(force: true);
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((req) async {
      req.response.statusCode = 500;
      await req.response.close();
    });
    dotenv.loadFromString(
      envString:
          'API_URL=http://${server.address.host}:${server.port}\nAPI_AUTH_KEY=k',
    );

    expect(() => ItemRepository().getItem(7), throwsA(isA<Exception>()));
  });
}

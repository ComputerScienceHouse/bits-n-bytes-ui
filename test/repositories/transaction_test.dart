import 'dart:convert';
import 'dart:io';

import 'package:bits_n_bytes_ui/models/api/item.dart';
import 'package:bits_n_bytes_ui/models/api/transaction.dart';
import 'package:bits_n_bytes_ui/repositories/transaction.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late HttpServer server;
  late List<HttpRequest> received;
  late List<String> bodies;

  setUp(() async {
    received = [];
    bodies = [];
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((req) async {
      received.add(req);
      bodies.add(await utf8.decoder.bind(req).join());
      req.response
        ..statusCode = 200
        ..write('{"transaction_id":1}');
      await req.response.close();
    });
    dotenv.loadFromString(
      envString:
          'API_URL=http://${server.address.host}:${server.port}\nAPI_AUTH_KEY=k',
    );
  });

  tearDown(() async => server.close(force: true));

  FullTransaction buildTransaction(List<Item> items) {
    final start = DateTime.utc(2026, 7, 8, 21, 45);
    return FullTransaction(
      transaction: Transaction(
        userId: 267,
        createdAt: start,
        sentSms: true,
        sentEmail: false,
        transactionStart: start,
        transactionEnd: DateTime.utc(2026, 7, 8, 21, 47, 11),
        receiptSmsTime: BigInt.from(20000),
        receiptEmailTime: BigInt.from(41000),
        recordedImageData: true,
        canceled: false,
      ),
      items: items,
    );
  }

  test('create POSTs the packet when it has items', () async {
    await TransactionRepository().create(
      buildTransaction([
        Item(id: 1, name: 'Chips', imgUrl: '', price: 1.5, quantity: 2),
        Item(id: 2, name: 'Soda', imgUrl: '', price: 2.0, quantity: 1),
      ]),
    );

    expect(received.length, 1);
    expect(received.single.method, 'POST');

    final body = jsonDecode(bodies.single) as Map<String, dynamic>;
    expect(body['transaction']['user_id'], 267);
    expect(body['transaction']['receipt_sms_time'], 20000);
    expect(body['items'], [
      {'item_id': 1, 'quantity': 2},
      {'item_id': 2, 'quantity': 1},
    ]);
  });

  test('create is a no-op for an empty transaction (nothing is sent)', () async {
    await TransactionRepository().create(buildTransaction([]));

    // Give any erroneous request a chance to arrive before asserting none did.
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(received, isEmpty);
  });
}

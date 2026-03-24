import 'package:redis/redis.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:developer';

void main(List<String> arguments) async {
  final conn = RedisConnection();

  final cmd = await conn.connect('localhost', 6379);
  log('Connected to Redis server.');

  // CACHE ALL ITEMS IN REDIS
  var url = Uri.https(dotenv.env['API_URL']!, '/get_items');
  var response = await http.get(url);
  if (response.statusCode == 200) {
    var items = convert.jsonDecode(response.body) as List<dynamic>;
    for (var itemJson in items) {
      if (itemJson is Map<String, dynamic> && itemJson.containsKey('id')) {
        // Create a unique key for this item, e.g., "item:1"
        String key = "item:${itemJson['id']}";
        String value = convert.jsonEncode(itemJson);
        await cmd.send_object(["SET", key, value]);
        log('Cached $key in Redis');
      }
    }
  } else {
    log('Failed to fetch from API: ${response.statusCode}');
  }

  conn.close();
}

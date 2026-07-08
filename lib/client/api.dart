// service interacting with our backend API so we can make calls to authenticate users

import 'dart:convert';
import 'package:bits_n_bytes_ui/models/api/item.dart';
import 'package:bits_n_bytes_ui/models/api/nfc.dart';
import 'package:bits_n_bytes_ui/models/api/user.dart';
import 'package:bits_n_bytes_ui/services/log_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static final client = http.Client();

  static Future<User> getUserById(int id) async {
    try {
      // API_URL carries the scheme and a trailing slash, so append the path
      // without a leading slash (avoids a `//users` double slash).
      var response = await client.get(
        Uri.parse('${dotenv.env["API_URL"]}users/$id'),
        headers: {"Authorization": dotenv.env["API_AUTH_KEY"] ?? ''},
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        LogService.logEvent('Success: $json');
        return User.fromJson(json);
      } else {
        LogService.logEvent('Server Error Status: ${response.statusCode}');
        throw Exception('Failed to load user');
      }
    } catch (e) {
      LogService.logEvent('Unexpected error $e');
      rethrow;
    }
  }

  static Future<Nfc> getNfcById(int id) async {
    try {
      var response = await client.get(
        Uri.parse('${dotenv.env["API_URL"]}nfc/$id'),
        headers: {"Authorization": dotenv.env["API_AUTH_KEY"] ?? ''},
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        LogService.logEvent('Success: $json');
        return Nfc.fromJson(json);
      } else {
        LogService.logEvent('Server Error Status: ${response.statusCode}');
        throw Exception('Failed to load user');
      }
    } catch (e) {
      LogService.logEvent('Unexpected error $e');
      rethrow;
    }
  }

  static Future<Item> getItemById(int id) async {
    try {
      var response = await client.get(
        Uri.parse('${dotenv.env["API_URL"]}items/$id'),
        headers: {"Authorization": dotenv.env["API_AUTH_KEY"] ?? ''},
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        LogService.logEvent('Success: $json');
        return Item.fromJson(json);
      } else {
        LogService.logEvent('Server Error Status: ${response.statusCode}');
        throw Exception('Failed to load item');
      }
    } catch (e) {
      LogService.logEvent('Unexpected error $e');
      rethrow;
    }
  }

  //TODO: Add createTransaction method, will return a 200 with the transactionId

  //TODO: Add postTransaction method, will use transactionId, list of items (cart), and other stats like sms sent/recieved, email sent/recieved
}

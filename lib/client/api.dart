// service interacting with our backend API so we can make calls to authenticate users

import 'dart:convert';

import 'package:bits_n_bytes_ui/models/api/item.dart';
import 'package:bits_n_bytes_ui/models/api/nfc.dart';
import 'package:bits_n_bytes_ui/models/api/transaction.dart' as bnb;
import 'package:bits_n_bytes_ui/models/api/user.dart';
import 'package:bits_n_bytes_ui/services/log_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

//NOTE: Changed .env API_URL to remove backslash, this may or may not cause bugs, noting this down for safekeep

class ApiService {
  static final client = http.Client();

  static Future<User> getUserById(int id) async {
    try {
      // API_URL carries the scheme and a trailing slash, so append the path
      // without a leading slash (avoids a `//users` double slash).
      var response = await client.get(
        Uri.parse('${dotenv.env["API_URL"]}/users/$id'),
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
      LogService.logEvent('API ENDPOINT: ${dotenv.env["API_URL"]}/nfc/$id');
      var response = await client.get(
        Uri.parse('${dotenv.env["API_URL"]}//nfc/$id'),
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
        Uri.parse('${dotenv.env["API_URL"]}/items/$id'),
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
  //TODO: Add createTransaction method, will return a 200

  static Future<void> createTransaction(bnb.FullTransaction transaction) async {
    try {
      LogService.logEvent(
        "Created transaction: $transaction with items: ${transaction.items}",
      );
      var response = await client.post(
        Uri.parse('${dotenv.env["API_URL"]}/add_transaction'),
        headers: {
          "Authorization": dotenv.env["API_AUTH_KEY"] ?? '',
          "Content-Type": "application/json",
        },
        body: jsonEncode(transaction.toJson()),
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(
          response.body,
        ); // This has the transactionId; we dont really need it
        LogService.logEvent('Success: $json');
      } else {
        LogService.logEvent('Server Error Status: ${response.statusCode}');
        throw Exception('Failed to load item');
      }
    } catch (e) {
      LogService.logEvent('Unexpected error $e');
      rethrow;
    }
  }

  Future<void> requestHelp(User user) async {
    if (dotenv.env["DEV_MODE"] == "True") {
      LogService.logEvent("DEV MODE: Help is on the way");
      return;
    }
    try {
      LogService.logEvent("Requesting help for ${user.name}");
      var response = await client.post(
        Uri.parse(
          'https://hooks.slack.com/triggers/${dotenv.env["SLACK_TRIGGER"]}',
        ),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": user.name}),
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(
          response.body,
        ); // This has the transactionId; we dont really need it
        LogService.logEvent('Success: $json');
      } else {
        LogService.logEvent('Server Error Status: ${response.statusCode}');
        throw Exception('Failed to load item');
      }
    } catch (e) {
      LogService.logEvent('Unexpected error $e');
      rethrow;
    }
  }
}

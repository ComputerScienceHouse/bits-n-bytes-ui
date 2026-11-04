import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:bits_n_bytes_ui/client/api.dart';
import 'package:bits_n_bytes_ui/models/api/user.dart';

/// Reads users from the backend. Phase 3b adds a local-cache fallback here.
class UserRepository {
  /// Fetch a user by id (throws on any non-200 — see [ApiService]).
  Future<User> getUser(int id) => ApiService.getUserById(id);

  /// Two-hop NFC login: card [uuid] → assigned user id → [User].
  ///
  /// Returns null when the card isn't in the system (the nfc lookup returns
  /// 404) so the caller can re-arm the reader; throws on any other failure so
  /// "not found" and "error" stay distinguishable. Builds [User] leniently
  /// (email may be absent) to match the kiosk's existing login behavior.
  Future<User?> findByNfcUuid(int uuid) async {
    final nfcResponse = await http.get(
      Uri.parse('${dotenv.env['API_URL']}/nfc/$uuid'),
      headers: {"Authorization": "${dotenv.env['API_AUTH_KEY']}"},
    );
    if (nfcResponse.statusCode == 404) return null;
    if (nfcResponse.statusCode != 200) {
      throw Exception('NFC lookup failed (${nfcResponse.statusCode})');
    }
    final int id = jsonDecode(nfcResponse.body)['assigned_user'];

    final userResponse = await http.get(
      Uri.parse('${dotenv.env['API_URL']}/users/$id'),
      headers: {"Authorization": "${dotenv.env['API_AUTH_KEY']}"},
    );
    if (userResponse.statusCode != 200) {
      throw Exception('User lookup failed (${userResponse.statusCode})');
    }
    final data = jsonDecode(userResponse.body);
    return User(
      id: data['id'],
      name: data['name'],
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      recordingEnabled: data['recordingEnabled'] ?? false,
    );
  }
}

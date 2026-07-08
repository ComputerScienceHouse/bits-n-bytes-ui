import 'package:bits_n_bytes_ui/client/api.dart';
import 'package:bits_n_bytes_ui/models/api/item.dart';

/// Reads catalog items. For now a thin pass-through to the backend client;
/// Phase 3b gives it a local-cache fallback (remote-first, write-through).
class ItemRepository {
  Future<Item> getItem(int id) => ApiService.getItemById(id);
}

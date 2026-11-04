import 'package:bits_n_bytes_ui/client/api.dart';
import 'package:bits_n_bytes_ui/models/api/transaction.dart';

class TransactionRepository {
  Future<void> create(FullTransaction t) async {
    if (!t.isEmpty) {
      await ApiService.createTransaction(t);
    }
  }
}

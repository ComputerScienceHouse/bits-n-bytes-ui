import 'package:bits_n_bytes_ui/models/api/item.dart';

/// Full request body for the create-transaction POST endpoint.
///
/// Shape:
/// ```json
/// {
///   "transaction": { ...fields },
///   "items": [ { "item_id": 1, "quantity": 2 }, ... ]
/// }
/// ```
class FullTransaction {
  Transaction transaction;
  final List<Item> items;

  FullTransaction({required this.transaction, required this.items});

  /// Creates an empty packet: a zeroed [Transaction] and a growable, empty
  /// item list. Used as the initial cart state before anything is scanned in.
  factory FullTransaction.empty() {
    return FullTransaction(transaction: Transaction.empty(), items: <Item>[]);
  }

  /// True when no items have been scanned into the cart yet.
  bool get isEmpty => items.isEmpty;

  Map<String, dynamic> toJson() {
    return {
      'transaction': transaction.toJson(),
      'items': [
        for (final item in items)
          {'item_id': item.id, 'quantity': item.quantity},
      ],
    };
  }
}

/// The nested `transaction` object inside a [TransactionPacket].
class Transaction {
  late int userId;
  final DateTime createdAt;
  late bool sentSms;
  late bool sentEmail;
  late DateTime transactionStart;
  late DateTime transactionEnd;
  late BigInt receiptSmsTime; // in milliseconds; round trip
  late BigInt receiptEmailTime; // in milliseconds; round trip
  late bool recordedImageData; // whether the item was recorded for capture
  late bool canceled;

  Transaction({
    required this.userId,
    required this.createdAt,
    required this.sentSms,
    required this.sentEmail,
    required this.transactionStart,
    required this.transactionEnd,
    required this.receiptSmsTime,
    required this.receiptEmailTime,
    required this.recordedImageData,
    required this.canceled,
  });

  /// A zeroed transaction with timestamps defaulted to "now". Fields are meant
  /// to be filled in over the course of a session before the packet is posted.
  factory Transaction.empty() {
    final now = DateTime.now();
    return Transaction(
      userId: 0,
      createdAt: now,
      sentSms: false,
      sentEmail: false,
      transactionStart: now,
      transactionEnd: now,
      receiptSmsTime: BigInt.zero,
      receiptEmailTime: BigInt.zero,
      recordedImageData: false,
      canceled: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'created_at': _formatDateTime(createdAt),
      'sent_sms': sentSms,
      'sent_email': sentEmail,
      'transaction_start': _formatDateTime(transactionStart),
      'transaction_end': _formatDateTime(transactionEnd),
      'receipt_sms_time': receiptSmsTime.toInt(),
      'receipt_email_time': receiptEmailTime.toInt(),
      'recorded_image_data': recordedImageData,
      'canceled': canceled,
    };
  }

  /// Formats a [DateTime] as `YYYY-MM-DD HH:MM:SS±HH:MM` to match the API's
  /// expected timestamp format (space separator, seconds precision, explicit
  /// UTC offset).
  static String _formatDateTime(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');

    final date =
        '${dt.year.toString().padLeft(4, '0')}-'
        '${two(dt.month)}-${two(dt.day)}';
    final time = '${two(dt.hour)}:${two(dt.minute)}:${two(dt.second)}';

    final offset = dt.timeZoneOffset;
    final sign = offset.isNegative ? '-' : '+';
    final absMinutes = offset.inMinutes.abs();
    final tz = '$sign${two(absMinutes ~/ 60)}:${two(absMinutes % 60)}';

    return '$date $time$tz';
  }
}

/// A single inventory change reported by the Jetson vision system over serial.
///
/// A positive [quantity] adds that many of item [id] to the cart; a negative
/// [quantity] removes them. Arrives as `{"id": 1, "quantity": 2}`.
class CartDelta {
  final int id;
  final int quantity;

  const CartDelta({required this.id, required this.quantity});

  factory CartDelta.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      // `num` tolerates ints or doubles coming off the wire.
      {'id': final num id, 'quantity': final num quantity} => CartDelta(
        id: id.toInt(),
        quantity: quantity.toInt(),
      ),
      _ => throw const FormatException('Failed to parse CartDelta'),
    };
  }
}

class Item {
  final int id;
  final String name;
  final String imgUrl;
  final double price;
  final int quantity;

  const Item({
    required this.id,
    required this.name,
    required this.imgUrl,
    required this.price,
    required this.quantity,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      // `num` tolerates ints or doubles off the wire; only id/name/price are
      // guaranteed by the items endpoint.
      {'id': final num id, 'name': final String name, 'price': final num price} =>
        Item(
          id: id.toInt(),
          name: name,
          // The API returns `thumb_img`; accept `imgUrl` too as a fallback.
          imgUrl: (json['thumb_img'] ?? json['imgUrl'] ?? '') as String,
          price: price.toDouble(),
          // The items endpoint carries no quantity — default to 0 and let the
          // cart set it via copyWith (see CartViewModel).
          quantity: (json['quantity'] as num?)?.toInt() ?? 0,
        ),
      _ => throw const FormatException('Failed to load item'),
    };
  }

  /// Returns a copy with the given fields replaced. Lets callers bump the
  /// quantity (or any single field) without rebuilding the whole object.
  Item copyWith({
    int? id,
    String? name,
    String? imgUrl,
    double? price,
    int? quantity,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      imgUrl: imgUrl ?? this.imgUrl,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }
}

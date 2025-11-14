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
      {
        'id': int id,
        'name': String name,
        'imgUrl': String imgUrl,
        'price': double price,
        'quantity': int quantity,
      } =>
        Item(
          id: id,
          name: name,
          imgUrl: imgUrl,
          price: price,
          quantity: quantity,
        ),
      _ => throw const FormatException('Failed to load item'),
    };
  }
}

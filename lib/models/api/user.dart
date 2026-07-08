class User {
  final int id;
  final String name;
  final String email;
  final String? phone;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {'id': int id, 'name': String name, 'email': String email} => User(
        id: id,
        name: name,
        email: email,
        phone: json['phone'] as String?,
      ),
      _ => throw const FormatException('Failed to load user'),
    };
  }
}

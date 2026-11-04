class Nfc {
  final int id;
  final int assignedUser;
  final String? type;

  const Nfc({required this.id, required this.assignedUser, required this.type});

  factory Nfc.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {'id': int id, 'assigned_user': int assignedUser, 'type': String type} =>
        Nfc(id: id, assignedUser: assignedUser, type: type),
      _ => throw const FormatException('Failed to load Nfc data'),
    };
  }
}

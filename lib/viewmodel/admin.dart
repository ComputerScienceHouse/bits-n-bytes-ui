import 'package:flutter/foundation.dart';

import 'package:bits_n_bytes_ui/services/serial_service.dart';

/// Backs the admin "Tare" tab: the list of shelves the ESP currently reports.
///
/// Still reads the raw `espState` notifier (not `espStream`) on purpose: the ESP
/// sends partial packets, and we must update **only** when a packet actually
/// carried `shelf_ids` — otherwise a door-only packet would clobber the known
/// shelves. The typed `EspState` stream defaults `shelfIds` to `[]`, which loses
/// that "was it present?" distinction.
class AdminViewModel extends ChangeNotifier {
  AdminViewModel({SerialService? serial}) : _serial = serial ?? SerialService() {
    _serial.espState.addListener(_onEspState);
  }

  final SerialService _serial;

  List<String> _connectedShelves = [];
  List<String> get connectedShelves => List.unmodifiable(_connectedShelves);

  void _onEspState() {
    final json = _serial.espState.value;
    if (json == null) return;

    final raw = json['shelf_ids'];
    if (raw is! List) return; // absent (or wrong type) → keep current shelves

    final next = raw.map((e) => e.toString()).toList();
    if (!listEquals(_connectedShelves, next)) {
      _connectedShelves = next;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _serial.espState.removeListener(_onEspState);
    super.dispose();
  }
}

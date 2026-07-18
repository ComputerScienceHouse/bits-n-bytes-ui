import 'package:bits_n_bytes_ui/models/serial/esp_state.dart';
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
  AdminViewModel({SerialService? serial})
    : _serial = serial ?? SerialService() {
    _serial.espState.addListener(_onEspState);
    // addListener does NOT fire for the value already in the notifier, so seed
    // from the last ESP packet — otherwise the Tare tab stays empty until the
    // *next* packet arrives (the shelf list is usually reported before the
    // admin screen is opened).
    _onEspState();
  }

  final SerialService _serial;

  List<ShelfData> _connectedShelves = [];
  List<ShelfData> get connectedShelves => List.unmodifiable(_connectedShelves);

  /// Shelves assigned to each column. Position is operator-controlled via
  /// [moveShelf]; the ESP's reported position is only used as the initial value.
  List<ShelfData> get leftShelves =>
      _connectedShelves.where((s) => s.position == 'left').toList();
  List<ShelfData> get rightShelves =>
      _connectedShelves.where((s) => s.position != 'left').toList();

  void _onEspState() {
    final json = _serial.espState.value;
    if (json == null) return;

    // Door-only packet (no shelf list) → keep the known shelves instead of
    // clobbering them. `json['shelf_ids']` is raw decoded JSON (a List of
    // objects), so parse it the same way EspState does rather than type-testing.
    if (!EspState.hasShelfIds(json)) return;
    final incoming = EspState.fromJson(json).shelfData;

    // Preserve the operator's column choice (see [moveShelf]) for shelves we
    // already track; only brand-new shelves take the ESP-reported position.
    final knownPos = {
      for (final s in _connectedShelves) s.macAddress: s.position,
    };
    final next = [
      for (final s in incoming)
        ShelfData(
          macAddress: s.macAddress,
          position: knownPos[s.macAddress] ?? s.position,
        ),
    ];

    // Compare by mac address (ShelfData has no ==) so unchanged packets don't
    // trigger needless rebuilds.
    final changed = !listEquals(
      _connectedShelves.map((s) => s.macAddress).toList(),
      next.map((s) => s.macAddress).toList(),
    );
    if (changed) {
      _connectedShelves = next;
      notifyListeners();
    }
  }

  /// Flip a shelf between the left and right columns.
  void moveShelf(String macAddress) {
    final i = _connectedShelves.indexWhere((s) => s.macAddress == macAddress);
    if (i == -1) return;
    final current = _connectedShelves[i];
    final newShelf = ShelfData(
      macAddress: current.macAddress,
      position: current.position == 'left' ? 'right' : 'left',
    );
    _connectedShelves = [..._connectedShelves]..[i] = newShelf;
    _serial.changeShelfPosition(newShelf);
    notifyListeners();
  }

  @override
  void dispose() {
    _serial.espState.removeListener(_onEspState);
    super.dispose();
  }
}

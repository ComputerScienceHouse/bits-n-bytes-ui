/// Snapshot of the ESP32 enclosure state, received over serial as JSON.
///
/// Unlike the API models this parses **leniently**: the ESP may send partial
/// packets (e.g. a door event is just `{"doors": true, "hatch": false}`), so
/// every field defaults instead of throwing when a key is absent.
///
/// Full packet shape:
/// ```json
/// { "doors": true, "hatch": true, "temp_c": 56,
///   "intake_rpm": 1000, "exhaust_rmp": 1000,
///   "shelf_ids": ["MAC_1", "MAC_2", "MAC_3"] }
/// ```

class ShelfData {
  final String macAddress;
  final String position;

  const ShelfData({this.macAddress = "", this.position = "right"});

  factory ShelfData.fromJson(Map<String, dynamic> json) => ShelfData(
    macAddress: json["mac_address"] ?? "",
    position: json["position"] ?? "right",
  );
}

class EspState {
  /// The ESP reports `doors: true` when the enclosure is **shut** (the signal
  /// the cart uses to move to checkout).
  final bool doorsClosed;
  final bool hatchOpen;
  final int tempC;
  final int intakeRpm;
  final int exhaustRpm;
  final List<ShelfData> shelfData;

  const EspState({
    this.doorsClosed = false,
    this.hatchOpen = false,
    this.tempC = 0,
    this.intakeRpm = 0,
    this.exhaustRpm = 0,
    this.shelfData = const [],
  });

  factory EspState.fromJson(Map<String, dynamic> json) => EspState(
    doorsClosed: json['doors'] == true,
    hatchOpen: json['hatch'] == true,
    tempC: (json['temp_c'] as num?)?.toInt() ?? 0,
    intakeRpm: (json['intake_rpm'] as num?)?.toInt() ?? 0,
    // Note: the firmware key is misspelled "exhaust_rmp".
    exhaustRpm: (json['exhaust_rmp'] as num?)?.toInt() ?? 0,
    shelfData:
        (json['shelf_ids'] as List?)
            ?.map((e) => ShelfData.fromJson(e))
            .toList() ??
        const [],
  );

  /// True when the packet actually carried a shelf list — lets a consumer
  /// ignore door-only packets instead of clobbering a known shelf list.
  static bool hasShelfIds(Map<String, dynamic> json) =>
      json['shelf_ids'] is List;
}

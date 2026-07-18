import 'dart:async';
import 'dart:typed_data'; // Required for Uint8List
import 'package:bits_n_bytes_ui/models/api/user.dart';
import 'package:bits_n_bytes_ui/models/serial/cart_delta.dart';
import 'package:bits_n_bytes_ui/models/serial/esp_state.dart';
import 'package:bits_n_bytes_ui/models/serial/nfc_scan.dart';
import 'package:bits_n_bytes_ui/services/serial_service_real.dart';
import 'package:bits_n_bytes_ui/services/serial_service_sim.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum SerialProtocol {
  /// Expects JSON objects wrapped in { ... }
  json,

  /// Expects fixed-length raw binary packets
  fixedLengthBinary,
}

class SerialDataPacket {
  final String portName;
  final SerialProtocol protocol;
  final dynamic
  data; // Will be Map<String, dynamic> for JSON, Uint8List for binary

  SerialDataPacket({
    required this.portName,
    required this.protocol,
    required this.data,
  });

  @override
  String toString() {
    // This gives you a useful LogService.logEvent message when you print the object
    return 'SerialDataPacket(port: $portName, protocol: $protocol, data: $data)';
  }
}

abstract class SerialService {
  static final String portESP = getPort("ESP_PORT", "/dev/ttyAMA0");
  static final String portJetson = getPort("JETSON_PORT", "/dev/AMA4");
  static final String portNFC = getPort("NFC_PORT", "/dev/ttyAMA3");

  // Common Notifiers
  ValueNotifier<Map<String, dynamic>?> get espState;
  ValueNotifier<Map<String, dynamic>?> get jetsonState;
  ValueNotifier<Uint8List?> get nfcState;

  // Typed event streams derived from the notifiers above (Phase 4B dual-API).
  // Consumers migrate off the notifiers onto these one at a time; the streams
  // emit the typed model equivalent of each notifier update.
  Stream<EspState> get espStream;
  Stream<CartDelta> get cartStream;
  Stream<NfcScan> get nfcStream;
  EspState? get latestEsp; // last value (streams are broadcast → no replay)
  CartDelta? get latestCart;
  NfcScan? get latestNfc;

  Future<bool> startListening(
    String portName, {
    int baudRate,
    int payloadSize,
    SerialProtocol protocol,
  });
  Future<bool> startListeningAll();
  void sendJsonTo(String portName, Map<String, dynamic> data);
  bool isListening(String portName);
  void dispose();
  void sendBinaryTo(String portName, Uint8List data);
  void broadcastJson(Map<String, dynamic> data);
  void stopListening(String portName);
  void openDoors();
  void openHatch();
  void clearCart();
  void requestVideoCapture(User user);
  void changeShelfPosition(ShelfData shelf);
  Future<void> hardResetPort(String portName, {int baudRate = 9600});
  Future<bool> startListeningNFC();
  Future<bool> startListeningJetson();
  Future<bool> startListeningESP();

  // Singleton accessor that handles the switch logic
  static final SerialService _instance = _buildService();
  factory SerialService() => _instance;

  static SerialService _buildService() {
    return (dotenv.env['SIM_CONNECTIONS'] == 'true')
        ? SerialServiceSim()
        : SerialServiceReal();
  }

  /// True when the in-process simulator backend is active (desktop dev).
  static bool get useSimulator => _instance is SerialServiceSim;

  static String getPort(String envStr, String defaultVal) {
    String? val = dotenv.env[envStr];
    return (val != null) ? val : defaultVal;
  }
}

/// Derives the typed [espStream]/[cartStream]/[nfcStream] from the raw
/// notifiers, so both service impls share one source of truth during the
/// Phase 4B dual-API migration. The impl provides the notifiers and calls
/// [bindStreams] from its constructor (and [disposeStreams] from `dispose`).
mixin SerialStreams {
  ValueNotifier<Map<String, dynamic>?> get espState;
  ValueNotifier<Map<String, dynamic>?> get jetsonState;
  ValueNotifier<Uint8List?> get nfcState;

  final _espController = StreamController<EspState>.broadcast();
  final _cartController = StreamController<CartDelta>.broadcast();
  final _nfcController = StreamController<NfcScan>.broadcast();

  EspState? _latestEsp;
  CartDelta? _latestCart;
  NfcScan? _latestNfc;

  Stream<EspState> get espStream => _espController.stream;
  Stream<CartDelta> get cartStream => _cartController.stream;
  Stream<NfcScan> get nfcStream => _nfcController.stream;
  EspState? get latestEsp => _latestEsp;
  CartDelta? get latestCart => _latestCart;
  NfcScan? get latestNfc => _latestNfc;

  /// Emit a typed event whenever the underlying notifier changes. Call once
  /// from the impl's constructor.
  void bindStreams() {
    espState.addListener(() {
      final v = espState.value;
      if (v == null) return;
      final esp = EspState.fromJson(v);
      _latestEsp = esp;
      _espController.add(esp);
    });
    jetsonState.addListener(() {
      final v = jetsonState.value;
      if (v == null) return;
      try {
        final delta = CartDelta.fromJson(v);
        _latestCart = delta;
        _cartController.add(delta);
      } on FormatException {
        // Malformed cart delta — the notifier still holds the raw map, but
        // there's no typed event to emit. Keep parity by simply skipping.
      }
    });
    nfcState.addListener(() {
      final v = nfcState.value;
      if (v == null || v.length < 4) return;
      final scan = NfcScan.fromBytes(v);
      _latestNfc = scan;
      _nfcController.add(scan);
    });
  }

  void disposeStreams() {
    _espController.close();
    _cartController.close();
    _nfcController.close();
  }
}

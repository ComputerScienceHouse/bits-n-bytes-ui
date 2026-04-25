import 'dart:async';
import 'dart:typed_data'; // Required for Uint8List
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
  static final String portNFC = getPort("NFC_PORT", "/dev/ttyUSB1");

  // Common Notifiers
  ValueNotifier<Map<String, dynamic>?> get espState;
  ValueNotifier<Map<String, dynamic>?> get jetsonState;
  ValueNotifier<Uint8List?> get nfcState;

  Future<bool> startListening(String portName, {
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
  Future<void> hardResetPort(String portName, {int baudRate = 9600});
  Future<bool> startListeningNFC();
  Future<bool> startListeningJetson();
  Future<bool> startListeningESP();
  
  // Singleton accessor that handles the switch logic
  static final SerialService _instance = _buildService();
  factory SerialService() => _instance;

  static SerialService _buildService() {
    return (dotenv.env['SIM_CONNECTIONS'] == 'true') ? SerialServiceSim() : SerialServiceReal();
  }

  static String getPort(String envStr, String defaultVal) {
    String? val = dotenv.env[envStr];
    return (val != null) ? val : defaultVal;
  }
}
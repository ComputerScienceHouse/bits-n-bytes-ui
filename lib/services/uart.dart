import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data'; // Required for Uint8List
import 'package:flutter_libserialport/flutter_libserialport.dart';

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
    // This gives you a useful log message when you print the object
    return 'SerialDataPacket(port: $portName, protocol: $protocol, data: $data)';
  }
}

class SerialService {
  // Singleton remains to provide a central access point
  static final SerialService _instance = SerialService._internal();
  factory SerialService() => _instance;
  SerialService._internal();

  static final String portESP = String.fromEnvironment("ESP_PORT", defaultValue: "/dev/ttyAMA0");
  static final String portJetson = String.fromEnvironment("JETSON_PORT", defaultValue: "/dev/ttyUSB0");
  static final String portNFC = String.fromEnvironment("NFC_PORT", defaultValue: "/dev/ttyUSB1");

  // Maps to hold separate resources for each port
  final Map<String, SerialPort> _ports = {};
  final Map<String, StreamSubscription> _subscriptions = {};

  final Map<String, String> _jsonBuffers = {}; // For JSON string data
  final Map<String, Uint8List> _binaryBuffers = {}; // For raw binary data
  final Map<String, int> _binaryPayloadSizes =
      {}; // Stores PAYLOAD_SIZE for binary ports
  final Map<String, SerialProtocol> _portProtocols =
      {}; // Stores protocol for each port

  // A single stream for all data from ALL ports.
  // You might want to wrap the data to know WHICH port it came from.
  final _dataStreamController = StreamController<SerialDataPacket>.broadcast();
  Stream<SerialDataPacket> get dataStream => _dataStreamController.stream;

  Future<bool> startListening(
    String portName, {
    int baudRate = 9600,
    SerialProtocol protocol = SerialProtocol.json,
    int payloadSize = 0, // REQUIRED for fixedLengthBinary
  }) async {
    if (_ports.containsKey(portName)) {
      log("SerialService: Already listening on $portName");
      return true;
    }

    if (protocol == SerialProtocol.fixedLengthBinary && payloadSize <= 0) {
      log(
        "SerialService ERROR [$portName]: fixedLengthBinary protocol requires a positive payloadSize.",
      );
      return false;
    }

    log(
      "SerialService: Attempting to open $portName ($protocol, $baudRate baud)...",
    );
    final port = SerialPort(portName);

    try {
      if (!port.open(mode: SerialPortMode.readWrite)) {
        log(
          "SerialService ERROR [$portName]: Failed to open. Error: ${SerialPort.lastError}",
        );
        return false;
      }

      // --- Configure Port ---
      final config = port.config;
      config.baudRate = baudRate;
      config.bits = 8;
      config.parity = SerialPortParity.none;
      config.stopBits = 1;
      port.config = config;

      // --- Store Protocol Info & Initialize Buffers ---
      _ports[portName] = port;
      _portProtocols[portName] = protocol;

      if (protocol == SerialProtocol.fixedLengthBinary) {
        _binaryPayloadSizes[portName] = payloadSize;
        _binaryBuffers[portName] = Uint8List(0); // Init empty binary buffer
      } else {
        _jsonBuffers[portName] = ""; // Init empty string buffer
      }

      // --- Start Reader Stream ---
      final reader = SerialPortReader(port);
      _subscriptions[portName] = reader.stream.listen(
        (data) {
          // Route data to the correct parser based on the port's protocol
          if (_portProtocols[portName] == SerialProtocol.fixedLengthBinary) {
            _onBinaryDataReceived(portName, data);
          } else {
            _onJsonDataReceived(portName, data);
          }
        },
        onError: (e) {
          log("SerialService ERROR [$portName]: $e");
          _cleanupPort(portName);
        },
        onDone: () {
          log("SerialService: Stream closed for $portName.");
          _cleanupPort(portName);
        },
      );

      log("SerialService: Successfully listening on $portName");
      return true;
    } catch (e, s) {
      log("SerialService EXCEPTION for $portName: $e");
      log("Stacktrace: $s");
      _cleanupPort(portName);
      return false;
    }
  }

  /// PARSER 1: Handles JSON data
  void _onJsonDataReceived(String portName, Uint8List data) {
    _jsonBuffers[portName] =
        (_jsonBuffers[portName] ?? "") + String.fromCharCodes(data);
    String buffer = _jsonBuffers[portName]!;

    while (true) {
      int startIndex = buffer.indexOf('{');
      if (startIndex == -1) break;
      int endIndex = buffer.indexOf('}', startIndex);
      if (endIndex == -1) break;

      final jsonString = buffer.substring(startIndex, endIndex + 1);
      buffer = buffer.substring(endIndex + 1);

      try {
        final Map<String, dynamic> jsonData = jsonDecode(jsonString);
        _dataStreamController.add(
          SerialDataPacket(
            portName: portName,
            protocol: SerialProtocol.json,
            data: jsonData,
          ),
        );
      } catch (e) {
        log('SerialService [$portName] JSON PARSE ERROR: $e');
      }
    }

    if (buffer.length > 4096) buffer = ""; // Safety clear
    _jsonBuffers[portName] = buffer;
  }

  /// PARSER 2: Handles fixed-length binary data
  void _onBinaryDataReceived(String portName, Uint8List data) {
    final int payloadSize = _binaryPayloadSizes[portName]!;
    Uint8List buffer = _binaryBuffers[portName]!;

    // 1. Append new data to the binary buffer
    buffer = Uint8List.fromList([...buffer, ...data]);

    // 2. Process all complete packets in the buffer
    while (buffer.length >= payloadSize) {
      // 3. Extract the packet
      final Uint8List packet = buffer.sublist(0, payloadSize);

      // 4. Trim the buffer
      buffer = buffer.sublist(payloadSize);

      // 5. Emit the raw binary packet
      _dataStreamController.add(
        SerialDataPacket(
          portName: portName,
          protocol: SerialProtocol.fixedLengthBinary,
          data: packet, // Emits the raw Uint8List
        ),
      );
    }

    // 6. Save the remaining incomplete data back to the buffer
    _binaryBuffers[portName] = buffer;
  }

  // --- Sending Methods ---

  /// Send a JSON object to a specific port
  void sendJsonTo(String portName, Map<String, dynamic> data) {
    final port = _ports[portName];
    if (port == null || !port.isOpen) {
      log("SerialService ERROR: Port $portName is not open.");
      return;
    }
    try {
      final jsonString = jsonEncode(data);
      port.write(Uint8List.fromList(jsonString.codeUnits));
    } catch (e) {
      log("SerialService [$portName] SEND JSON ERROR: $e");
    }
  }

  /// Send raw binary data (a Uint8List) to a specific port
  void sendBinaryTo(String portName, Uint8List data) {
    final port = _ports[portName];
    if (port == null || !port.isOpen) {
      log("SerialService ERROR: Port $portName is not open.");
      return;
    }
    try {
      port.write(data);
      log('SerialService [$portName] SENT: ${data.length} bytes');
    } catch (e) {
      log("SerialService [$portName] SEND BINARY ERROR: $e");
    }
  }

  /// Send JSON to ALL known ports
  void broadcastJson(Map<String, dynamic> data) {
    for (final portName in _ports.keys) {
      if (_portProtocols[portName] == SerialProtocol.json) {
        sendJsonTo(portName, data);
      }
    }
  }

  void stopListening(String portName) {
    if (_ports.containsKey(portName)) {
      log("SerialService: Stopping listener and cleaning up $portName...");
      _cleanupPort(portName);
    } else {
      log("SerialService: No active listener found for $portName to stop.");
    }
  }

  // --- Cleanup ---
  void _cleanupPort(String portName) {
    log("Cleaning up $portName...");
    _subscriptions[portName]?.cancel();
    _ports[portName]?.close();
    _ports[portName]?.dispose();
    _subscriptions.remove(portName);
    _ports.remove(portName);
    _jsonBuffers.remove(portName);
    _binaryBuffers.remove(portName);
    _portProtocols.remove(portName);
    _binaryPayloadSizes.remove(portName);
  }

  void dispose() {
    for (var portName in _ports.keys.toList()) {
      _cleanupPort(portName);
    }
    _dataStreamController.close();
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data'; // Required for Uint8List
import 'package:bits_n_bytes_ui/services/log_service.dart';
import 'package:flutter/material.dart';
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
    // This gives you a useful LogService.logEvent message when you print the object
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

  final Map<String, BytesBuilder> _binaryBuilders = {};

  final ValueNotifier<Map<String, dynamic>?> espState = ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?> jetsonState = ValueNotifier(null);
  final ValueNotifier<Uint8List?> nfcState = ValueNotifier(null);

  Future<bool> startListening(
    String portName, {
    int baudRate = 9600,
    SerialProtocol protocol = SerialProtocol.json,
    int payloadSize = 0, // REQUIRED for fixedLengthBinary
  }) async {
    if (_ports.containsKey(portName)) {
      LogService.logEvent("SerialService: Already listening on $portName");
      return true;
    }

    if (protocol == SerialProtocol.fixedLengthBinary && payloadSize <= 0) {
      LogService.logEvent(
        "SerialService ERROR [$portName]: fixedLengthBinary protocol requires a positive payloadSize.",
      );
      return false;
    }

    LogService.logEvent(
      "SerialService: Attempting to open $portName ($protocol, $baudRate baud)...",
    );
    final port = SerialPort(portName);

    try {
      if (!port.open(mode: SerialPortMode.readWrite)) {
        LogService.logEvent(
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
          // LogService.logEvent("DEBUG: Received ${data.length} bytes from $portName: ${String.fromCharCodes(data)}");
          // Route data to the correct parser based on the port's protocol
          if (_portProtocols[portName] == SerialProtocol.fixedLengthBinary) {
            _onBinaryDataReceived(portName, data);
          } else {
            _onJsonDataReceived(portName, data);
          }
        },
        onError: (e) {
          LogService.logEvent("SerialService ERROR [$portName]: $e");
          _cleanupPort(portName);
        },
        onDone: () {
          LogService.logEvent("SerialService: Stream closed for $portName.");
          _cleanupPort(portName);
        },
      );

      LogService.logEvent("SerialService: Successfully listening on $portName");
      return true;
    } catch (e, s) {
      LogService.logEvent("SerialService EXCEPTION for $portName: $e");
      LogService.logEvent("Stacktrace: $s");
      _cleanupPort(portName);
      return false;
    }
  }

  /// PARSER 1: Handles JSON data
String _accumulatedBuffer = "";

void _onJsonDataReceived(String portName, Uint8List data) {
  _accumulatedBuffer += String.fromCharCodes(data);

  // Use a while loop instead of recursion
  while (_accumulatedBuffer.contains('{')) {
    int startIdx = _accumulatedBuffer.indexOf('{');
    
    // Remove junk before the first '{'
    if (startIdx > 0) {
      _accumulatedBuffer = _accumulatedBuffer.substring(startIdx);
    }

    int braceCount = 0;
    int endIdx = -1;

    for (int i = 0; i < _accumulatedBuffer.length; i++) {
      if (_accumulatedBuffer[i] == '{') {
        braceCount++;
      } else if (_accumulatedBuffer[i] == '}') {
        braceCount--;
      }

      if (braceCount == 0 && i > 0) {
        endIdx = i;
        break;
      }
    }

    // If we haven't found a full object yet, break the while loop 
    // and wait for more data from the serial port.
    if (endIdx == -1) {
      // LogService.logEvent("STILL PARSING");
      break;
    } 

    String completeJson = _accumulatedBuffer.substring(0, endIdx + 1);
    _accumulatedBuffer = _accumulatedBuffer.substring(endIdx + 1);

    try {
      LogService.logEvent("JSON COMPLETE SENDING");
      final Map<String, dynamic> jsonData = jsonDecode(completeJson);

      if (portName == portESP) {
        // This updates the value and NOTIFIES all listeners automatically
        espState.value = jsonData;
        LogService.logEvent("onJsonDataReceived: ESP");
      } else if (portName == portJetson) {
        jetsonState.value = jsonData;
        // LogService.logEvent("onJsonDataReceived: JETSON");
      // } else if (portName == portNFC) { // NFC SHOULDNT BE CALLED HERE
      //   nfcState.value = jsonData;
      //   // LogService.logEvent("onJsonDataReceived: NFC");
      } else {
        LogService.logEvent("onJsonDataReceived: Unknown Port or NFC");
      }
    } catch (e) {
      LogService.logEvent("Json Parse Error on $portName: $e");
      // If it failed to decode, the buffer might be corrupted. 
      // You might want to clear it or handle it here.
    }
  }
}

  /// PARSER 2: Handles fixed-length binary data
  // Change your map definition:


  void _onBinaryDataReceived(String portName, Uint8List data) {
    final builder = _binaryBuilders.putIfAbsent(portName, () => BytesBuilder());
    builder.add(data);
    
    final int payloadSize = _binaryPayloadSizes[portName]!;
    
    // Create a temporary view to check length without clearing
    while (builder.length >= payloadSize) {
      final fullBuffer = builder.takeBytes(); // This clears the builder
      final packet = fullBuffer.sublist(0, payloadSize);
      final remainder = fullBuffer.sublist(payloadSize);
      
      // _dataStreamController.add(SerialDataPacket(portName: portName, protocol: SerialProtocol.json, data: packet));
      if (portName == portNFC) {
        nfcState.value = packet;
        LogService.logEvent("onBinaryDataReceived: NFC packet updated");
      } else {
        LogService.logEvent("onBinaryDataReceived: Not from NFC :skull:");
      }
      
      builder.add(remainder);
    }
  }

  // --- Sending Methods ---

  /// Send a JSON object to a specific port
  void sendJsonTo(String portName, Map<String, dynamic> data) {
    final port = _ports[portName];
    if (port == null || !port.isOpen) {
      LogService.logEvent("SerialService ERROR: Port $portName is not open.");
      return;
    }
    try {
      final jsonString = jsonEncode(data);
      port.write(Uint8List.fromList(jsonString.codeUnits));
    } catch (e) {
      LogService.logEvent("SerialService [$portName] SEND JSON ERROR: $e");
    }
  }

  /// Send raw binary data (a Uint8List) to a specific port
  void sendBinaryTo(String portName, Uint8List data) {
    final port = _ports[portName];
    if (port == null || !port.isOpen) {
      LogService.logEvent("SerialService ERROR: Port $portName is not open.");
      return;
    }
    try {
      port.write(data);
      LogService.logEvent('SerialService [$portName] SENT: ${data.length} bytes');
    } catch (e) {
      LogService.logEvent("SerialService [$portName] SEND BINARY ERROR: $e");
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
      LogService.logEvent("SerialService: Stopping listener and cleaning up $portName...");
      _cleanupPort(portName);
    } else {
      LogService.logEvent("SerialService: No active listener found for $portName to stop.");
    }
  }

  bool isListening(String portName) {
    return _ports.containsKey(portName);
  }

  // --- Cleanup ---
  void _cleanupPort(String portName) {
    LogService.logEvent("Cleaning up $portName...");
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
    espState.dispose();
    jetsonState.dispose();
    nfcState.dispose();
  }

  void openDoors() {
    LogService.logEvent("Sending door command...");
    sendJsonTo(portESP, {"doors": true,"hatch":false});
  }

  void openHatch() {
    LogService.logEvent("Sending hatch command...");
    sendJsonTo(portESP, {"hatch": true,"doors":false});
  }

  Future<void> hardResetPort(String portName, {int baudRate = 9600}) async {
    LogService.logEvent("SerialService: Hard resetting $portName...");

    // If we have an existing port object, try to close it explicitly
    final existingPort = _ports[portName];
    if (existingPort != null) {
      try {
        if (existingPort.isOpen) {
          existingPort.close();
        }
        existingPort.dispose();
      } catch (e) {
        LogService.logEvent("Error during pre-reset cleanup: $e");
      }
      _ports.remove(portName);
    }

    // Wait for the Linux Kernel to catch up (Crucial for Pi)
    await Future.delayed(const Duration(milliseconds: 800));

    // Re-attempt start
    await startListening(portName, baudRate: baudRate);
  }

  Future<bool> startListeningNFC() async {
    bool success = await startListening(
      SerialService.portNFC,
      protocol: SerialProtocol.fixedLengthBinary,
      payloadSize: 7,
    );

    if (success) {
      LogService.logEvent("NFC Listening: Success");
    } else {
      LogService.logEvent("NFC Listening: Failure");
    }

    return success;
  }

  Future<bool> startListeningJetson() async {
    bool success = await startListening(
      SerialService.portJetson,
      protocol: SerialProtocol.json,
    );

    if (success) {
      LogService.logEvent("Jetson Listening: Success");
    } else {
      LogService.logEvent("Jetson Listening: Failure");
    }

    return success;
  }

  Future<bool> startListeningESP() async {
    bool success = await startListening(
      SerialService.portESP,
      protocol: SerialProtocol.json,
    );

    if (success) {
      LogService.logEvent("ESP Listening: Success");
    } else {
      LogService.logEvent("ESP Listening: Failure");
    }

    return success;
  }

  Future<bool> startListeningAll() async {
    LogService.logEvent("UART-Service: StartListeningAll");
    // Start all of them simultaneously
    final results = await Future.wait([
      startListeningNFC(),
      startListeningESP(),
      startListeningJetson(),
    ]);

    // results is a List<bool> [nfcSuccess, espSuccess, jetsonSuccess]
    return results.every((success) => success);
  }
}

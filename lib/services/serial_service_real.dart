import 'dart:async';
import 'dart:convert';
import 'dart:typed_data'; // Required for Uint8List
import 'package:bits_n_bytes_ui/services/log_service.dart';
import 'package:bits_n_bytes_ui/services/serial_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';

class SerialServiceReal implements SerialService {
  // Maps to hold separate resources for each port
  final Map<String, SerialPort> _ports = {};
  final Map<String, StreamSubscription> _subscriptions = {};

  final Map<String, String> _jsonBuffers = {}; // For JSON string data
  final Map<String, Uint8List> _binaryBuffers = {}; // For raw binary data
  final Map<String, int> _binaryPayloadSizes = {}; // Stores PAYLOAD_SIZE for binary ports
  final Map<String, SerialProtocol> _portProtocols = {}; // Stores protocol for each port

  final Map<String, BytesBuilder> _binaryBuilders = {};

  @override
  final ValueNotifier<Map<String, dynamic>?> espState = ValueNotifier(null);
  @override
  final ValueNotifier<Map<String, dynamic>?> jetsonState = ValueNotifier(null);
  @override
  final ValueNotifier<Uint8List?> nfcState = ValueNotifier(null);

  @override
  Future<bool> startListening(
    String portName, {
    int baudRate = 9600,
    SerialProtocol protocol = SerialProtocol.json,
    int payloadSize = 0,
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
  ///
  /// Single forward scan over the buffer with a brace-depth counter. Complete
  /// `{...}` objects are decoded as they close; the buffer is sliced exactly
  /// once at the end to drop everything already consumed. This avoids the old
  /// O(n²) behaviour where every chunk did `+=` plus repeated `substring`
  /// rebuilds over a growing buffer on the UI isolate.
  void _onJsonDataReceived(String portName, Uint8List data) {
    // Append the new bytes to THIS port's buffer (one allocation per chunk).
    final String buffer =
        (_jsonBuffers[portName] ?? "") + String.fromCharCodes(data);

    int braceCount = 0;
    int objStart = -1; // index of the current object's opening brace
    int consumed = 0; // end (exclusive) of the last fully decoded object

    for (int i = 0; i < buffer.length; i++) {
      final int c = buffer.codeUnitAt(i);
      if (c == 0x7B) {
        // '{'
        if (braceCount == 0) objStart = i;
        braceCount++;
      } else if (c == 0x7D) {
        // '}'
        if (braceCount > 0) {
          braceCount--;
          if (braceCount == 0 && objStart != -1) {
            _dispatchJson(portName, buffer.substring(objStart, i + 1));
            consumed = i + 1;
            objStart = -1;
          }
        }
      }
    }

    // Keep only the unconsumed tail for the next chunk (single slice).
    _jsonBuffers[portName] = consumed > 0 ? buffer.substring(consumed) : buffer;
  }

  /// Decode one complete JSON object and route it to the matching state.
  void _dispatchJson(String portName, String completeJson) {
    try {
      final Map<String, dynamic> jsonData = jsonDecode(completeJson);

      if (portName == SerialService.portESP) {
        espState.value = jsonData;
      } else if (portName == SerialService.portJetson) {
        jetsonState.value = jsonData;
      } else {
        LogService.logEvent("Received JSON on unknown port: $portName");
      }
    } catch (e) {
      LogService.logEvent(
        "Json Parse Error on $portName: $e | Raw: $completeJson",
      );
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
      if (portName == SerialService.portNFC) {
        nfcState.value = packet;
        LogService.logEvent("onBinaryDataReceived: NFC packet updated [$packet]");
      } else {
        LogService.logEvent("onBinaryDataReceived: Not from NFC :skull:");
      }
      
      builder.add(remainder);
    }
  }

  // --- Sending Methods ---

  /// Send a JSON object to a specific port
  @override
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
  @override
  void sendBinaryTo(String portName, Uint8List data) {
    final port = _ports[portName];
    if (port == null || !port.isOpen) {
      LogService.logEvent("SerialService ERROR: Port $portName is not open.");
      return;
    }
    try {
      int bytesWritten = port.write(data);
      LogService.logEvent('SerialService [$portName] SENT: $bytesWritten bytes');
    } catch (e) {
      LogService.logEvent("SerialService [$portName] SEND BINARY ERROR: $e");
    }
  }

  /// Send JSON to ALL known ports
  @override
  void broadcastJson(Map<String, dynamic> data) {
    for (final portName in _ports.keys) {
      if (_portProtocols[portName] == SerialProtocol.json) {
        sendJsonTo(portName, data);
      }
    }
  }

  @override
  void stopListening(String portName) {
    if (_ports.containsKey(portName)) {
      LogService.logEvent("SerialService: Stopping listener and cleaning up $portName...");
      _cleanupPort(portName);
    } else {
      LogService.logEvent("SerialService: No active listener found for $portName to stop.");
    }
  }

  @override
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

  @override
  void dispose() {
    for (var portName in _ports.keys.toList()) {
      _cleanupPort(portName);
    }
    espState.dispose();
    jetsonState.dispose();
    nfcState.dispose();
  }

  @override
  void openDoors() {
    LogService.logEvent("Sending door command...");
    sendJsonTo(SerialService.portESP, {"doors": true,"hatch":false});
  }

  @override
  void openHatch() {
    LogService.logEvent("Sending hatch command...");
    sendJsonTo(SerialService.portESP, {"hatch": true,"doors":false});
  }

  @override
  void clearCart() {
    LogService.logEvent("Sending clear-cart command to Jetson...");
    sendBinaryTo(SerialService.portJetson, Uint8List.fromList([0xDE, 0xAD, 0xBE, 0xEF]));
  }

  @override
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

  @override
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

  @override
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

  @override
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

  @override
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

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:bits_n_bytes_ui/services/log_service.dart';
import 'package:bits_n_bytes_ui/services/serial_service.dart';
import 'package:flutter/material.dart' hide Router;

class SerialServiceSim with SerialStreams implements SerialService {
  SerialServiceSim() {
    bindStreams(); // derive typed streams from the notifiers (Phase 4B)
  }

  @override
  final ValueNotifier<Map<String, dynamic>?> espState = ValueNotifier(null);
  @override
  final ValueNotifier<Map<String, dynamic>?> jetsonState = ValueNotifier(null);
  @override
  final ValueNotifier<Uint8List?> nfcState = ValueNotifier(null);

  HttpServer? _server;

  @override
  Future<bool> startListeningAll() async {
    LogService.logEvent("UART-Service: Starting Simulator REST API...");
    
    final router = Router();

    // PUT /esp
    // {
    // 	"doors": true,
    // 	"hatch": true,
    // 	"temp_c": 56,
    // 	"intake_rpm": 1000,
    // 	"exhaust_rmp": 1000,
    // 	"shelf_ids": ["MAC_1", "MAC_2", "MAC_3"]
    // }
    router.put('/esp', (Request request) async {
      try {
        final content = await request.readAsString();
        final data = jsonDecode(content) as Map<String, dynamic>;
        espState.value = data;
        LogService.logEvent("Sim: ESP state updated via PUT");
        return Response.ok(jsonEncode({'status': 'success', 'received': data}));
      } catch (e) {
        return Response.internalServerError(body: 'JSON Parse Error: $e');
      }
    });

    // PUT /jetson
    router.put('/jetson', (Request request) async {
      try {
        final content = await request.readAsString();
        final data = jsonDecode(content) as Map<String, dynamic>;
        jetsonState.value = data;
        LogService.logEvent("Sim: Jetson state updated via PUT");
        return Response.ok(jsonEncode({'status': 'success', 'received': data}));
      } catch (e) {
        return Response.internalServerError(body: 'JSON Parse Error: $e');
      }
    });

    // NFC remains unimplemented as requested
    router.put('/nfc', (Request request) {
      return Response.notFound('NFC simulation not implemented yet');
    });

    try {
      // Binding to 0.0.0.0 allows access from other devices on the network
      _server = await io.serve(router, '0.0.0.0', 8080);
      LogService.logEvent("🚀 Sim Server running at http://${_server!.address.host}:${_server!.port}");
      return true;
    } catch (e) {
      LogService.logEvent("Sim Server failed to start: $e");
      return false;
    }
  }

  @override
  Future<bool> startListening(
    String portName, {
    int baudRate = 9600,
    SerialProtocol protocol = SerialProtocol.json,
    int payloadSize = 0,
  }) async => true;

  @override
  void sendJsonTo(String portName, Map<String, dynamic> data) {
    LogService.logEvent("SIM OUTBOUND [$portName]: ${jsonEncode(data)}");
  }

  @override
  void sendBinaryTo(String portName, Uint8List data) {
    LogService.logEvent("SIM OUTBOUND BINARY [$portName]: ${data.length} bytes");
  }

  @override
  void broadcastJson(Map<String, dynamic> data) {
    sendJsonTo("BROADCAST", data);
  }

  @override
  bool isListening(String portName) => _server != null;

  @override
  void stopListening(String portName) => LogService.logEvent("Sim: Stop listening $portName");

  @override
  void dispose() {
    _server?.close();
    espState.dispose();
    jetsonState.dispose();
    nfcState.dispose();
    disposeStreams();
  }

  // Helper logic for UI buttons
  @override
  void openDoors() => sendJsonTo(SerialService.portESP, {"doors": true, "hatch": false});

  @override
  void openHatch() => sendJsonTo(SerialService.portESP, {"hatch": true, "doors": false});

  @override
  void clearCart() => LogService.logEvent("SIM: clearCart -> [0xDE, 0xAD, 0xBE, 0xEF] to Jetson");

  @override
  Future<void> hardResetPort(String portName, {int baudRate = 9600}) async {
    LogService.logEvent("Sim: Hard reset triggered for $portName");
  }

  // These are kept to satisfy the interface, though startListeningAll handles the server
  @override
  Future<bool> startListeningNFC() async => true;
  @override
  Future<bool> startListeningJetson() async => true;
  @override
  Future<bool> startListeningESP() async => true;
}
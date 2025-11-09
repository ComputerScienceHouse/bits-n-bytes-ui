import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data'; // Required for Uint8List
import 'package:flutter_libserialport/flutter_libserialport.dart';

class SerialService {
  // This makes it a singleton
  static final SerialService _instance = SerialService._internal();
  factory SerialService() => _instance;
  SerialService._internal();

  SerialPort? _port;
  StreamSubscription? _serialSubscription;

  // Buffer for incoming data
  String _buffer = "";

  // Completer to fix the race condition
  final Completer<void> _readyCompleter = Completer<void>();
  Future<void> get isReady => _readyCompleter.future;

  final _dataStreamController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get dataStream => _dataStreamController.stream;

  void startListening() async {
    if (_port != null) return; // Already started

    // 1. Get a list of available ports
    final portNames = SerialPort.availablePorts;
    if (portNames.isEmpty) {
      log("SerialService ERROR: No serial ports found.");
      return;
    }
    log("SerialService: Available ports: $portNames");

    final portName = "/dev/ttyAMA0";
    _port = SerialPort(portName);

    try {
      // 3. Open the port
      if (!_port!.open(mode: SerialPortMode.readWrite)) {
        log("SerialService ERROR: Failed to open port $portName.");
        log("Error: ${SerialPort.lastError}");
        return;
      }

      // 4. Configure the port
      final config = _port!.config;
      config.baudRate = 9600; // <-- Set your baud rate
      config.bits = 8;
      config.parity = SerialPortParity.none;
      config.stopBits = 1;
      _port!.config = config;
      // 5. Send a "hello" message
      _port!.write(Uint8List.fromList("Hello from Flutter!\n".codeUnits));

      // 6. Listen to the data stream!
      // Create a SerialPortReader to get a Stream
      final reader = SerialPortReader(_port!);
      _serialSubscription = reader.stream.listen(_onDataReceived);

      log("SerialService: Started listening on $portName...");

      // 7. Signal that the service is ready
      if (!_readyCompleter.isCompleted) {
        _readyCompleter.complete();
      }
    } catch (e, s) {
      log("SerialService ERROR: $e");
      log("Stacktrace: $s");
      if (e is SerialPortError) {
        log("SerialPortError: ${SerialPort.lastError}");
      }
    }
  }

  /// This function is called every time new data arrives
  void _onDataReceived(Uint8List data) {
    // Add the new data to our buffer
    _buffer += String.fromCharCodes(data);

    // Keep checking the buffer for complete JSON objects
    while (true) {
      // Find the start and end of a JSON object
      int startIndex = _buffer.indexOf('{');
      // If we don't have a complete { ... } object, wait for more data.
      if (startIndex == -1) {
        break;
      }   
      
      int endIndex = _buffer.indexOf('}', startIndex);

      if (endIndex == -1) {
        break;
      }

      // Extract the complete JSON string
      final jsonString = _buffer.substring(startIndex, endIndex + 1);

      // Remove this object from the buffer
      _buffer = _buffer.substring(endIndex + 1);

      // Try to parse it
      try {
        final Map<String, dynamic> jsonData = jsonDecode(jsonString);
        // Success! Send the parsed data to the UI
        log('SerialService: Parsed and sending: $jsonData');
        _dataStreamController.add(jsonData);
      } catch (e) {
        log('SERIAL PARSE ERROR: $e');
        log('BAD DATA: "$jsonString"');
        _dataStreamController.addError({'error': 'Invalid JSON'});
      }
    }
    
    // Safety check: prevent the buffer from growing forever if data is bad
    if (_buffer.length > 2048) {
      log("SerialService: Clearing large buffer.");
      _buffer = "";
    }
  }

  /// Public method to send data (called from UI)
  void sendJson(Map<String, dynamic> data) async {
    // Wait for the port to be open and ready
    await isReady;

    if (_port == null || !_port!.isOpen) {
      log("SerialService ERROR: Port is not open to send data.");
      return;
    }
    try {
      final jsonString = jsonEncode(data);
      log('SerialService: Sending JSON: $jsonString');
      // Convert string to bytes and write to port
      _port!.write(Uint8List.fromList(jsonString.codeUnits));
    } catch (e) {
      log("SerialService ERROR: Could not encode/send JSON: $e");
    }
  }

  void dispose() {
    log("SerialService: Stopping...");
    _serialSubscription?.cancel();
    _port?.close();
    _port?.dispose();
    _dataStreamController.close();
  }
}
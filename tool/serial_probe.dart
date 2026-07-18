// Standalone serial probe — opens a REAL port with the same stack the app uses
// (package:libserialport + SerialPortReader) and dumps everything it receives.
// This isolates the app's software path from the hardware.
//
// Run on the Pi (uses the system libserialport.so, same as the app):
//
//   dart run tool/serial_probe.dart                       # list ports + usage
//   dart run tool/serial_probe.dart /dev/ttyAMA0          # CONTROL: ESP (known-good)
//   dart run tool/serial_probe.dart /dev/ttyAMA3 ff,00,00,00,00,00,00,00
//                                                         # NFC: arm, then listen
//
// arg1 = port, arg2 = optional comma-separated HEX bytes to send after opening
// (e.g. the NFC arm command), arg3 = optional baud (default 9600).

import 'dart:async';
import 'dart:typed_data';

import 'package:libserialport/libserialport.dart';

String _hex(List<int> b) =>
    b.map((x) => x.toRadixString(16).padLeft(2, '0')).join(' ');
String _ascii(List<int> b) => b
    .map((x) => (x >= 0x20 && x < 0x7f) ? String.fromCharCode(x) : '.')
    .join();

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    print('Available ports: ${SerialPort.availablePorts}');
    print('usage: dart run tool/serial_probe.dart <port> [armHexCsv] [baud]');
    return;
  }

  final portName = args[0];
  final baud = args.length > 2 ? int.parse(args[2]) : 9600;

  print('Opening $portName @ $baud 8N1 ...');
  final port = SerialPort(portName);
  if (!port.open(mode: SerialPortMode.readWrite)) {
    print('FAILED to open $portName: ${SerialPort.lastError}');
    return;
  }

  final cfg = port.config;
  cfg.baudRate = baud;
  cfg.bits = 8;
  cfg.parity = SerialPortParity.none;
  cfg.stopBits = 1;
  port.config = cfg;
  print('Opened OK.');

  // Optional: send an arm/init command (e.g. the NFC ff,00,... sequence).
  if (args.length > 1 && args[1].trim().isNotEmpty) {
    final bytes = Uint8List.fromList(
      args[1].split(',').map((s) => int.parse(s.trim(), radix: 16)).toList(),
    );
    final n = port.write(bytes);
    print('TX ${n}B: ${_hex(bytes)}');
  }

  var total = 0;
  final reader = SerialPortReader(port);
  final sub = reader.stream.listen(
    (data) {
      total += data.length;
      print('RX ${data.length}B  hex: ${_hex(data)}  ascii: ${_ascii(data)}');
    },
    onError: (e) => print('RX ERROR: $e'),
  );

  print('Listening 20s — trigger the device / tap a card now ...');
  await Future.delayed(const Duration(seconds: 20));

  await sub.cancel();
  port.close();
  port.dispose();
  print('Done. Total received: $total bytes.');
}

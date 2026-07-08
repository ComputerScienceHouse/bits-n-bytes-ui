import 'dart:typed_data';

import 'package:bits_n_bytes_ui/services/serial_service_sim.dart';
import 'package:flutter_test/flutter_test.dart';

/// Phase 4B dual-API parity: the typed streams must carry the same information
/// as the raw notifiers they're derived from. Uses SerialServiceSim directly
/// (construction just wires the notifier→stream derivation; no server).
void main() {
  test('espStream emits the EspState equivalent of espState.value', () async {
    final sim = SerialServiceSim();
    final emitted = <bool>[];
    final sub = sim.espStream.listen((e) => emitted.add(e.doorsClosed));

    sim.espState.value = {'doors': true, 'temp_c': 42};
    await Future.delayed(Duration.zero);

    // Notifier holds the raw map; stream + latest carry the typed equivalent.
    expect(sim.espState.value, {'doors': true, 'temp_c': 42});
    expect(emitted, [true]);
    expect(sim.latestEsp?.doorsClosed, true);
    expect(sim.latestEsp?.tempC, 42);

    await sub.cancel();
  });

  test('cartStream emits the CartDelta equivalent of jetsonState.value', () async {
    final sim = SerialServiceSim();
    final emitted = <int>[];
    final sub = sim.cartStream.listen((d) => emitted.add(d.quantity));

    sim.jetsonState.value = {'id': 7, 'quantity': 3};
    await Future.delayed(Duration.zero);

    expect(sim.jetsonState.value, {'id': 7, 'quantity': 3});
    expect(emitted, [3]);
    expect(sim.latestCart?.id, 7);
    expect(sim.latestCart?.quantity, 3);

    await sub.cancel();
  });

  test('nfcStream emits the NfcScan equivalent of nfcState.value', () async {
    final sim = SerialServiceSim();
    final emitted = <int>[];
    final sub = sim.nfcStream.listen((s) => emitted.add(s.uuid));

    final packet = Uint8List(4)..buffer.asByteData().setUint32(0, 12345);
    sim.nfcState.value = packet;
    await Future.delayed(Duration.zero);

    expect(sim.nfcState.value, packet);
    expect(emitted, [12345]);
    expect(sim.latestNfc?.uuid, 12345);

    await sub.cancel();
  });

  test('a malformed cart map updates the notifier but emits no typed event',
      () async {
    final sim = SerialServiceSim();
    final emitted = <int>[];
    final sub = sim.cartStream.listen((d) => emitted.add(d.quantity));

    sim.jetsonState.value = {'unexpected': 'shape'}; // not a CartDelta
    await Future.delayed(Duration.zero);

    expect(sim.jetsonState.value, {'unexpected': 'shape'}); // notifier still set
    expect(emitted, isEmpty); // no typed event
    expect(sim.latestCart, isNull);

    await sub.cancel();
  });
}

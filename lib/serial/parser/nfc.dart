import 'dart:typed_data';

/// Reassembles a raw byte stream into fixed-size binary packets — the NFC
/// reader's framing. One instance per port; buffers a partial tail between
/// chunks. Pure (no I/O, no notifiers) so it is unit-testable.
class NfcFramer {
  NfcFramer(this.payloadSize) : assert(payloadSize > 0);

  final int payloadSize;
  final BytesBuilder _builder = BytesBuilder();

  /// Appends [data] and returns every complete [payloadSize]-byte packet now
  /// available (zero, one, or many). A partial tail is retained.
  List<Uint8List> addChunk(Uint8List data) {
    _builder.add(data);

    final packets = <Uint8List>[];
    while (_builder.length >= payloadSize) {
      final full = _builder.takeBytes(); // drains the builder
      packets.add(full.sublist(0, payloadSize));
      _builder.add(full.sublist(payloadSize)); // put the remainder back
    }
    return packets;
  }
}

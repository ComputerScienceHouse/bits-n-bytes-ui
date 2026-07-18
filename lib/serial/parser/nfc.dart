import 'dart:typed_data';

/// Reassembles a raw byte stream into fixed-size binary packets — the NFC
/// reader's framing. One instance per port; buffers a partial tail between
/// chunks. Pure (no I/O, no notifiers) so it is unit-testable.
///
/// The raw stream has no delimiter, so a single stray byte (an echoed command,
/// line noise, a split read) would permanently misalign a blind fixed-size
/// slicer — and then every UID decodes to garbage. When [syncByte] is set, the
/// framer discards leading bytes until the buffer starts with it, re-aligning
/// to the true packet boundary. NXP card UIDs always begin with 0x04, so that
/// is the sync marker for the NFC reader.
class NfcFramer {
  NfcFramer(this.payloadSize, {this.syncByte}) : assert(payloadSize > 0);

  final int payloadSize;
  final int? syncByte;
  final BytesBuilder _builder = BytesBuilder();

  /// Appends [data] and returns every complete [payloadSize]-byte packet now
  /// available (zero, one, or many). A partial tail is retained.
  List<Uint8List> addChunk(Uint8List data) {
    _builder.add(data);
    var buf = _builder.takeBytes(); // drain; the remainder is re-added below

    final packets = <Uint8List>[];
    while (true) {
      // Re-sync: drop anything before the packet-start marker so an echoed
      // command / noise byte can't shift every subsequent frame.
      if (syncByte != null) {
        var start = 0;
        while (start < buf.length && buf[start] != syncByte) {
          start++;
        }
        if (start > 0) buf = buf.sublist(start);
      }

      if (buf.length < payloadSize) break;
      packets.add(buf.sublist(0, payloadSize));
      buf = buf.sublist(payloadSize);
    }

    _builder.add(buf); // retain partial tail for the next chunk
    return packets;
  }

  /// Discards any half-assembled bytes. Call when (re)arming the reader so a
  /// fresh command/response cycle starts from a clean, aligned buffer instead
  /// of inheriting stray bytes (echoed commands, noise) from before.
  void reset() => _builder.clear();
}

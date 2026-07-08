import 'dart:typed_data';

/// A single NFC card tap.
///
/// The reader emits a fixed-length binary packet (not JSON); the first 4 bytes
/// are a big-endian uint32 card id. This matches the decode the welcome flow
/// does today and the packet the sim writes to `nfcState`.
class NfcScan {
  final int uuid;

  const NfcScan(this.uuid);

  factory NfcScan.fromBytes(Uint8List bytes) {
    if (bytes.length < 4) {
      throw const FormatException('NFC packet too short (need >= 4 bytes)');
    }
    final data = ByteData.view(
      bytes.buffer,
      bytes.offsetInBytes,
      bytes.lengthInBytes,
    );
    return NfcScan(data.getUint32(0)); // big-endian
  }
}

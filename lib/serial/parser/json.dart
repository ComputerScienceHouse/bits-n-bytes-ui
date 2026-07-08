import 'dart:typed_data';

/// Splits a raw serial byte stream into complete top-level `{...}` JSON frames.
///
/// One instance per port; it holds the unconsumed tail between chunks. Pure —
/// no I/O, no `jsonDecode`, no notifiers — so the framing is unit-testable.
/// This is the single forward brace-depth scan lifted out of `SerialServiceReal`
/// (it avoids the old O(n²) `+=`/`substring` rebuild on the UI isolate).
class JsonFrameParser {
  String _buffer = '';

  /// Appends [data] and returns every complete `{...}` object that closed in
  /// this chunk (zero, one, or many). An incomplete tail is retained for next
  /// time; bytes before the first brace are dropped once an object completes.
  List<String> addChunk(Uint8List data) {
    _buffer += String.fromCharCodes(data);

    final frames = <String>[];
    int braceCount = 0;
    int objStart = -1; // opening brace of the current object
    int consumed = 0; // end (exclusive) of the last completed object

    for (int i = 0; i < _buffer.length; i++) {
      final c = _buffer.codeUnitAt(i);
      if (c == 0x7B) {
        // '{'
        if (braceCount == 0) objStart = i;
        braceCount++;
      } else if (c == 0x7D) {
        // '}'
        if (braceCount > 0) {
          braceCount--;
          if (braceCount == 0 && objStart != -1) {
            frames.add(_buffer.substring(objStart, i + 1));
            consumed = i + 1;
            objStart = -1;
          }
        }
      }
    }

    // Keep only the unconsumed tail for the next chunk (single slice).
    if (consumed > 0) _buffer = _buffer.substring(consumed);
    return frames;
  }
}

import 'dart:typed_data';

import 'package:bits_n_bytes_ui/serial/parser/nfc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('emits a complete fixed-size packet', () {
    final out = NfcFramer(4).addChunk(Uint8List.fromList([1, 2, 3, 4]));
    expect(out.single, [1, 2, 3, 4]);
  });

  test('reassembles a packet split across chunks', () {
    final f = NfcFramer(4);
    expect(f.addChunk(Uint8List.fromList([1, 2])), isEmpty);
    expect(f.addChunk(Uint8List.fromList([3, 4])).single, [1, 2, 3, 4]);
  });

  test('emits multiple packets and retains the partial tail', () {
    final f = NfcFramer(4);
    final out = f.addChunk(Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8, 9]));
    expect(out.length, 2);
    expect(out[0], [1, 2, 3, 4]);
    expect(out[1], [5, 6, 7, 8]);
    // the trailing 9 is retained and completes with the next chunk
    expect(f.addChunk(Uint8List.fromList([10, 11, 12])).single, [9, 10, 11, 12]);
  });
}

import 'dart:typed_data';

import 'package:bits_n_bytes_ui/serial/parser/json.dart';
import 'package:flutter_test/flutter_test.dart';

Uint8List b(String s) => Uint8List.fromList(s.codeUnits);

void main() {
  test('emits a complete object in a single chunk', () {
    expect(JsonFrameParser().addChunk(b('{"a":1}')), ['{"a":1}']);
  });

  test('reassembles an object split across chunks', () {
    final p = JsonFrameParser();
    expect(p.addChunk(b('{"a":')), isEmpty);
    expect(p.addChunk(b('1}')), ['{"a":1}']);
  });

  test('emits multiple back-to-back objects in one chunk', () {
    expect(
      JsonFrameParser().addChunk(b('{"a":1}{"b":2}')),
      ['{"a":1}', '{"b":2}'],
    );
  });

  test('drops leading garbage before the first brace once an object closes', () {
    final p = JsonFrameParser();
    expect(p.addChunk(b('garbage{"a":1}')), ['{"a":1}']);
    expect(p.addChunk(b('{"b":2}')), ['{"b":2}']); // buffer is clean afterwards
  });

  test('respects brace depth for nested objects', () {
    expect(
      JsonFrameParser().addChunk(b('{"a":{"b":1}}')),
      ['{"a":{"b":1}}'],
    );
  });

  test('emits one whole object and retains a following partial', () {
    final p = JsonFrameParser();
    expect(p.addChunk(b('{"a":1}{"b":')), ['{"a":1}']);
    expect(p.addChunk(b('2}')), ['{"b":2}']);
  });
}

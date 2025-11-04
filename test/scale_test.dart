import 'package:flutter_test/flutter_test.dart';
import 'package:katya_ai_rechain_mesh/src/crypto/scale.dart';

void main() {
  test('SCALE compact int encodes small value', () {
    final out = Scale.encodeCompactInt(42);
    expect(out.isNotEmpty, true);
  });

  test('SCALE bytes prefix with length', () {
    final out = Scale.encodeBytes([1, 2, 3]);
    expect(out.length >= 4, true);
  });
}

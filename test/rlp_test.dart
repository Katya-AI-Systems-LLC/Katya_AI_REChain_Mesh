import 'package:flutter_test/flutter_test.dart';
import 'package:katya_ai_rechain_mesh/src/crypto/rlp.dart';

void main() {
  test('RLP encodes small int list', () {
    final out = Rlp.encode([1, 2, 3]);
    expect(out.isNotEmpty, true);
    // Not asserting exact bytes; smoke test only
  });
}

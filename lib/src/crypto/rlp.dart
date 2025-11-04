/// Minimal RLP encode for common EVM cases (strings, bytes, ints, lists).
class Rlp {
  static List<int> encode(dynamic value) {
    if (value is List<int>) return _encodeBytes(value);
    if (value is String) return _encodeBytes(_utf8(value));
    if (value is int) return _encodeBytes(_intToBytes(value));
    if (value is List) return _encodeList(value);
    throw ArgumentError('Unsupported RLP type: ${value.runtimeType}');
  }

  static List<int> _encodeBytes(List<int> input) {
    final len = input.length;
    if (len == 1 && input[0] < 0x80) return input;
    if (len <= 55) return [0x80 + len] + input;
    final lenBytes = _intToBytes(len);
    return [0xb7 + lenBytes.length] + lenBytes + input;
  }

  static List<int> _encodeList(List<dynamic> list) {
    final payload = <int>[];
    for (final v in list) {
      payload.addAll(encode(v));
    }
    final len = payload.length;
    if (len <= 55) return [0xc0 + len] + payload;
    final lenBytes = _intToBytes(len);
    return [0xf7 + lenBytes.length] + lenBytes + payload;
  }

  static List<int> _intToBytes(int value) {
    if (value == 0) return <int>[];
    final bytes = <int>[];
    var v = value;
    while (v > 0) {
      bytes.insert(0, v & 0xff);
      v >>= 8;
    }
    return bytes;
  }

  static List<int> _utf8(String s) => s.codeUnits;
}

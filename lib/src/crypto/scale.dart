/// Minimal SCALE codec stubs: compact ints and byte arrays
class Scale {
  static List<int> encodeCompactInt(int value) {
    if (value < 1 << 6) {
      return [(value << 2)];
    } else if (value < 1 << 14) {
      final v = (value << 2) | 0x01;
      return [v & 0xff, (v >> 8) & 0xff];
    } else {
      // Fallback: 4-byte mode
      final bytes = _u32(value);
      return [0x03] + bytes;
    }
  }

  static List<int> encodeBytes(List<int> bytes) {
    return encodeCompactInt(bytes.length) + bytes;
  }

  static List<int> _u32(int v) =>
      [v & 0xff, (v >> 8) & 0xff, (v >> 16) & 0xff, (v >> 24) & 0xff];
}

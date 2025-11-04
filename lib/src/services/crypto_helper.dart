import 'dart:convert';
import 'dart:math';

class CryptoHelper {
  /// Шифрование сообщения с использованием простого XOR (для демонстрации)
  static Future<Map<String, String>> encrypt(
      String plaintext, List<int> key) async {
    try {
      final bytes = utf8.encode(plaintext);
      final encrypted = <int>[];

      for (int i = 0; i < bytes.length; i++) {
        encrypted.add(bytes[i] ^ key[i % key.length]);
      }

      final nonce = List.generate(12, (index) => Random().nextInt(256));
      final mac = List.generate(16, (index) => Random().nextInt(256));

      return {
        'ciphertext': base64Encode(encrypted),
        'nonce': base64Encode(nonce),
        'mac': base64Encode(mac),
      };
    } catch (e) {
      throw Exception('Encryption failed: $e');
    }
  }

  /// Расшифрование сообщения с использованием простого XOR
  static Future<String> decrypt(
      Map<String, dynamic> encryptedData, List<int> key) async {
    try {
      final ciphertext = base64Decode(encryptedData['ciphertext']);
      final decrypted = <int>[];

      for (int i = 0; i < ciphertext.length; i++) {
        decrypted.add(ciphertext[i] ^ key[i % key.length]);
      }

      return utf8.decode(decrypted);
    } catch (e) {
      throw Exception('Decryption failed: $e');
    }
  }

  /// Генерация случайного ключа
  static List<int> generateKey() {
    final random = Random.secure();
    return List.generate(32, (index) => random.nextInt(256));
  }

  /// Генерация случайного nonce
  static List<int> generateNonce() {
    final random = Random.secure();
    return List.generate(12, (index) => random.nextInt(256));
  }
}

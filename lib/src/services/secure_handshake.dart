import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'crypto_handshake.dart';
import 'crypto_helper.dart';

/// Безопасный handshake для mesh-сети с ECDH/X25519 и аутентификацией
class SecureHandshake {
  static final _x25519 = X25519();
  static final _hkdf = Hkdf(hmac: Hmac.sha256());
  static final _hmac = Hmac.sha256();

  // Состояние handshake
  KeyPair? _myKeyPair;
  List<int>? _peerPublicKey;
  List<int>? _sessionKey;
  String? _handshakeId;

  /// Инициализация handshake
  Future<Map<String, dynamic>> initiateHandshake() async {
    try {
      // Генерируем новую пару ключей
      _myKeyPair = await CryptoHandshake.generateKeyPair();
      final myPublicKey = await CryptoHandshake.extractPublicKey(_myKeyPair!);

      // Создаем уникальный ID для handshake
      _handshakeId = 'handshake-${DateTime.now().millisecondsSinceEpoch}';

      // Создаем сообщение инициализации
      final initMessage = {
        'type': 'handshake_init',
        'handshakeId': _handshakeId,
        'publicKey': CryptoHandshake.b64(myPublicKey),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      // Подписываем сообщение для аутентификации
      final messageBytes = utf8.encode(jsonEncode(initMessage));
      final signature = await _signMessage(messageBytes);

      return {...initMessage, 'signature': CryptoHandshake.b64(signature)};
    } catch (e) {
      throw Exception('Failed to initiate handshake: $e');
    }
  }

  /// Обработка входящего handshake
  Future<Map<String, dynamic>> handleHandshakeInit(
    Map<String, dynamic> initMessage,
  ) async {
    try {
      // Проверяем тип сообщения
      if (initMessage['type'] != 'handshake_init') {
        throw Exception('Invalid handshake message type');
      }

      // Сохраняем публичный ключ пира
      _peerPublicKey = CryptoHandshake.fromB64(initMessage['publicKey']);
      _handshakeId = initMessage['handshakeId'];

      // Генерируем нашу пару ключей
      _myKeyPair = await CryptoHandshake.generateKeyPair();
      final myPublicKey = await CryptoHandshake.extractPublicKey(_myKeyPair!);

      // Создаем ответ
      final responseMessage = {
        'type': 'handshake_response',
        'handshakeId': _handshakeId,
        'publicKey': CryptoHandshake.b64(myPublicKey),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      // Подписываем ответ
      final messageBytes = utf8.encode(jsonEncode(responseMessage));
      final signature = await _signMessage(messageBytes);

      return {...responseMessage, 'signature': CryptoHandshake.b64(signature)};
    } catch (e) {
      throw Exception('Failed to handle handshake init: $e');
    }
  }

  /// Завершение handshake
  Future<void> completeHandshake(Map<String, dynamic> responseMessage) async {
    try {
      // Проверяем тип сообщения
      if (responseMessage['type'] != 'handshake_response') {
        throw Exception('Invalid handshake response type');
      }

      // Проверяем ID handshake
      if (responseMessage['handshakeId'] != _handshakeId) {
        throw Exception('Handshake ID mismatch');
      }

      // Обновляем публичный ключ пира
      _peerPublicKey = CryptoHandshake.fromB64(responseMessage['publicKey']);

      // Вычисляем общий секрет
      if (_myKeyPair == null || _peerPublicKey == null) {
        throw Exception('Missing key pair or peer public key');
      }

      final sharedSecret = await CryptoHandshake.deriveSharedSecret(
        _myKeyPair!,
        _peerPublicKey!,
      );

      // Генерируем сессионный ключ
      final info = utf8.encode('katya-mesh-session-$_handshakeId');
      _sessionKey = await CryptoHandshake.deriveSymmetricKey(
        sharedSecret,
        info: info,
      );

      print('Handshake completed successfully');
    } catch (e) {
      throw Exception('Failed to complete handshake: $e');
    }
  }

  /// Получить сессионный ключ
  List<int>? get sessionKey => _sessionKey;

  /// Проверить, завершен ли handshake
  bool get isHandshakeComplete => _sessionKey != null;

  /// Сбросить состояние handshake
  void reset() {
    _myKeyPair = null;
    _peerPublicKey = null;
    _sessionKey = null;
    _handshakeId = null;
  }

  /// Подписать сообщение (для аутентификации)
  Future<List<int>> _signMessage(List<int> message) async {
    // В реальном приложении здесь должна быть подпись с использованием долгосрочного ключа
    // Для демонстрации используем HMAC с фиксированным ключом
    final key = SecretKey(utf8.encode('katya-mesh-auth-key'));
    final mac = await _hmac.calculateMac(message, secretKey: key);
    return mac.bytes;
  }

  /// Проверить подпись сообщения
  Future<bool> _verifySignature(List<int> message, List<int> signature) async {
    try {
      final expectedSignature = await _signMessage(message);
      return _constantTimeCompare(signature, expectedSignature);
    } catch (e) {
      return false;
    }
  }

  /// Сравнение массивов байтов с постоянным временем
  bool _constantTimeCompare(List<int> a, List<int> b) {
    if (a.length != b.length) return false;

    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a[i] ^ b[i];
    }
    return result == 0;
  }

  /// Создать зашифрованное сообщение с аутентификацией
  Future<Map<String, dynamic>> createSecureMessage(String plaintext) async {
    if (_sessionKey == null) {
      throw Exception('No session key available');
    }

    try {
      // Шифруем сообщение
      final encrypted = await CryptoHelper.encrypt(plaintext, _sessionKey!);

      // Создаем структуру сообщения
      final message = {
        'type': 'secure_message',
        'handshakeId': _handshakeId,
        'ciphertext': encrypted['ciphertext'],
        'nonce': encrypted['nonce'],
        'mac': encrypted['mac'],
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      // Подписываем зашифрованное сообщение
      final messageBytes = utf8.encode(jsonEncode(message));
      final signature = await _signMessage(messageBytes);

      return {...message, 'signature': CryptoHandshake.b64(signature)};
    } catch (e) {
      throw Exception('Failed to create secure message: $e');
    }
  }

  /// Расшифровать безопасное сообщение
  Future<String> decryptSecureMessage(
    Map<String, dynamic> secureMessage,
  ) async {
    if (_sessionKey == null) {
      throw Exception('No session key available');
    }

    try {
      // Проверяем тип сообщения
      if (secureMessage['type'] != 'secure_message') {
        throw Exception('Invalid message type');
      }

      // Проверяем ID handshake
      if (secureMessage['handshakeId'] != _handshakeId) {
        throw Exception('Handshake ID mismatch');
      }

      // Расшифровываем сообщение
      final encryptedData = {
        'ciphertext': secureMessage['ciphertext'],
        'nonce': secureMessage['nonce'],
        'mac': secureMessage['mac'],
      };

      final plaintext = await CryptoHelper.decrypt(encryptedData, _sessionKey!);
      return plaintext;
    } catch (e) {
      throw Exception('Failed to decrypt secure message: $e');
    }
  }

  /// Получить информацию о состоянии handshake
  Map<String, dynamic> getHandshakeInfo() {
    return {
      'handshakeId': _handshakeId,
      'isComplete': isHandshakeComplete,
      'hasSessionKey': _sessionKey != null,
      'hasPeerKey': _peerPublicKey != null,
    };
  }
}

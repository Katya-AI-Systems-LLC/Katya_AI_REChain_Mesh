import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Мост для работы с нативным кодом платформ
class NativeBridge {
  static const MethodChannel _channel = MethodChannel(
    'com.katya.rechain.mesh/native',
  );

  /// Получить информацию об устройстве
  static Future<Map<String, dynamic>> getDeviceInfo() async {
    // Для веб-платформы сразу возвращаем информацию без platform channel
    if (kIsWeb) {
      return _getWebDeviceInfo();
    }

    try {
      // Для мобильных и десктопных платформ пытаемся использовать platform channel
      final result = await _channel.invokeMethod('getDeviceInfo');
      return Map<String, dynamic>.from(result);
    } catch (e) {
      print('Error getting device info: $e');
      return _getDefaultDeviceInfo();
    }
  }

  /// Получить информацию об устройстве для веб-платформы
  static Map<String, dynamic> _getWebDeviceInfo() {
    // Простая синхронная реализация для веб
    return {
      'platform': 'web',
      'deviceName': 'Web Browser',
      'userAgent': _getUserAgentSync(),
      'isMobile': _isMobileDeviceSync(),
      'isTablet': _isTabletDeviceSync(),
      'isDesktop': _isDesktopDeviceSync(),
      'isBluetoothSupported': false, // Web Bluetooth API не всегда доступен
      'isBluetoothLESupported': false,
      'isCameraSupported': false, // Требует пользовательского разрешения
      'isMicrophoneSupported': false, // Требует пользовательского разрешения
      'screenWidth': 1920, // Дефолтные значения
      'screenHeight': 1080,
      'pixelRatio': 1.0,
    };
  }

  /// Дефолтная информация об устройстве
  static Map<String, dynamic> _getDefaultDeviceInfo() {
    return {
      'platform': 'unknown',
      'deviceName': 'Unknown Device',
      'isBluetoothSupported': false,
      'isBluetoothLESupported': false,
      'isCameraSupported': false,
      'isMicrophoneSupported': false,
    };
  }

  /// Синхронные методы для веб
  static String _getUserAgentSync() {
    if (kIsWeb) {
      return ''; // В веб окружении user agent можно получить только через JS
    }
    return 'Unknown';
  }

  static bool _isMobileDeviceSync() {
    if (kIsWeb) {
      return false; // Определяется через user agent в JS
    }
    return false;
  }

  static bool _isTabletDeviceSync() {
    if (kIsWeb) {
      return false;
    }
    return false;
  }

  static bool _isDesktopDeviceSync() {
    if (kIsWeb) {
      return true; // Дефолт для веб
    }
    return true;
  }

  /// Запустить mesh-сервис
  static Future<bool> startMeshService() async {
    if (kIsWeb) {
      print('Mesh service not available on web platform');
      return false;
    }

    try {
      final result = await _channel.invokeMethod('startMeshService');
      return result ?? false;
    } catch (e) {
      print('Error starting mesh service: $e');
      return false;
    }
  }

  /// Остановить mesh-сервис
  static Future<bool> stopMeshService() async {
    if (kIsWeb) {
      print('Mesh service not available on web platform');
      return false;
    }

    try {
      final result = await _channel.invokeMethod('stopMeshService');
      return result ?? false;
    } catch (e) {
      print('Error stopping mesh service: $e');
      return false;
    }
  }

  /// Проверить разрешения Bluetooth
  static Future<bool> checkBluetoothPermission() async {
    if (kIsWeb) {
      return false; // Web Bluetooth не поддерживается в fallback режиме
    }

    try {
      final result = await _channel.invokeMethod('checkBluetoothPermission');
      return result ?? false;
    } catch (e) {
      print('Error checking Bluetooth permission: $e');
      return false;
    }
  }

  /// Запросить разрешения Bluetooth
  static Future<bool> requestBluetoothPermission() async {
    if (kIsWeb) {
      return false; // Web Bluetooth не поддерживается в fallback режиме
    }

    try {
      final result = await _channel.invokeMethod('requestBluetoothPermission');
      return result ?? false;
    } catch (e) {
      print('Error requesting Bluetooth permission: $e');
      return false;
    }
  }
}

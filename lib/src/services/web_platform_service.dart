import 'package:flutter/foundation.dart' show kIsWeb;

/// Web-specific implementation of platform services
class WebPlatformService {
  /// Initialize web platform services
  static void initialize() {
    if (kIsWeb) {
      // Register web platform channel handlers
      _registerWebHandlers();
    }
  }

  /// Register web-specific platform channel handlers
  static void _registerWebHandlers() {
    // This method would normally register JavaScript handlers
    // For now, we'll use the fallback implementation in NativeBridge
  }

  /// Get web-specific device information
  static Map<String, dynamic> getWebDeviceInfo() {
    return {
      'platform': 'web',
      'deviceName': 'Web Browser',
      'userAgent': _getUserAgent(),
      'isMobile': _isMobileDevice(),
      'isTablet': _isTabletDevice(),
      'isDesktop': _isDesktopDevice(),
      'isBluetoothSupported': _isBluetoothSupported(),
      'isBluetoothLESupported': _isBluetoothSupported(),
      'isCameraSupported': _hasCamera(),
      'isMicrophoneSupported': _hasMicrophone(),
      'screenWidth': _getScreenWidth(),
      'screenHeight': _getScreenHeight(),
      'pixelRatio': _getPixelRatio(),
    };
  }

  static String _getUserAgent() {
    if (kIsWeb) {
      return ''; // Will be populated by JavaScript
    }
    return 'Unknown';
  }

  static bool _isMobileDevice() {
    if (kIsWeb) {
      final userAgent = _getUserAgent().toLowerCase();
      return userAgent.contains('mobile') ||
             userAgent.contains('android') ||
             userAgent.contains('iphone');
    }
    return false;
  }

  static bool _isTabletDevice() {
    if (kIsWeb) {
      final userAgent = _getUserAgent().toLowerCase();
      return userAgent.contains('tablet') ||
             (userAgent.contains('ipad') && !userAgent.contains('mobile'));
    }
    return false;
  }

  static bool _isDesktopDevice() {
    if (kIsWeb) {
      final userAgent = _getUserAgent().toLowerCase();
      return userAgent.contains('windows') ||
             userAgent.contains('macintosh') ||
             userAgent.contains('linux') ||
             userAgent.contains('chrome');
    }
    return true;
  }

  static bool _isBluetoothSupported() {
    if (kIsWeb) {
      return false; // Web Bluetooth API availability varies
    }
    return false;
  }

  static bool _hasCamera() {
    if (kIsWeb) {
      return false; // Would need user permission
    }
    return false;
  }

  static bool _hasMicrophone() {
    if (kIsWeb) {
      return false; // Would need user permission
    }
    return false;
  }

  static int _getScreenWidth() {
    if (kIsWeb) {
      return 1920; // Default desktop width
    }
    return 1920;
  }

  static int _getScreenHeight() {
    if (kIsWeb) {
      return 1080; // Default desktop height
    }
    return 1080;
  }

  static double _getPixelRatio() {
    if (kIsWeb) {
      return 1.0; // Default pixel ratio
    }
    return 1.0;
  }
}

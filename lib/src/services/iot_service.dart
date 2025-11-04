import 'dart:async';

/// Сервис IoT устройств
class IoTService {
  static final IoTService _instance = IoTService._internal();
  factory IoTService() => _instance;
  static IoTService get instance => _instance;
  IoTService._internal();

  Future<void> initialize() async {
    print('IoT Service initialized');
  }

  void dispose() {
    print('IoT Service disposed');
  }
}

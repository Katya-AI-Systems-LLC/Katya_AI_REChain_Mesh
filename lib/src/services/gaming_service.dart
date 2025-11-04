import 'dart:async';

/// Сервис геймификации
class GamingService {
  static final GamingService _instance = GamingService._internal();
  factory GamingService() => _instance;
  static GamingService get instance => _instance;
  GamingService._internal();

  Future<void> initialize() async {
    print('Gaming Service initialized');
  }

  void dispose() {
    print('Gaming Service disposed');
  }
}

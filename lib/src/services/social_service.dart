import 'dart:async';

/// Сервис социальных функций
class SocialService {
  static final SocialService _instance = SocialService._internal();
  factory SocialService() => _instance;
  static SocialService get instance => _instance;
  SocialService._internal();

  Future<void> initialize() async {
    print('Social Service initialized');
  }

  void dispose() {
    print('Social Service disposed');
  }
}

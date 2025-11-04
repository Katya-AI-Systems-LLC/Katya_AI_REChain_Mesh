import 'dart:async';

/// Сервис блокчейн функций
class BlockchainService {
  static final BlockchainService _instance = BlockchainService._internal();
  factory BlockchainService() => _instance;
  static BlockchainService get instance => _instance;
  BlockchainService._internal();

  Future<void> initialize() async {
    print('Blockchain Service initialized');
  }

  void dispose() {
    print('Blockchain Service disposed');
  }
}

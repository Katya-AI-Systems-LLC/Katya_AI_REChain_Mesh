import 'dart:async';
import 'dart:math';

/// Сервис блокчейн функций - NFT, токены, DeFi
class BlockchainService {
  static final BlockchainService _instance = BlockchainService._internal();
  factory BlockchainService() => _instance;
  static BlockchainService get instance => _instance;
  BlockchainService._internal();

  final StreamController<Transaction> _onTransactionConfirmed =
      StreamController.broadcast();
  final StreamController<NFT> _onNFTMinted = StreamController.broadcast();
  final StreamController<TokenTransfer> _onTokenTransfer =
      StreamController.broadcast();

  // Данные
  final Map<String, Wallet> _wallets = {};
  final Map<String, List<Transaction>> _transactions = {};
  final Map<String, List<NFT>> _nfts = {};
  final Map<String, TokenBalance> _tokenBalances = {};
  final Map<String, SmartContract> _contracts = {};

  Stream<Transaction> get onTransactionConfirmed =>
      _onTransactionConfirmed.stream;
  Stream<NFT> get onNFTMinted => _onNFTMinted.stream;
  Stream<TokenTransfer> get onTokenTransfer => _onTokenTransfer.stream;

  /// Инициализация сервиса
  Future<void> initialize() async {
    print('Initializing Blockchain Service...');
    await _loadSampleData();
    print('Blockchain Service initialized');
  }

  /// Создание кошелька
  Future<Wallet> createWallet({
    required String userId,
    String? name,
  }) async {
    final walletId = _generateId();
    final address = _generateAddress();
    final privateKey = _generatePrivateKey();

    final wallet = Wallet(
      id: walletId,
      userId: userId,
      name: name ?? 'Main Wallet',
      address: address,
      privateKey: privateKey,
      balance: 0.0,
      createdAt: DateTime.now(),
    );

    _wallets[walletId] = wallet;
    _tokenBalances[walletId] = TokenBalance(
      walletId: walletId,
      tokens: {},
    );

    return wallet;
  }

  /// Получение кошелька пользователя
  Wallet? getUserWallet(String userId) {
    return _wallets.values.firstWhere(
      (wallet) => wallet.userId == userId,
      orElse: () => throw Exception('Wallet not found'),
    );
  }

  /// Получение всех кошельков пользователя
  List<Wallet> getWalletsForUser(String userId) {
    final wallets = _wallets.values
        .where((wallet) => wallet.userId == userId)
        .toList();
    wallets.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return wallets;
  }

  /// Получение кошелька по идентификатору
  Wallet? getWalletById(String walletId) {
    return _wallets[walletId];
  }

  /// Отправка транзакции
  Future<Transaction> sendTransaction({
    required String fromWalletId,
    required String toAddress,
    required double amount,
    String? memo,
  }) async {
    final fromWallet = _wallets[fromWalletId];
    if (fromWallet == null) {
      throw Exception('Wallet not found');
    }

    if (fromWallet.balance < amount) {
      throw Exception('Insufficient balance');
    }

    final transactionId = _generateId();
    final transaction = Transaction(
      id: transactionId,
      fromAddress: fromWallet.address,
      toAddress: toAddress,
      amount: amount,
      fee: 0.001, // Фиксированная комиссия
      memo: memo,
      status: TransactionStatus.pending,
      createdAt: DateTime.now(),
      confirmedAt: null,
    );

    // Добавляем транзакцию
    final userTransactions = _transactions[fromWalletId] ?? [];
    userTransactions.add(transaction);
    _transactions[fromWalletId] = userTransactions;

    // Симулируем подтверждение транзакции
    _simulateTransactionConfirmation(transaction, fromWalletId);

    return transaction;
  }

  /// Минтинг NFT
  Future<NFT> mintNFT({
    required String walletId,
    required String name,
    required String description,
    required String imageUrl,
    Map<String, dynamic>? metadata,
  }) async {
    final nftId = _generateId();
    final wallet = _wallets[walletId];
    if (wallet == null) {
      throw Exception('Wallet not found');
    }

    final nft = NFT(
      id: nftId,
      name: name,
      description: description,
      imageUrl: imageUrl,
      ownerAddress: wallet.address,
      ownerWalletId: walletId,
      tokenId: Random().nextInt(1000000),
      contractAddress: '0x${_generateAddress()}',
      metadata: metadata ?? {},
      createdAt: DateTime.now(),
    );

    final userNFTs = _nfts[walletId] ?? [];
    userNFTs.add(nft);
    _nfts[walletId] = userNFTs;

    _onNFTMinted.add(nft);
    return nft;
  }

  /// Передача NFT
  Future<bool> transferNFT({
    required String nftId,
    required String fromWalletId,
    required String toAddress,
  }) async {
    final fromWallet = _wallets[fromWalletId];
    if (fromWallet == null) {
      return false;
    }

    // Находим NFT
    NFT? nft;
    String? currentWalletId;

    for (final entry in _nfts.entries) {
      final nftList = entry.value;
      final foundNFT = nftList.firstWhere(
        (n) => n.id == nftId,
        orElse: () => NFT(
          id: '',
          name: '',
          description: '',
          imageUrl: '',
          ownerAddress: '',
          ownerWalletId: '',
          tokenId: 0,
          contractAddress: '',
          metadata: {},
          createdAt: DateTime.now(),
        ),
      );

      if (foundNFT.id.isNotEmpty) {
        nft = foundNFT;
        currentWalletId = entry.key;
        break;
      }
    }

    if (nft == null || currentWalletId != fromWalletId) {
      return false;
    }

    // Обновляем владельца NFT
    final updatedNFT = nft.copyWith(
      ownerAddress: toAddress,
      ownerWalletId: toAddress, // Упрощение для демо
    );

    // Удаляем из старого кошелька
    final oldNFTs = _nfts[fromWalletId] ?? [];
    oldNFTs.removeWhere((n) => n.id == nftId);
    _nfts[fromWalletId] = oldNFTs;

    // Добавляем в новый кошелек (если существует)
    final newWalletNFTs = _nfts[toAddress] ?? [];
    newWalletNFTs.add(updatedNFT);
    _nfts[toAddress] = newWalletNFTs;

    return true;
  }

  /// Получение баланса токенов
  TokenBalance getTokenBalance(String walletId) {
    return _tokenBalances[walletId] ??
        TokenBalance(
          walletId: walletId,
          tokens: {},
        );
  }

  /// Передача токенов
  Future<bool> transferTokens({
    required String fromWalletId,
    required String toAddress,
    required String tokenSymbol,
    required double amount,
  }) async {
    final fromBalance = _tokenBalances[fromWalletId];
    if (fromBalance == null) {
      return false;
    }

    final currentBalance = fromBalance.tokens[tokenSymbol] ?? 0.0;
    if (currentBalance < amount) {
      return false;
    }

    // Обновляем баланс отправителя
    fromBalance.tokens[tokenSymbol] = currentBalance - amount;

    // Обновляем баланс получателя
    final toBalance = _tokenBalances[toAddress] ??
        TokenBalance(
          walletId: toAddress,
          tokens: {},
        );
    toBalance.tokens[tokenSymbol] =
        (toBalance.tokens[tokenSymbol] ?? 0.0) + amount;
    _tokenBalances[toAddress] = toBalance;

    // Создаем событие передачи
    final transfer = TokenTransfer(
      id: _generateId(),
      fromAddress: _wallets[fromWalletId]?.address ?? '',
      toAddress: toAddress,
      tokenSymbol: tokenSymbol,
      amount: amount,
      timestamp: DateTime.now(),
    );

    _onTokenTransfer.add(transfer);
    return true;
  }

  /// Создание смарт-контракта
  Future<SmartContract> deployContract({
    required String walletId,
    required String name,
    required String description,
    required String code,
    Map<String, dynamic>? parameters,
  }) async {
    final contractId = _generateId();
    final contractAddress = '0x${_generateAddress()}';

    final contract = SmartContract(
      id: contractId,
      name: name,
      description: description,
      address: contractAddress,
      deployerWalletId: walletId,
      code: code,
      parameters: parameters ?? {},
      isActive: true,
      createdAt: DateTime.now(),
    );

    _contracts[contractId] = contract;
    return contract;
  }

  /// Вызов функции смарт-контракта
  Future<bool> callContractFunction({
    required String contractId,
    required String functionName,
    required String walletId,
    Map<String, dynamic>? parameters,
  }) async {
    final contract = _contracts[contractId];
    if (contract == null) {
      return false;
    }

    // Симулируем вызов функции
    print('Calling contract function: $functionName with params: $parameters');

    // Здесь можно добавить логику выполнения функций контракта
    return true;
  }

  /// Получение истории транзакций
  List<Transaction> getTransactionHistory(String walletId) {
    return _transactions[walletId] ?? [];
  }

  /// Получение NFT пользователя
  List<NFT> getUserNFTs(String walletId) {
    return _nfts[walletId] ?? [];
  }

  /// Получение статистики
  Map<String, dynamic> getStatistics() {
    final totalWallets = _wallets.length;
    final totalTransactions =
        _transactions.values.fold(0, (sum, list) => sum + list.length);
    final totalNFTs = _nfts.values.fold(0, (sum, list) => sum + list.length);
    final totalContracts = _contracts.length;

    return {
      'total_wallets': totalWallets,
      'total_transactions': totalTransactions,
      'total_nfts': totalNFTs,
      'total_contracts': totalContracts,
    };
  }

  /// Получение смарт-контрактов по кошельку
  List<SmartContract> getContractsForWallet(String walletId) {
    final contracts = _contracts.values
        .where((contract) => contract.deployerWalletId == walletId)
        .toList();
    contracts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return contracts;
  }

  /// Получение всех смарт-контрактов
  List<SmartContract> getAllContracts() {
    final contracts = _contracts.values.toList();
    contracts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return contracts;
  }

  // Приватные методы

  Future<void> _loadSampleData() async {
    // Создаем пример кошелька
    final wallet = Wallet(
      id: 'wallet_001',
      userId: 'user_001',
      name: 'Main Wallet',
      address: '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6',
      privateKey: '0x1234567890abcdef...',
      balance: 1.5,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    );

    _wallets['wallet_001'] = wallet;
    _tokenBalances['wallet_001'] = const TokenBalance(
      walletId: 'wallet_001',
      tokens: {
        'KATYA': 1000.0,
        'MESH': 500.0,
        'AI': 250.0,
      },
    );

    // Создаем пример NFT
    final nft = NFT(
      id: 'nft_001',
      name: 'Katya AI Avatar',
      description: 'Уникальный аватар AI-ассистента Катя',
      imageUrl: 'https://example.com/katya-avatar.png',
      ownerAddress: wallet.address,
      ownerWalletId: 'wallet_001',
      tokenId: 1,
      contractAddress: '0x1234567890abcdef1234567890abcdef12345678',
      metadata: {
        'rarity': 'legendary',
        'attributes': ['ai', 'assistant', 'mesh'],
        'creator': 'Katya Team',
      },
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    );

    _nfts['wallet_001'] = [nft];

    // Создаем пример смарт-контракта
    final contract = SmartContract(
      id: 'contract_001',
      name: 'Katya Token Contract',
      description: 'Контракт для токена Katya AI',
      address: '0xabcdef1234567890abcdef1234567890abcdef12',
      deployerWalletId: 'wallet_001',
      code: '''
        contract KatyaToken {
            mapping(address => uint256) public balances;
            
            function transfer(address to, uint256 amount) public {
                require(balances[msg.sender] >= amount);
                balances[msg.sender] -= amount;
                balances[to] += amount;
            }
        }
      ''',
      parameters: {
        'totalSupply': 1000000,
        'decimals': 18,
      },
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    );

    _contracts['contract_001'] = contract;
  }

  void _simulateTransactionConfirmation(
      Transaction transaction, String walletId) {
    // Симулируем подтверждение через 3 секунды
    Timer(const Duration(seconds: 3), () {
      final confirmedTransaction = transaction.copyWith(
        status: TransactionStatus.confirmed,
        confirmedAt: DateTime.now(),
      );

      // Обновляем транзакцию
      final userTransactions = _transactions[walletId] ?? [];
      final index = userTransactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        userTransactions[index] = confirmedTransaction;
        _transactions[walletId] = userTransactions;
      }

      // Обновляем баланс кошелька
      final wallet = _wallets[walletId];
      if (wallet != null) {
        _wallets[walletId] = wallet.copyWith(
          balance: wallet.balance - transaction.amount - transaction.fee,
        );
      }

      _onTransactionConfirmed.add(confirmedTransaction);
    });
  }

  String _generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }

  String _generateAddress() {
    const chars = '0123456789abcdef';
    final address =
        List.generate(40, (index) => chars[Random().nextInt(chars.length)]);
    return address.join();
  }

  String _generatePrivateKey() {
    const chars = '0123456789abcdef';
    final key =
        List.generate(64, (index) => chars[Random().nextInt(chars.length)]);
    return key.join();
  }

  void dispose() {
    _onTransactionConfirmed.close();
    _onNFTMinted.close();
    _onTokenTransfer.close();
  }
}

// Модели данных

class Wallet {
  final String id;
  final String userId;
  final String name;
  final String address;
  final String privateKey;
  final double balance;
  final DateTime createdAt;

  const Wallet({
    required this.id,
    required this.userId,
    required this.name,
    required this.address,
    required this.privateKey,
    required this.balance,
    required this.createdAt,
  });

  Wallet copyWith({
    String? id,
    String? userId,
    String? name,
    String? address,
    String? privateKey,
    double? balance,
    DateTime? createdAt,
  }) {
    return Wallet(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      address: address ?? this.address,
      privateKey: privateKey ?? this.privateKey,
      balance: balance ?? this.balance,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class Transaction {
  final String id;
  final String fromAddress;
  final String toAddress;
  final double amount;
  final double fee;
  final String? memo;
  final TransactionStatus status;
  final DateTime createdAt;
  final DateTime? confirmedAt;

  const Transaction({
    required this.id,
    required this.fromAddress,
    required this.toAddress,
    required this.amount,
    required this.fee,
    this.memo,
    required this.status,
    required this.createdAt,
    this.confirmedAt,
  });

  Transaction copyWith({
    String? id,
    String? fromAddress,
    String? toAddress,
    double? amount,
    double? fee,
    String? memo,
    TransactionStatus? status,
    DateTime? createdAt,
    DateTime? confirmedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      fromAddress: fromAddress ?? this.fromAddress,
      toAddress: toAddress ?? this.toAddress,
      amount: amount ?? this.amount,
      fee: fee ?? this.fee,
      memo: memo ?? this.memo,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
    );
  }
}

enum TransactionStatus {
  pending,
  confirmed,
  failed,
}

class NFT {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String ownerAddress;
  final String ownerWalletId;
  final int tokenId;
  final String contractAddress;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  const NFT({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.ownerAddress,
    required this.ownerWalletId,
    required this.tokenId,
    required this.contractAddress,
    required this.metadata,
    required this.createdAt,
  });

  NFT copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? ownerAddress,
    String? ownerWalletId,
    int? tokenId,
    String? contractAddress,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) {
    return NFT(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      ownerAddress: ownerAddress ?? this.ownerAddress,
      ownerWalletId: ownerWalletId ?? this.ownerWalletId,
      tokenId: tokenId ?? this.tokenId,
      contractAddress: contractAddress ?? this.contractAddress,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class TokenBalance {
  final String walletId;
  final Map<String, double> tokens;

  const TokenBalance({
    required this.walletId,
    required this.tokens,
  });
}

class TokenTransfer {
  final String id;
  final String fromAddress;
  final String toAddress;
  final String tokenSymbol;
  final double amount;
  final DateTime timestamp;

  const TokenTransfer({
    required this.id,
    required this.fromAddress,
    required this.toAddress,
    required this.tokenSymbol,
    required this.amount,
    required this.timestamp,
  });
}

class SmartContract {
  final String id;
  final String name;
  final String description;
  final String address;
  final String deployerWalletId;
  final String code;
  final Map<String, dynamic> parameters;
  final bool isActive;
  final DateTime createdAt;

  const SmartContract({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.deployerWalletId,
    required this.code,
    required this.parameters,
    required this.isActive,
    required this.createdAt,
  });
}

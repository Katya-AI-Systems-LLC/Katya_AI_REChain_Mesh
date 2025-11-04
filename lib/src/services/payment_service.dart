import 'dart:async';
import 'package:uuid/uuid.dart';

/// Сервис платежей и финансов для супераппа
class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  static PaymentService get instance => _instance;
  PaymentService._internal();

  final StreamController<PaymentEvent> _onPaymentEvent =
      StreamController.broadcast();
  final StreamController<Transaction> _onTransactionUpdate =
      StreamController.broadcast();

  // Данные пользователей и транзакций
  final Map<String, UserWallet> _wallets = {};
  final Map<String, Transaction> _transactions = {};
  final Map<String, PaymentMethod> _paymentMethods = {};
  final Map<String, Merchant> _merchants = {};

  // Настройки
  final double _transactionFee = 0.02; // 2%
  final double _minTransactionAmount = 0.01;
  final double _maxTransactionAmount = 10000.0;
  final Duration _transactionTimeout = const Duration(minutes: 10);

  Stream<PaymentEvent> get onPaymentEvent => _onPaymentEvent.stream;
  Stream<Transaction> get onTransactionUpdate => _onTransactionUpdate.stream;

  /// Инициализация сервиса
  Future<void> initialize() async {
    print('Initializing Payment Service...');

    // Загружаем предопределенных мерчантов
    await _loadMerchants();

    // Запускаем мониторинг транзакций
    Timer.periodic(const Duration(seconds: 30), (_) => _monitorTransactions());

    print('Payment Service initialized');
  }

  /// Создание кошелька пользователя
  Future<UserWallet> createWallet({
    required String userId,
    required String currency,
    double initialBalance = 0.0,
  }) async {
    final wallet = UserWallet(
      id: const Uuid().v4(),
      userId: userId,
      currency: currency,
      balance: initialBalance,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isActive: true,
    );

    _wallets[wallet.id] = wallet;

    _onPaymentEvent.add(PaymentEvent(
      type: PaymentEventType.walletCreated,
      userId: userId,
      data: {'walletId': wallet.id, 'currency': currency},
      timestamp: DateTime.now(),
    ));

    return wallet;
  }

  /// Пополнение кошелька
  Future<Transaction> topUpWallet({
    required String walletId,
    required double amount,
    required PaymentMethodType method,
    Map<String, dynamic>? metadata,
  }) async {
    final wallet = _wallets[walletId];
    if (wallet == null) {
      throw Exception('Wallet not found: $walletId');
    }

    if (amount < _minTransactionAmount) {
      throw Exception('Amount too small: $amount');
    }

    if (amount > _maxTransactionAmount) {
      throw Exception('Amount too large: $amount');
    }

    final transaction = Transaction(
      id: const Uuid().v4(),
      type: TransactionType.topUp,
      fromWalletId: null,
      toWalletId: walletId,
      amount: amount,
      currency: wallet.currency,
      status: TransactionStatus.pending,
      method: method,
      metadata: metadata ?? {},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      completedAt: null,
      fee: 0.0,
    );

    _transactions[transaction.id] = transaction;

    // Эмулируем обработку платежа
    await _processPayment(transaction);

    return transaction;
  }

  /// Перевод между кошельками
  Future<Transaction> transfer({
    required String fromWalletId,
    required String toWalletId,
    required double amount,
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    final fromWallet = _wallets[fromWalletId];
    final toWallet = _wallets[toWalletId];

    if (fromWallet == null) {
      throw Exception('Source wallet not found: $fromWalletId');
    }

    if (toWallet == null) {
      throw Exception('Destination wallet not found: $toWalletId');
    }

    if (fromWallet.currency != toWallet.currency) {
      throw Exception('Currency mismatch');
    }

    if (amount < _minTransactionAmount) {
      throw Exception('Amount too small: $amount');
    }

    if (fromWallet.balance < amount) {
      throw Exception('Insufficient balance');
    }

    final fee = amount * _transactionFee;
    final totalAmount = amount + fee;

    if (fromWallet.balance < totalAmount) {
      throw Exception('Insufficient balance for fee');
    }

    final transaction = Transaction(
      id: const Uuid().v4(),
      type: TransactionType.transfer,
      fromWalletId: fromWalletId,
      toWalletId: toWalletId,
      amount: amount,
      currency: fromWallet.currency,
      status: TransactionStatus.pending,
      method: PaymentMethodType.wallet,
      metadata: {
        'description': description,
        ...?metadata,
      },
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      completedAt: null,
      fee: fee,
    );

    _transactions[transaction.id] = transaction;

    // Выполняем перевод
    await _executeTransfer(transaction);

    return transaction;
  }

  /// Покупка у мерчанта
  Future<Transaction> purchase({
    required String walletId,
    required String merchantId,
    required double amount,
    required String productId,
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    final wallet = _wallets[walletId];
    final merchant = _merchants[merchantId];

    if (wallet == null) {
      throw Exception('Wallet not found: $walletId');
    }

    if (merchant == null) {
      throw Exception('Merchant not found: $merchantId');
    }

    if (amount < _minTransactionAmount) {
      throw Exception('Amount too small: $amount');
    }

    if (wallet.balance < amount) {
      throw Exception('Insufficient balance');
    }

    final transaction = Transaction(
      id: const Uuid().v4(),
      type: TransactionType.purchase,
      fromWalletId: walletId,
      toWalletId: merchant.walletId,
      amount: amount,
      currency: wallet.currency,
      status: TransactionStatus.pending,
      method: PaymentMethodType.wallet,
      metadata: {
        'merchantId': merchantId,
        'productId': productId,
        'description': description,
        ...?metadata,
      },
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      completedAt: null,
      fee: 0.0,
    );

    _transactions[transaction.id] = transaction;

    // Выполняем покупку
    await _executePurchase(transaction);

    return transaction;
  }

  /// Получение баланса кошелька
  double getWalletBalance(String walletId) {
    final wallet = _wallets[walletId];
    return wallet?.balance ?? 0.0;
  }

  /// Получение истории транзакций
  List<Transaction> getTransactionHistory({
    required String walletId,
    int limit = 50,
    int offset = 0,
  }) {
    final transactions = _transactions.values
        .where((t) => t.fromWalletId == walletId || t.toWalletId == walletId)
        .toList();

    transactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return transactions.skip(offset).take(limit).toList();
  }

  /// Получение статистики
  PaymentStats getStats(String userId) {
    final userWallets =
        _wallets.values.where((w) => w.userId == userId).toList();
    final userTransactions = _transactions.values
        .where((t) => userWallets
            .any((w) => w.id == t.fromWalletId || w.id == t.toWalletId))
        .toList();

    final totalBalance =
        userWallets.fold(0.0, (sum, wallet) => sum + wallet.balance);
    final totalTransactions = userTransactions.length;
    final totalSpent = userTransactions
        .where((t) =>
            t.type == TransactionType.purchase ||
            t.type == TransactionType.transfer)
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalReceived = userTransactions
        .where((t) => t.type == TransactionType.topUp)
        .fold(0.0, (sum, t) => sum + t.amount);

    return PaymentStats(
      totalBalance: totalBalance,
      totalTransactions: totalTransactions,
      totalSpent: totalSpent,
      totalReceived: totalReceived,
      activeWallets: userWallets.where((w) => w.isActive).length,
    );
  }

  /// Добавление метода платежа
  void addPaymentMethod(PaymentMethod method) {
    _paymentMethods[method.id] = method;
  }

  /// Получение методов платежа пользователя
  List<PaymentMethod> getPaymentMethods(String userId) {
    return _paymentMethods.values.where((m) => m.userId == userId).toList();
  }

  // Приватные методы

  Future<void> _loadMerchants() async {
    // Загружаем предопределенных мерчантов
    final merchants = [
      const Merchant(
        id: 'merchant_1',
        name: 'Mesh Store',
        description: 'Онлайн магазин mesh-устройств',
        category: 'Electronics',
        walletId: 'merchant_wallet_1',
        isActive: true,
      ),
      const Merchant(
        id: 'merchant_2',
        name: 'AI Services',
        description: 'AI-услуги и подписки',
        category: 'Services',
        walletId: 'merchant_wallet_2',
        isActive: true,
      ),
      const Merchant(
        id: 'merchant_3',
        name: 'Mesh Games',
        description: 'Игры для mesh-сети',
        category: 'Entertainment',
        walletId: 'merchant_wallet_3',
        isActive: true,
      ),
    ];

    for (final merchant in merchants) {
      _merchants[merchant.id] = merchant;

      // Создаем кошелек для мерчанта
      await createWallet(
        userId: merchant.id,
        currency: 'USD',
        initialBalance: 1000.0,
      );
    }
  }

  Future<void> _processPayment(Transaction transaction) async {
    try {
      // Эмулируем обработку платежа
      await Future.delayed(const Duration(seconds: 2));

      // Обновляем статус
      transaction = transaction.copyWith(
        status: TransactionStatus.completed,
        completedAt: DateTime.now(),
      );
      _transactions[transaction.id] = transaction;

      // Обновляем баланс кошелька
      final wallet = _wallets[transaction.toWalletId];
      if (wallet != null) {
        _wallets[transaction.toWalletId] = wallet.copyWith(
          balance: wallet.balance + transaction.amount,
          updatedAt: DateTime.now(),
        );
      }

      _onTransactionUpdate.add(transaction);

      _onPaymentEvent.add(PaymentEvent(
        type: PaymentEventType.transactionCompleted,
        userId: wallet?.userId ?? '',
        data: {
          'transactionId': transaction.id,
          'amount': transaction.amount,
          'currency': transaction.currency,
        },
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      // Обрабатываем ошибку
      transaction = transaction.copyWith(
        status: TransactionStatus.failed,
        completedAt: DateTime.now(),
      );
      _transactions[transaction.id] = transaction;

      _onTransactionUpdate.add(transaction);

      _onPaymentEvent.add(PaymentEvent(
        type: PaymentEventType.transactionFailed,
        userId: '',
        data: {
          'transactionId': transaction.id,
          'error': e.toString(),
        },
        timestamp: DateTime.now(),
      ));
    }
  }

  Future<void> _executeTransfer(Transaction transaction) async {
    try {
      // Эмулируем выполнение перевода
      await Future.delayed(const Duration(seconds: 1));

      // Обновляем статус
      transaction = transaction.copyWith(
        status: TransactionStatus.completed,
        completedAt: DateTime.now(),
      );
      _transactions[transaction.id] = transaction;

      // Обновляем балансы кошельков
      final fromWallet = _wallets[transaction.fromWalletId!];
      final toWallet = _wallets[transaction.toWalletId];

      if (fromWallet != null) {
        _wallets[transaction.fromWalletId!] = fromWallet.copyWith(
          balance: fromWallet.balance - transaction.amount - transaction.fee,
          updatedAt: DateTime.now(),
        );
      }

      if (toWallet != null) {
        _wallets[transaction.toWalletId] = toWallet.copyWith(
          balance: toWallet.balance + transaction.amount,
          updatedAt: DateTime.now(),
        );
      }

      _onTransactionUpdate.add(transaction);

      _onPaymentEvent.add(PaymentEvent(
        type: PaymentEventType.transferCompleted,
        userId: fromWallet?.userId ?? '',
        data: {
          'transactionId': transaction.id,
          'amount': transaction.amount,
          'currency': transaction.currency,
        },
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      // Обрабатываем ошибку
      transaction = transaction.copyWith(
        status: TransactionStatus.failed,
        completedAt: DateTime.now(),
      );
      _transactions[transaction.id] = transaction;

      _onTransactionUpdate.add(transaction);
    }
  }

  Future<void> _executePurchase(Transaction transaction) async {
    try {
      // Эмулируем выполнение покупки
      await Future.delayed(const Duration(seconds: 1));

      // Обновляем статус
      transaction = transaction.copyWith(
        status: TransactionStatus.completed,
        completedAt: DateTime.now(),
      );
      _transactions[transaction.id] = transaction;

      // Обновляем балансы кошельков
      final fromWallet = _wallets[transaction.fromWalletId!];
      final toWallet = _wallets[transaction.toWalletId];

      if (fromWallet != null) {
        _wallets[transaction.fromWalletId!] = fromWallet.copyWith(
          balance: fromWallet.balance - transaction.amount,
          updatedAt: DateTime.now(),
        );
      }

      if (toWallet != null) {
        _wallets[transaction.toWalletId] = toWallet.copyWith(
          balance: toWallet.balance + transaction.amount,
          updatedAt: DateTime.now(),
        );
      }

      _onTransactionUpdate.add(transaction);

      _onPaymentEvent.add(PaymentEvent(
        type: PaymentEventType.purchaseCompleted,
        userId: fromWallet?.userId ?? '',
        data: {
          'transactionId': transaction.id,
          'amount': transaction.amount,
          'currency': transaction.currency,
          'merchantId': transaction.metadata['merchantId'],
        },
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      // Обрабатываем ошибку
      transaction = transaction.copyWith(
        status: TransactionStatus.failed,
        completedAt: DateTime.now(),
      );
      _transactions[transaction.id] = transaction;

      _onTransactionUpdate.add(transaction);
    }
  }

  void _monitorTransactions() {
    final now = DateTime.now();
    final timeout = _transactionTimeout;

    for (final transaction in _transactions.values) {
      if (transaction.status == TransactionStatus.pending) {
        if (now.difference(transaction.createdAt) > timeout) {
          // Таймаут транзакции
          final updatedTransaction = transaction.copyWith(
            status: TransactionStatus.failed,
            completedAt: now,
          );
          _transactions[transaction.id] = updatedTransaction;
          _onTransactionUpdate.add(updatedTransaction);
        }
      }
    }
  }

  void dispose() {
    _onPaymentEvent.close();
    _onTransactionUpdate.close();
  }
}

// Модели данных

class UserWallet {
  final String id;
  final String userId;
  final String currency;
  final double balance;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  const UserWallet({
    required this.id,
    required this.userId,
    required this.currency,
    required this.balance,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });

  UserWallet copyWith({
    String? id,
    String? userId,
    String? currency,
    double? balance,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return UserWallet(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      currency: currency ?? this.currency,
      balance: balance ?? this.balance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

class Transaction {
  final String id;
  final TransactionType type;
  final String? fromWalletId;
  final String toWalletId;
  final double amount;
  final String currency;
  final TransactionStatus status;
  final PaymentMethodType method;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final double fee;

  const Transaction({
    required this.id,
    required this.type,
    this.fromWalletId,
    required this.toWalletId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.method,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
    required this.fee,
  });

  Transaction copyWith({
    String? id,
    TransactionType? type,
    String? fromWalletId,
    String? toWalletId,
    double? amount,
    String? currency,
    TransactionStatus? status,
    PaymentMethodType? method,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    double? fee,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      fromWalletId: fromWalletId ?? this.fromWalletId,
      toWalletId: toWalletId ?? this.toWalletId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      method: method ?? this.method,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      fee: fee ?? this.fee,
    );
  }
}

class PaymentMethod {
  final String id;
  final String userId;
  final PaymentMethodType type;
  final Map<String, dynamic> details;
  final bool isActive;
  final DateTime createdAt;

  const PaymentMethod({
    required this.id,
    required this.userId,
    required this.type,
    required this.details,
    required this.isActive,
    required this.createdAt,
  });
}

class Merchant {
  final String id;
  final String name;
  final String description;
  final String category;
  final String walletId;
  final bool isActive;

  const Merchant({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.walletId,
    required this.isActive,
  });
}

class PaymentEvent {
  final PaymentEventType type;
  final String userId;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  const PaymentEvent({
    required this.type,
    required this.userId,
    required this.data,
    required this.timestamp,
  });
}

class PaymentStats {
  final double totalBalance;
  final int totalTransactions;
  final double totalSpent;
  final double totalReceived;
  final int activeWallets;

  const PaymentStats({
    required this.totalBalance,
    required this.totalTransactions,
    required this.totalSpent,
    required this.totalReceived,
    required this.activeWallets,
  });
}

// Перечисления

enum TransactionType {
  topUp,
  transfer,
  purchase,
  refund,
  fee,
}

enum TransactionStatus {
  pending,
  completed,
  failed,
  cancelled,
}

enum PaymentMethodType {
  wallet,
  card,
  bank,
  crypto,
  cash,
}

enum PaymentEventType {
  walletCreated,
  walletUpdated,
  transactionStarted,
  transactionCompleted,
  transactionFailed,
  transferCompleted,
  purchaseCompleted,
  refundCompleted,
}

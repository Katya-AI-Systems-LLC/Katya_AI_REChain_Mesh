import 'dart:async';
import 'chat_service.dart';
import 'mesh_service_ble.dart';
import 'voting_service.dart';
import 'ai/ai_service.dart';
import 'ai/agent_orchestrator.dart';
import 'ai/tool_registry.dart';
import 'ai/local_ai_service.dart';
import 'ai/openai_service.dart';
import '../config/app_config.dart';
import 'ai/tools_examples.dart';
import 'file_service.dart';
import 'audio_service.dart';
import 'news_service.dart';
import 'analytics_service.dart';
import 'maps_service.dart';
import 'health_service.dart';
import 'social_service.dart';
import 'gaming_service.dart';
import 'iot_service.dart';
import 'blockchain_service.dart';

/// Ядро супераппа - управление всеми сервисами
class SuperAppCore {
  static final SuperAppCore _instance = SuperAppCore._internal();
  factory SuperAppCore() => _instance;
  static SuperAppCore get instance => _instance;
  SuperAppCore._internal();

  final StreamController<SuperAppEvent> _onEvent = StreamController.broadcast();

  // Сервисы
  late final ChatService chatService;
  late final MeshServiceBLE meshService;
  late final VotingService votingService;
  late final AIService aiService;
  late final AgentOrchestrator aiOrchestrator;
  late final ToolRegistry toolRegistry;
  late final FileService fileService;
  late final AudioService audioService;
  late final NewsService newsService;
  late final AnalyticsService analyticsService;
  late final MapsService mapsService;
  late final HealthService healthService;
  late final SocialService socialService;
  late final GamingService gamingService;
  late final IoTService iotService;
  late final BlockchainService blockchainService;

  bool _isInitialized = false;
  Stream<SuperAppEvent> get onEvent => _onEvent.stream;

  /// Инициализация всех сервисов
  Future<void> initialize() async {
    if (_isInitialized) {
      print('SuperApp already initialized');
      return;
    }

    print('Initializing SuperApp Core...');

    try {
      // Инициализация сервисов
      chatService = ChatService();
      meshService = MeshServiceBLE();
      votingService = VotingService();
      toolRegistry = ToolRegistry();
      if (AppConfig.aiProvider == 'openai' &&
          AppConfig.openaiApiKey.isNotEmpty) {
        aiService = OpenAIService(apiKey: AppConfig.openaiApiKey);
      } else {
        aiService = LocalAIService();
      }
      aiOrchestrator =
          AgentOrchestrator(provider: aiService, tools: toolRegistry);
      registerExampleTools(toolRegistry);
      fileService = FileService();
      audioService = AudioService();
      newsService = NewsService();
      analyticsService = AnalyticsService();
      mapsService = MapsService();
      healthService = HealthService();
      socialService = SocialService();
      gamingService = GamingService();
      iotService = IoTService();
      blockchainService = BlockchainService();

      // Запуск инициализации сервисов параллельно
      await Future.wait([
        chatService.initialize(),
        meshService.initialize(),
        votingService.initialize(),
        Future.value(), // aiService doesn't have initialize
        Future.value(), // fileService doesn't have initialize
        Future.value(), // audioService doesn't have initialize
        newsService.initialize(),
        analyticsService.initialize(),
        mapsService.initialize(),
        healthService.initialize(),
        socialService.initialize(),
        gamingService.initialize(),
        iotService.initialize(),
        blockchainService.initialize(),
      ]);

      _isInitialized = true;
      _emitEvent(SuperAppEvent(
        type: SuperAppEventType.initialized,
        data: {'timestamp': DateTime.now().toIso8601String()},
      ));

      print('SuperApp Core initialized successfully');
    } catch (e, stackTrace) {
      print('Error initializing SuperApp Core: $e');
      print('Stack trace: $stackTrace');
      _emitEvent(SuperAppEvent(
        type: SuperAppEventType.error,
        data: {'error': e.toString()},
      ));
      rethrow;
    }
  }

  /// Получение статуса инициализации
  bool get isInitialized => _isInitialized;

  /// Получение всех сервисов
  Map<String, dynamic> getServices() {
    return {
      'chat': chatService,
      'mesh': meshService,
      'voting': votingService,
      'ai': aiService,
      'file': fileService,
      'audio': audioService,
      'news': newsService,
      'analytics': analyticsService,
      'maps': mapsService,
      'health': healthService,
      'social': socialService,
      'gaming': gamingService,
      'iot': iotService,
      'blockchain': blockchainService,
    };
  }

  /// Остановка всех сервисов
  Future<void> shutdown() async {
    if (!_isInitialized) return;

    print('Shutting down SuperApp Core...');

    try {
      // Остановка сервисов
      chatService.dispose();
      meshService.dispose();
      votingService.dispose();
      await aiService.dispose();
      // fileService doesn't have dispose
      // audioService doesn't have dispose
      newsService.dispose();
      analyticsService.dispose();
      mapsService.dispose();
      healthService.dispose();
      socialService.dispose();
      gamingService.dispose();
      iotService.dispose();
      blockchainService.dispose();

      _isInitialized = false;
      _emitEvent(SuperAppEvent(
        type: SuperAppEventType.shutdown,
        data: {'timestamp': DateTime.now().toIso8601String()},
      ));

      print('SuperApp Core shut down successfully');
    } catch (e, stackTrace) {
      print('Error shutting down SuperApp Core: $e');
      print('Stack trace: $stackTrace');
    }
  }

  /// Получение общей статистики
  Map<String, dynamic> getStatistics() {
    final chatStats = chatService.getStatistics();
    final votingStats = votingService.getStatistics();
    final analyticsMetrics = analyticsService.getAppMetrics();

    return {
      'total_messages': chatStats['total_messages'],
      'active_conversations': chatStats['active_conversations'],
      'total_polls': votingStats['total_polls'],
      'total_votes': votingStats['total_votes'],
      'total_users': analyticsMetrics.totalUsers,
      'total_events': analyticsMetrics.totalEvents,
      'active_users': analyticsMetrics.activeUsers,
      'initialization_time':
          _isInitialized ? DateTime.now().toIso8601String() : null,
    };
  }

  // Приватные методы

  void _emitEvent(SuperAppEvent event) {
    _onEvent.add(event);
  }

  void dispose() {
    shutdown();
    _onEvent.close();
  }
}

// Модели данных

class SuperAppEvent {
  final SuperAppEventType type;
  final Map<String, dynamic> data;

  const SuperAppEvent({
    required this.type,
    required this.data,
  });
}

enum SuperAppEventType {
  initialized,
  error,
  shutdown,
  serviceStatusChanged,
}

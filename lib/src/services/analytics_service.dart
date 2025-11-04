import 'dart:async';
import 'dart:math';

/// Сервис аналитики и статистики
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  static AnalyticsService get instance => _instance;
  AnalyticsService._internal();

  final StreamController<AnalyticsEvent> _onEventTracked =
      StreamController.broadcast();

  // Данные
  final Map<String, List<AnalyticsEvent>> _events = {};
  final Map<String, UserMetrics> _userMetrics = {};
  final Map<String, AppMetrics> _appMetrics = {};

  Stream<AnalyticsEvent> get onEventTracked => _onEventTracked.stream;

  /// Инициализация сервиса
  Future<void> initialize() async {
    print('Initializing Analytics Service...');

    // Запускаем периодический сбор метрик
    Timer.periodic(const Duration(minutes: 5), (_) => _collectAppMetrics());

    print('Analytics Service initialized');
  }

  /// Отслеживание события
  Future<void> trackEvent({
    required String userId,
    required String eventName,
    Map<String, dynamic>? properties,
    Map<String, dynamic>? context,
  }) async {
    final event = AnalyticsEvent(
      id: _generateEventId(),
      userId: userId,
      eventName: eventName,
      properties: properties ?? {},
      context: context ?? {},
      timestamp: DateTime.now(),
    );

    _addEvent(event);
    _updateUserMetrics(userId, event);
    _onEventTracked.add(event);

    print('Tracked event: $eventName for user: $userId');
  }

  /// Отслеживание просмотра страницы
  Future<void> trackPageView({
    required String userId,
    required String pageName,
    Map<String, dynamic>? properties,
  }) async {
    await trackEvent(
      userId: userId,
      eventName: 'page_view',
      properties: {
        'page_name': pageName,
        ...?properties,
      },
    );
  }

  /// Получение метрик пользователя
  UserMetrics getUserMetrics(String userId) {
    return _userMetrics[userId] ??
        UserMetrics(
          userId: userId,
          totalEvents: 0,
          totalSessions: 0,
          averageSessionDuration: Duration.zero,
          mostUsedFeatures: [],
          lastActive: DateTime.now(),
        );
  }

  /// Получение метрик приложения
  AppMetrics getAppMetrics() {
    return _appMetrics['global'] ??
        const AppMetrics(
          totalUsers: 0,
          totalEvents: 0,
          activeUsers: 0,
          averageSessionDuration: Duration.zero,
          mostPopularFeatures: [],
          crashRate: 0.0,
          performanceScore: 0.0,
        );
  }

  /// Получение отчета о производительности
  PerformanceReport getPerformanceReport() {
    final metrics = getAppMetrics();

    return const PerformanceReport(
      appLaunchTime: Duration(milliseconds: 500),
      averageResponseTime: Duration(milliseconds: 200),
      memoryUsage: 50.0, // MB
      networkLatency: Duration(milliseconds: 150),
      errorRate: 0.01, // 1%
      successRate: 0.99, // 99%
    );
  }

  /// Получение отчета о поведении пользователей
  Future<UserBehaviorReport> getUserBehaviorReport({
    required int days,
  }) async {
    final cutoff = DateTime.now().subtract(Duration(days: days));

    final events = _events.values
        .expand((list) => list)
        .where((event) => event.timestamp.isAfter(cutoff))
        .toList();

    final uniqueUsers = events.map((e) => e.userId).toSet().length;
    final totalEvents = events.length;
    final averageEventsPerUser =
        uniqueUsers > 0 ? totalEvents / uniqueUsers : 0.0;

    return UserBehaviorReport(
      totalUsers: uniqueUsers,
      totalEvents: totalEvents,
      averageEventsPerUser: averageEventsPerUser,
      topEvents: _getTopEvents(events),
      activeHours: _getActiveHours(events),
    );
  }

  /// Получение аналитических инсайтов
  List<AnalyticsInsight> getInsights() {
    final insights = <AnalyticsInsight>[];

    final metrics = getAppMetrics();

    // Инсайт о производительности
    if (metrics.performanceScore < 0.7) {
      insights.add(const AnalyticsInsight(
        type: InsightType.performance,
        title: 'Низкая производительность',
        description: 'Производительность приложения ниже нормы',
        priority: InsightPriority.high,
        recommendations: [
          'Оптимизировать использование памяти',
          'Улучшить сетевые запросы',
          'Кэшировать данные',
        ],
      ));
    }

    // Инсайт об использовании функций
    if (metrics.mostPopularFeatures.isNotEmpty) {
      insights.add(const AnalyticsInsight(
        type: InsightType.usage,
        title: 'Популярные функции',
        description: 'Наиболее используемые функции приложения',
        priority: InsightPriority.low,
        recommendations: [
          'Улучшить популярные функции',
          'Добавить похожую функциональность',
        ],
      ));
    }

    return insights;
  }

  // Приватные методы

  String _generateEventId() {
    return 'evt_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }

  void _addEvent(AnalyticsEvent event) {
    final userEvents = _events[event.userId] ?? [];
    userEvents.add(event);
    _events[event.userId] = userEvents;
  }

  void _updateUserMetrics(String userId, AnalyticsEvent event) {
    final current = _userMetrics[userId] ??
        UserMetrics(
          userId: userId,
          totalEvents: 0,
          totalSessions: 0,
          averageSessionDuration: Duration.zero,
          mostUsedFeatures: [],
          lastActive: DateTime.now(),
        );

    _userMetrics[userId] = current.copyWith(
      totalEvents: current.totalEvents + 1,
      lastActive: event.timestamp,
    );
  }

  void _collectAppMetrics() {
    final totalUsers = _events.keys.length;
    final totalEvents =
        _events.values.fold(0, (sum, events) => sum + events.length);

    final activeUsers = _userMetrics.values
        .where((m) => DateTime.now().difference(m.lastActive).inHours < 24)
        .length;

    _appMetrics['global'] = AppMetrics(
      totalUsers: totalUsers,
      totalEvents: totalEvents,
      activeUsers: activeUsers,
      averageSessionDuration: const Duration(minutes: 15),
      mostPopularFeatures: ['chat', 'messaging', 'ai'],
      crashRate: 0.01,
      performanceScore: 0.85,
    );
  }

  List<EventSummary> _getTopEvents(List<AnalyticsEvent> events) {
    final eventCounts = <String, int>{};

    for (final event in events) {
      eventCounts[event.eventName] = (eventCounts[event.eventName] ?? 0) + 1;
    }

    final sorted = eventCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted
        .take(5)
        .map((e) => EventSummary(
              eventName: e.key,
              count: e.value,
            ))
        .toList();
  }

  Map<int, int> _getActiveHours(List<AnalyticsEvent> events) {
    final hourCounts = <int, int>{};

    for (final event in events) {
      final hour = event.timestamp.hour;
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }

    return hourCounts;
  }

  void dispose() {
    _onEventTracked.close();
  }
}

// Модели данных

class AnalyticsEvent {
  final String id;
  final String userId;
  final String eventName;
  final Map<String, dynamic> properties;
  final Map<String, dynamic> context;
  final DateTime timestamp;

  const AnalyticsEvent({
    required this.id,
    required this.userId,
    required this.eventName,
    required this.properties,
    required this.context,
    required this.timestamp,
  });
}

class UserMetrics {
  final String userId;
  final int totalEvents;
  final int totalSessions;
  final Duration averageSessionDuration;
  final List<String> mostUsedFeatures;
  final DateTime lastActive;

  const UserMetrics({
    required this.userId,
    required this.totalEvents,
    required this.totalSessions,
    required this.averageSessionDuration,
    required this.mostUsedFeatures,
    required this.lastActive,
  });

  UserMetrics copyWith({
    String? userId,
    int? totalEvents,
    int? totalSessions,
    Duration? averageSessionDuration,
    List<String>? mostUsedFeatures,
    DateTime? lastActive,
  }) {
    return UserMetrics(
      userId: userId ?? this.userId,
      totalEvents: totalEvents ?? this.totalEvents,
      totalSessions: totalSessions ?? this.totalSessions,
      averageSessionDuration:
          averageSessionDuration ?? this.averageSessionDuration,
      mostUsedFeatures: mostUsedFeatures ?? this.mostUsedFeatures,
      lastActive: lastActive ?? this.lastActive,
    );
  }
}

class AppMetrics {
  final int totalUsers;
  final int totalEvents;
  final int activeUsers;
  final Duration averageSessionDuration;
  final List<String> mostPopularFeatures;
  final double crashRate;
  final double performanceScore;

  const AppMetrics({
    required this.totalUsers,
    required this.totalEvents,
    required this.activeUsers,
    required this.averageSessionDuration,
    required this.mostPopularFeatures,
    required this.crashRate,
    required this.performanceScore,
  });
}

class PerformanceReport {
  final Duration appLaunchTime;
  final Duration averageResponseTime;
  final double memoryUsage;
  final Duration networkLatency;
  final double errorRate;
  final double successRate;

  const PerformanceReport({
    required this.appLaunchTime,
    required this.averageResponseTime,
    required this.memoryUsage,
    required this.networkLatency,
    required this.errorRate,
    required this.successRate,
  });
}

class UserBehaviorReport {
  final int totalUsers;
  final int totalEvents;
  final double averageEventsPerUser;
  final List<EventSummary> topEvents;
  final Map<int, int> activeHours;

  const UserBehaviorReport({
    required this.totalUsers,
    required this.totalEvents,
    required this.averageEventsPerUser,
    required this.topEvents,
    required this.activeHours,
  });
}

class EventSummary {
  final String eventName;
  final int count;

  const EventSummary({
    required this.eventName,
    required this.count,
  });
}

class AnalyticsInsight {
  final InsightType type;
  final String title;
  final String description;
  final InsightPriority priority;
  final List<String> recommendations;

  const AnalyticsInsight({
    required this.type,
    required this.title,
    required this.description,
    required this.priority,
    required this.recommendations,
  });
}

enum InsightType {
  performance,
  usage,
  security,
  revenue,
}

enum InsightPriority {
  low,
  medium,
  high,
  critical,
}

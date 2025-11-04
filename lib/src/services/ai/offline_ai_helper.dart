import '../../services/voting_service.dart';
import 'dart:math';

/// Simple offline AI helper for chat suggestions and poll analysis
class OfflineAIHelper {
  static final OfflineAIHelper _instance = OfflineAIHelper._internal();
  factory OfflineAIHelper() => _instance;
  static OfflineAIHelper get instance => _instance;
  OfflineAIHelper._internal();

  final Random _random = Random();

  /// Generate AI response (for compatibility with AIRequest/AIResponse pattern)
  Future<Map<String, dynamic>> generate(Map<String, dynamic> request) async {
    // Simulate AI processing delay
    await Future.delayed(Duration(milliseconds: 200 + _random.nextInt(300)));

    final prompt = (request['prompt'] as String? ?? '').toLowerCase();
    final context = request['context'] as Map<String, dynamic>? ?? {};

    // Chat suggestions
    if (prompt.contains('привет') || prompt.contains('hello') || prompt.contains('hi')) {
      return {
        'text': 'Привет! 👋 Готов помочь с mesh-коммуникацией.',
        'metadata': {'type': 'greeting'},
      };
    }

    if (prompt.contains('как дела') || prompt.contains('how are you')) {
      return {
        'text': 'Отлично! Mesh-сеть работает. Пиров: ${context['peers'] ?? 0}.',
        'metadata': {'type': 'status'},
      };
    }

    if (prompt.contains('голосование') || prompt.contains('vote') || prompt.contains('poll')) {
      return {
        'text': 'Создайте опрос в разделе "Голосование". Я могу проанализировать результаты!',
        'metadata': {'type': 'voting_help'},
      };
    }

    // Generic response pattern matching
    final suggestions = [
      'Попробуйте создать опрос для быстрого принятия решений.',
      'Mesh-мессенджер работает без интернета через BLE.',
      'Используйте broadcast для отправки сообщений всем пирам.',
    ];
    final response = suggestions[_random.nextInt(suggestions.length)];

    return {
      'text': response,
      'metadata': {'type': 'suggestion'},
    };
  }

  /// Generate chat reply suggestions based on last messages
  Future<List<String>> suggestReplies(List<String> recentMessages) async {
    await Future.delayed(Duration(milliseconds: 100));
    
    if (recentMessages.isEmpty) {
      return ['Привет! 👋', 'Как дела?', 'Готов к общению'];
    }

    final last = recentMessages.last.toLowerCase();
    final suggestions = <String>[];

    if (last.contains('привет') || last.contains('hello')) {
      suggestions.addAll(['Привет! 👋', 'Здравствуй', 'Приветствую']);
    } else if (last.contains('как дела') || last.contains('how are')) {
      suggestions.addAll(['Всё хорошо, спасибо!', 'Отлично! А у тебя?', 'Всё в порядке']);
    } else if (last.contains('?')) {
      suggestions.addAll(['Хороший вопрос!', 'Давай разберёмся', 'Подумаю...']);
    } else {
      suggestions.addAll(['Понял 👍', 'Ок', 'Интересно...']);
    }

    return suggestions.take(3).toList();
  }

  /// Analyze voting poll and provide summary
  Future<String> analyzePoll(VotingPoll poll) async {
    await Future.delayed(Duration(milliseconds: 300));
    
    final total = poll.votes.values.fold(0, (s, v) => s + v);
    if (total == 0) {
      return '📊 Опрос "${poll.title}": пока нет голосов. Ожидаем активности...';
    }

    final leader = poll.votes.entries.reduce((a, b) => a.value > b.value ? a : b);
    final leaderPercent = (leader.value / total * 100).toStringAsFixed(1);
    
    final activePercent = poll.isActive ? 'Активно' : 'Завершено';
    
    return '''📊 Анализ опроса "${poll.title}":

🎯 Лидер: ${leader.key} (${leader.value} голосов, $leaderPercent%)
📈 Всего голосов: $total
⚡ Статус: $activePercent

💡 Рекомендация: ${poll.isActive ? 'Продолжайте голосовать!' : 'Опрос завершён, можно подвести итоги.'}''';
  }

  Future<void> dispose() async {
    // No-op for offline helper
  }
}


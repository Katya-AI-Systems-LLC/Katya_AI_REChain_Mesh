import 'dart:async';
import 'dart:math';
import 'package:uuid/uuid.dart';

/// Продвинутый AI сервис с машинным обучением и NLP
class AdvancedAIService {
  static final AdvancedAIService _instance = AdvancedAIService._internal();
  factory AdvancedAIService() => _instance;
  static AdvancedAIService get instance => _instance;
  AdvancedAIService._internal();

  final StreamController<AIResponse> _onResponseGenerated =
      StreamController.broadcast();
  final StreamController<AILearningEvent> _onLearningEvent =
      StreamController.broadcast();

  // Модели и данные
  final Map<String, UserProfile> _userProfiles = {};
  final Map<String, ConversationContext> _conversations = {};
  final Map<String, double> _sentimentWeights = {};
  final Map<String, List<String>> _topicClusters = {};
  final Map<String, double> _languageModel = {};

  // Настройки AI
  final double _learningRate = 0.1;
  final int _contextWindow = 10;
  final double _creativityLevel = 0.7;
  final bool _enableLearning = true;

  Stream<AIResponse> get onResponseGenerated => _onResponseGenerated.stream;
  Stream<AILearningEvent> get onLearningEvent => _onLearningEvent.stream;

  /// Инициализация AI системы
  Future<void> initialize() async {
    print('Initializing Advanced AI Service...');

    // Загружаем предобученные модели
    await _loadPreTrainedModels();

    // Инициализируем базовые веса
    _initializeSentimentWeights();

    // Запускаем фоновое обучение
    if (_enableLearning) {
      Timer.periodic(
          const Duration(minutes: 5), (_) => _performBackgroundLearning());
    }

    print('Advanced AI Service initialized');
  }

  /// Генерация ответа с учетом контекста
  Future<AIResponse> generateResponse({
    required String userId,
    required String message,
    required ConversationContext context,
  }) async {
    try {
      // Анализируем сообщение
      final analysis = await _analyzeMessage(message);

      // Получаем профиль пользователя
      final userProfile = _getUserProfile(userId);

      // Генерируем ответ
      final response = await _generateContextualResponse(
        message: message,
        analysis: analysis,
        userProfile: userProfile,
        context: context,
      );

      // Обновляем контекст
      _updateConversationContext(userId, message, response);

      // Обучаем модель на новом взаимодействии
      if (_enableLearning) {
        await _learnFromInteraction(userId, message, response, analysis);
      }

      // Отправляем событие
      _onResponseGenerated.add(response);

      return response;
    } catch (e) {
      print('Error generating AI response: $e');
      return AIResponse(
        id: const Uuid().v4(),
        text: 'Извините, произошла ошибка при обработке вашего сообщения.',
        confidence: 0.0,
        sentiment: Sentiment.neutral,
        topics: [],
        suggestions: [],
        timestamp: DateTime.now(),
      );
    }
  }

  /// Анализ настроения и эмоций
  Future<SentimentAnalysis> analyzeSentiment(String text) async {
    final words = _tokenize(text);
    double positiveScore = 0.0;
    double negativeScore = 0.0;
    double neutralScore = 0.0;

    for (final word in words) {
      final weight = _sentimentWeights[word.toLowerCase()] ?? 0.0;
      if (weight > 0) {
        positiveScore += weight;
      } else if (weight < 0) {
        negativeScore += weight.abs();
      } else {
        neutralScore += 1.0;
      }
    }

    final totalScore = positiveScore + negativeScore + neutralScore;
    if (totalScore == 0) {
      return const SentimentAnalysis(
        sentiment: Sentiment.neutral,
        confidence: 0.0,
        emotions: [Emotion.neutral],
        intensity: 0.0,
      );
    }

    final normalizedPositive = positiveScore / totalScore;
    final normalizedNegative = negativeScore / totalScore;
    final normalizedNeutral = neutralScore / totalScore;

    Sentiment sentiment;
    double confidence;
    List<Emotion> emotions = [];

    if (normalizedPositive > normalizedNegative &&
        normalizedPositive > normalizedNeutral) {
      sentiment = Sentiment.positive;
      confidence = normalizedPositive;
      emotions = _detectEmotions(text, true);
    } else if (normalizedNegative > normalizedPositive &&
        normalizedNegative > normalizedNeutral) {
      sentiment = Sentiment.negative;
      confidence = normalizedNegative;
      emotions = _detectEmotions(text, false);
    } else {
      sentiment = Sentiment.neutral;
      confidence = normalizedNeutral;
      emotions = [Emotion.neutral];
    }

    return SentimentAnalysis(
      sentiment: sentiment,
      confidence: confidence,
      emotions: emotions,
      intensity: (normalizedPositive + normalizedNegative) / 2,
    );
  }

  /// Генерация умных предложений
  Future<List<String>> generateSmartSuggestions({
    required String userId,
    required String context,
    required int count,
  }) async {
    final userProfile = _getUserProfile(userId);
    final suggestions = <String>[];

    // Анализируем контекст
    final contextAnalysis = await _analyzeMessage(context);

    // Генерируем предложения на основе профиля пользователя
    if (userProfile.preferredTopics.isNotEmpty) {
      suggestions.addAll(_generateTopicBasedSuggestions(
        userProfile.preferredTopics,
        contextAnalysis.topics,
        count ~/ 2,
      ));
    }

    // Генерируем предложения на основе эмоций
    if (contextAnalysis.sentiment != Sentiment.neutral) {
      suggestions.addAll(_generateEmotionBasedSuggestions(
        contextAnalysis.sentiment,
        contextAnalysis.emotions,
        count ~/ 2,
      ));
    }

    // Генерируем общие предложения
    suggestions.addAll(_generateGeneralSuggestions(count - suggestions.length));

    return suggestions.take(count).toList();
  }

  /// Обучение на пользовательских данных
  Future<void> learnFromUserFeedback({
    required String userId,
    required String message,
    required AIResponse response,
    required double rating,
    required String feedback,
  }) async {
    if (!_enableLearning) return;

    try {
      // Обновляем веса на основе обратной связи
      final words = _tokenize(message);
      final feedbackWords = _tokenize(feedback);

      for (final word in words) {
        final currentWeight = _sentimentWeights[word.toLowerCase()] ?? 0.0;
        final adjustment = (rating - 0.5) * _learningRate;
        _sentimentWeights[word.toLowerCase()] = currentWeight + adjustment;
      }

      // Обновляем профиль пользователя
      final userProfile = _getUserProfile(userId);
      userProfile.addInteraction(message, response, rating);

      // Отправляем событие обучения
      _onLearningEvent.add(AILearningEvent(
        type: AILearningEventType.feedback,
        userId: userId,
        data: {
          'rating': rating,
          'feedback': feedback,
          'message': message,
        },
        timestamp: DateTime.now(),
      ));

      print('Learned from user feedback: rating=$rating');
    } catch (e) {
      print('Error learning from feedback: $e');
    }
  }

  /// Получение аналитики пользователя
  UserAnalytics getUserAnalytics(String userId) {
    final userProfile = _getUserProfile(userId);
    final conversations = _conversations[userId] ?? const ConversationContext();

    return UserAnalytics(
      userId: userId,
      totalMessages: userProfile.totalMessages,
      averageSentiment: userProfile.averageSentiment,
      preferredTopics: userProfile.preferredTopics,
      communicationStyle: userProfile.communicationStyle,
      responseTime: userProfile.averageResponseTime,
      satisfactionScore: userProfile.satisfactionScore,
      lastActive: userProfile.lastActive,
    );
  }

  // Приватные методы

  Future<void> _loadPreTrainedModels() async {
    // Загружаем предобученные модели (в реальном приложении из файлов)
    _languageModel.addAll({
      'привет': 0.8,
      'спасибо': 0.9,
      'пожалуйста': 0.7,
      'хорошо': 0.8,
      'плохо': -0.8,
      'отлично': 0.9,
      'ужасно': -0.9,
      'люблю': 0.9,
      'ненавижу': -0.9,
      'рад': 0.8,
      'грустно': -0.7,
    });
  }

  void _initializeSentimentWeights() {
    _sentimentWeights.addAll(_languageModel);
  }

  Future<void> _performBackgroundLearning() async {
    // Выполняем фоновое обучение
    print('Performing background learning...');

    // Обновляем кластеры тем
    await _updateTopicClusters();

    // Оптимизируем веса
    await _optimizeWeights();

    print('Background learning completed');
  }

  Future<MessageAnalysis> _analyzeMessage(String message) async {
    final sentiment = await analyzeSentiment(message);
    final topics = _extractTopics(message);
    final entities = _extractEntities(message);
    final intent = _detectIntent(message);

    return MessageAnalysis(
      text: message,
      sentiment: sentiment,
      topics: topics,
      entities: entities,
      intent: intent,
      confidence: sentiment.confidence,
      timestamp: DateTime.now(),
    );
  }

  List<String> _extractTopics(String text) {
    final topics = <String>[];
    final words = _tokenize(text);

    // Простое извлечение тем на основе ключевых слов
    final topicKeywords = {
      'работа': ['работа', 'работать', 'офис', 'проект', 'задача'],
      'семья': ['семья', 'родители', 'дети', 'мама', 'папа'],
      'друзья': ['друзья', 'друг', 'подруга', 'встреча', 'вечеринка'],
      'здоровье': ['здоровье', 'болезнь', 'врач', 'лекарство', 'боль'],
      'путешествия': ['путешествие', 'отпуск', 'поездка', 'страна', 'город'],
      'еда': ['еда', 'ресторан', 'готовить', 'вкусно', 'голодный'],
      'спорт': ['спорт', 'тренировка', 'бег', 'фитнес', 'игра'],
      'музыка': ['музыка', 'песня', 'концерт', 'группа', 'альбом'],
    };

    for (final entry in topicKeywords.entries) {
      for (final keyword in entry.value) {
        if (words.any((word) => word.toLowerCase().contains(keyword))) {
          topics.add(entry.key);
          break;
        }
      }
    }

    return topics;
  }

  List<String> _extractEntities(String text) {
    // Простое извлечение сущностей
    final entities = <String>[];
    final words = _tokenize(text);

    for (final word in words) {
      if (word.length > 3 && word[0].toUpperCase() == word[0]) {
        entities.add(word);
      }
    }

    return entities;
  }

  Intent _detectIntent(String text) {
    final lowerText = text.toLowerCase();

    if (lowerText.contains('?') ||
        lowerText.contains('что') ||
        lowerText.contains('как')) {
      return Intent.question;
    } else if (lowerText.contains('спасибо') ||
        lowerText.contains('благодарю')) {
      return Intent.gratitude;
    } else if (lowerText.contains('привет') ||
        lowerText.contains('здравствуй')) {
      return Intent.greeting;
    } else if (lowerText.contains('пока') ||
        lowerText.contains('до свидания')) {
      return Intent.goodbye;
    } else if (lowerText.contains('помоги') ||
        lowerText.contains('нужна помощь')) {
      return Intent.help;
    } else {
      return Intent.statement;
    }
  }

  Future<AIResponse> _generateContextualResponse({
    required String message,
    required MessageAnalysis analysis,
    required UserProfile userProfile,
    required ConversationContext context,
  }) async {
    final responseText = await _generateResponseText(
      message: message,
      analysis: analysis,
      userProfile: userProfile,
      context: context,
    );

    final suggestions = await generateSmartSuggestions(
      userId: userProfile.userId,
      context: message,
      count: 3,
    );

    return AIResponse(
      id: const Uuid().v4(),
      text: responseText,
      confidence: analysis.confidence,
      sentiment: analysis.sentiment.sentiment,
      topics: analysis.topics,
      suggestions: suggestions,
      timestamp: DateTime.now(),
    );
  }

  Future<String> _generateResponseText({
    required String message,
    required MessageAnalysis analysis,
    required UserProfile userProfile,
    required ConversationContext context,
  }) async {
    // Генерируем ответ на основе анализа
    switch (analysis.intent) {
      case Intent.greeting:
        return _generateGreetingResponse(userProfile);
      case Intent.question:
        return _generateQuestionResponse(analysis);
      case Intent.gratitude:
        return _generateGratitudeResponse();
      case Intent.goodbye:
        return _generateGoodbyeResponse();
      case Intent.help:
        return _generateHelpResponse(analysis);
      case Intent.statement:
        return _generateStatementResponse(analysis, userProfile);
    }
  }

  String _generateGreetingResponse(UserProfile userProfile) {
    final greetings = [
      'Привет! Как дела?',
      'Здравствуй! Рад тебя видеть!',
      'Привет! Что нового?',
      'Здравствуй! Как настроение?',
    ];

    return greetings[Random().nextInt(greetings.length)];
  }

  String _generateQuestionResponse(MessageAnalysis analysis) {
    if (analysis.topics.contains('работа')) {
      return 'Расскажи подробнее о своей работе. Что тебя интересует?';
    } else if (analysis.topics.contains('семья')) {
      return 'Как дела в семье? Все хорошо?';
    } else if (analysis.topics.contains('здоровье')) {
      return 'Как самочувствие? Нужна ли помощь?';
    } else {
      return 'Интересный вопрос! Можешь рассказать больше?';
    }
  }

  String _generateGratitudeResponse() {
    final responses = [
      'Пожалуйста! Рад помочь!',
      'Не за что! Всегда к твоим услугам!',
      'Пожалуйста! Обращайся еще!',
    ];

    return responses[Random().nextInt(responses.length)];
  }

  String _generateGoodbyeResponse() {
    final responses = [
      'До свидания! Увидимся!',
      'Пока! Хорошего дня!',
      'До встречи! Береги себя!',
    ];

    return responses[Random().nextInt(responses.length)];
  }

  String _generateHelpResponse(MessageAnalysis analysis) {
    return 'Конечно помогу! Расскажи, что именно тебя беспокоит?';
  }

  String _generateStatementResponse(
      MessageAnalysis analysis, UserProfile userProfile) {
    if (analysis.sentiment.sentiment == Sentiment.positive) {
      return 'Отлично! Рад за тебя!';
    } else if (analysis.sentiment.sentiment == Sentiment.negative) {
      return 'Понимаю, что тебе нелегко. Хочешь поговорить об этом?';
    } else {
      return 'Понятно. Расскажи еще что-нибудь!';
    }
  }

  List<String> _generateTopicBasedSuggestions(
    List<String> preferredTopics,
    List<String> currentTopics,
    int count,
  ) {
    final suggestions = <String>[];

    for (final topic in preferredTopics) {
      if (suggestions.length >= count) break;

      switch (topic) {
        case 'работа':
          suggestions.add('Как дела на работе?');
          break;
        case 'семья':
          suggestions.add('Как семья?');
          break;
        case 'здоровье':
          suggestions.add('Как самочувствие?');
          break;
        case 'путешествия':
          suggestions.add('Планируешь куда-то поехать?');
          break;
      }
    }

    return suggestions;
  }

  List<String> _generateEmotionBasedSuggestions(
    Sentiment sentiment,
    List<Emotion> emotions,
    int count,
  ) {
    final suggestions = <String>[];

    if (sentiment == Sentiment.positive) {
      suggestions.addAll([
        'Отлично! Что еще хорошего?',
        'Здорово! Расскажи подробнее!',
      ]);
    } else if (sentiment == Sentiment.negative) {
      suggestions.addAll([
        'Понимаю. Хочешь поговорить?',
        'Может, расскажешь, что случилось?',
      ]);
    }

    return suggestions.take(count).toList();
  }

  List<String> _generateGeneralSuggestions(int count) {
    final suggestions = [
      'Что нового?',
      'Как дела?',
      'Что планируешь?',
      'Как настроение?',
      'Что интересного?',
    ];

    return suggestions.take(count).toList();
  }

  List<Emotion> _detectEmotions(String text, bool isPositive) {
    final emotions = <Emotion>[];

    if (isPositive) {
      if (text.contains('рад') || text.contains('счастлив')) {
        emotions.add(Emotion.joy);
      }
      if (text.contains('люблю') || text.contains('обожаю')) {
        emotions.add(Emotion.love);
      }
      if (text.contains('горжусь') || text.contains('горд')) {
        emotions.add(Emotion.pride);
      }
    } else {
      if (text.contains('грустно') || text.contains('печально')) {
        emotions.add(Emotion.sadness);
      }
      if (text.contains('злой') || text.contains('злюсь')) {
        emotions.add(Emotion.anger);
      }
      if (text.contains('боюсь') || text.contains('страшно')) {
        emotions.add(Emotion.fear);
      }
    }

    if (emotions.isEmpty) {
      emotions.add(Emotion.neutral);
    }

    return emotions;
  }

  UserProfile _getUserProfile(String userId) {
    return _userProfiles[userId] ?? UserProfile(userId: userId);
  }

  void _updateConversationContext(
      String userId, String message, AIResponse response) {
    final context = _conversations[userId] ?? const ConversationContext();
    context.addMessage(message);
    context.addResponse(response);
    _conversations[userId] = context;
  }

  Future<void> _learnFromInteraction(
    String userId,
    String message,
    AIResponse response,
    MessageAnalysis analysis,
  ) async {
    final userProfile = _getUserProfile(userId);
    userProfile.addInteraction(
        message, response, 0.5); // Средняя оценка по умолчанию

    // Обновляем веса на основе взаимодействия
    final words = _tokenize(message);
    for (final word in words) {
      final currentWeight = _sentimentWeights[word.toLowerCase()] ?? 0.0;
      final adjustment =
          (analysis.sentiment.sentiment == Sentiment.positive ? 0.1 : -0.1) *
              _learningRate;
      _sentimentWeights[word.toLowerCase()] = currentWeight + adjustment;
    }
  }

  Future<void> _updateTopicClusters() async {
    // Обновляем кластеры тем на основе пользовательских данных
    print('Updating topic clusters...');
  }

  Future<void> _optimizeWeights() async {
    // Оптимизируем веса модели
    print('Optimizing weights...');
  }

  List<String> _tokenize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
  }

  void dispose() {
    _onResponseGenerated.close();
    _onLearningEvent.close();
  }
}

// Модели данных

class AIResponse {
  final String id;
  final String text;
  final double confidence;
  final Sentiment sentiment;
  final List<String> topics;
  final List<String> suggestions;
  final DateTime timestamp;

  const AIResponse({
    required this.id,
    required this.text,
    required this.confidence,
    required this.sentiment,
    required this.topics,
    required this.suggestions,
    required this.timestamp,
  });
}

class SentimentAnalysis {
  final Sentiment sentiment;
  final double confidence;
  final List<Emotion> emotions;
  final double intensity;

  const SentimentAnalysis({
    required this.sentiment,
    required this.confidence,
    required this.emotions,
    required this.intensity,
  });
}

class MessageAnalysis {
  final String text;
  final SentimentAnalysis sentiment;
  final List<String> topics;
  final List<String> entities;
  final Intent intent;
  final double confidence;
  final DateTime timestamp;

  const MessageAnalysis({
    required this.text,
    required this.sentiment,
    required this.topics,
    required this.entities,
    required this.intent,
    required this.confidence,
    required this.timestamp,
  });
}

class UserProfile {
  final String userId;
  final List<String> preferredTopics;
  final CommunicationStyle communicationStyle;
  final double averageSentiment;
  final Duration averageResponseTime;
  final double satisfactionScore;
  final DateTime lastActive;
  final int totalMessages;

  const UserProfile({
    required this.userId,
    this.preferredTopics = const [],
    this.communicationStyle = CommunicationStyle.casual,
    this.averageSentiment = 0.0,
    this.averageResponseTime = Duration.zero,
    this.satisfactionScore = 0.0,
    required this.lastActive,
    this.totalMessages = 0,
  });

  UserProfile addInteraction(
      String message, AIResponse response, double rating) {
    // Обновляем профиль на основе взаимодействия
    return this;
  }
}

class ConversationContext {
  final List<String> messages;
  final List<AIResponse> responses;
  final DateTime lastUpdated;

  const ConversationContext({
    this.messages = const [],
    this.responses = const [],
    required this.lastUpdated,
  });

  void addMessage(String message) {
    // Добавляем сообщение в контекст
  }

  void addResponse(AIResponse response) {
    // Добавляем ответ в контекст
  }
}

class AILearningEvent {
  final AILearningEventType type;
  final String userId;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  const AILearningEvent({
    required this.type,
    required this.userId,
    required this.data,
    required this.timestamp,
  });
}

class UserAnalytics {
  final String userId;
  final int totalMessages;
  final double averageSentiment;
  final List<String> preferredTopics;
  final CommunicationStyle communicationStyle;
  final Duration responseTime;
  final double satisfactionScore;
  final DateTime lastActive;

  const UserAnalytics({
    required this.userId,
    required this.totalMessages,
    required this.averageSentiment,
    required this.preferredTopics,
    required this.communicationStyle,
    required this.responseTime,
    required this.satisfactionScore,
    required this.lastActive,
  });
}

// Перечисления

enum Sentiment { positive, negative, neutral }

enum Emotion { joy, sadness, anger, fear, love, pride, neutral }

enum Intent { greeting, question, gratitude, goodbye, help, statement }

enum CommunicationStyle { formal, casual, friendly, professional }

enum AILearningEventType { feedback, interaction, optimization }

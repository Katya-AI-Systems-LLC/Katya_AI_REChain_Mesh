import 'dart:async';
import 'package:uuid/uuid.dart';

/// Сервис новостей и контента для супераппа
class NewsService {
  static final NewsService _instance = NewsService._internal();
  factory NewsService() => _instance;
  static NewsService get instance => _instance;
  NewsService._internal();

  final StreamController<NewsArticle> _onArticlePublished =
      StreamController.broadcast();
  final StreamController<UserReading> _onReadingEvent =
      StreamController.broadcast();

  // Данные
  final Map<String, NewsArticle> _articles = {};
  final Map<String, NewsCategory> _categories = {};
  final Map<String, List<String>> _userPreferences = {};
  final Map<String, List<UserReading>> _readingHistory = {};

  Stream<NewsArticle> get onArticlePublished => _onArticlePublished.stream;
  Stream<UserReading> get onReadingEvent => _onReadingEvent.stream;

  /// Инициализация сервиса
  Future<void> initialize() async {
    print('Initializing News Service...');

    await _loadCategories();
    await _loadDefaultArticles();

    print('News Service initialized');
  }

  /// Публикация новостной статьи
  Future<NewsArticle> publishArticle({
    required String title,
    required String content,
    required String authorId,
    required NewsCategory category,
    List<String>? tags,
    String? imageUrl,
  }) async {
    final article = NewsArticle(
      id: const Uuid().v4(),
      title: title,
      content: content,
      authorId: authorId,
      category: category,
      tags: tags ?? [],
      imageUrl: imageUrl,
      publishedAt: DateTime.now(),
      views: 0,
      likes: 0,
      isPublished: true,
    );

    _articles[article.id] = article;
    _onArticlePublished.add(article);

    return article;
  }

  /// Получение персонализированной ленты
  Future<List<NewsArticle>> getPersonalizedFeed({
    required String userId,
    int limit = 20,
  }) async {
    final preferences = _getUserPreferences(userId);
    final articles = _articles.values.where((a) => a.isPublished).toList();

    // Сортировка по релевантности
    articles.sort((a, b) {
      final aRelevance = _calculateRelevance(a, preferences);
      final bRelevance = _calculateRelevance(b, preferences);
      return bRelevance.compareTo(aRelevance);
    });

    return articles.take(limit).toList();
  }

  /// Отметка прочтения статьи
  Future<void> markAsRead({
    required String userId,
    required String articleId,
  }) async {
    final history = _readingHistory[userId] ?? [];
    history.add(UserReading(
      articleId: articleId,
      readAt: DateTime.now(),
      readDuration: Duration.zero,
    ));
    _readingHistory[userId] = history;

    final article = _articles[articleId];
    if (article != null) {
      _articles[articleId] = article.copyWith(views: article.views + 1);
    }

    _onReadingEvent.add(UserReading(
      articleId: articleId,
      readAt: DateTime.now(),
      readDuration: Duration.zero,
    ));
  }

  /// Поиск статей
  Future<List<NewsArticle>> searchArticles({
    required String query,
    NewsCategory? category,
    int limit = 20,
  }) async {
    final lowerQuery = query.toLowerCase();

    return _articles.values
        .where((a) => a.isPublished)
        .where((a) {
          if (category != null && a.category != category) return false;
          return a.title.toLowerCase().contains(lowerQuery) ||
              a.content.toLowerCase().contains(lowerQuery) ||
              a.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
        })
        .take(limit)
        .toList();
  }

  /// Получение популярных статей
  Future<List<NewsArticle>> getPopularArticles({
    required int days,
    int limit = 20,
  }) async {
    final cutoff = DateTime.now().subtract(Duration(days: days));

    final articles = _articles.values
        .where((a) => a.isPublished && a.publishedAt.isAfter(cutoff))
        .toList()
      ..sort((a, b) => b.views.compareTo(a.views));

    return articles.take(limit).toList();
  }

  /// Получение категорий
  List<NewsCategory> getCategories() {
    return _categories.values.toList();
  }

  // Приватные методы

  Future<void> _loadCategories() async {
    final categories = NewsCategory.values;
    for (final category in categories) {
      _categories[category.name] = category;
    }
  }

  Future<void> _loadDefaultArticles() async {
    final articles = [
      NewsArticle(
        id: 'article_1',
        title: 'Mesh-сеть: будущее коммуникаций',
        content:
            'Mesh-сети представляют революционный подход к коммуникациям...',
        authorId: 'author_1',
        category: NewsCategory.technology,
        tags: ['mesh', 'технологии', 'будущее'],
        publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
        views: 150,
        likes: 25,
        isPublished: true,
      ),
      NewsArticle(
        id: 'article_2',
        title: 'AI в повседневной жизни',
        content:
            'Искусственный интеллект становится неотъемлемой частью нашей жизни...',
        authorId: 'author_2',
        category: NewsCategory.technology,
        tags: ['ai', 'искусственный интеллект'],
        publishedAt: DateTime.now().subtract(const Duration(hours: 5)),
        views: 200,
        likes: 30,
        isPublished: true,
      ),
    ];

    for (final article in articles) {
      _articles[article.id] = article;
    }
  }

  List<String> _getUserPreferences(String userId) {
    return _userPreferences[userId] ?? [];
  }

  double _calculateRelevance(NewsArticle article, List<String> preferences) {
    double score = 0.0;

    // Бонус за популярность
    score += (article.views / 1000.0) * 0.3;
    score += (article.likes / 100.0) * 0.2;

    // Бонус за недавность
    final hoursSincePublished =
        DateTime.now().difference(article.publishedAt).inHours;
    if (hoursSincePublished < 24) {
      score += 0.5;
    } else if (hoursSincePublished < 168) {
      // неделя
      score += 0.3;
    }

    return score;
  }

  void dispose() {
    _onArticlePublished.close();
    _onReadingEvent.close();
  }
}

// Модели данных

class NewsArticle {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final NewsCategory category;
  final List<String> tags;
  final String? imageUrl;
  final DateTime publishedAt;
  final int views;
  final int likes;
  final bool isPublished;

  const NewsArticle({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.category,
    required this.tags,
    this.imageUrl,
    required this.publishedAt,
    required this.views,
    required this.likes,
    required this.isPublished,
  });

  NewsArticle copyWith({
    String? id,
    String? title,
    String? content,
    String? authorId,
    NewsCategory? category,
    List<String>? tags,
    String? imageUrl,
    DateTime? publishedAt,
    int? views,
    int? likes,
    bool? isPublished,
  }) {
    return NewsArticle(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      imageUrl: imageUrl ?? this.imageUrl,
      publishedAt: publishedAt ?? this.publishedAt,
      views: views ?? this.views,
      likes: likes ?? this.likes,
      isPublished: isPublished ?? this.isPublished,
    );
  }
}

class NewsCategory {
  final String id;
  final String name;
  final String description;
  final String icon;

  const NewsCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });

  static NewsCategory get technology => const NewsCategory(
        id: 'technology',
        name: 'Технологии',
        description: 'Новости о технологиях',
        icon: '💻',
      );

  static NewsCategory get business => const NewsCategory(
        id: 'business',
        name: 'Бизнес',
        description: 'Бизнес новости',
        icon: '💼',
      );

  static NewsCategory get science => const NewsCategory(
        id: 'science',
        name: 'Наука',
        description: 'Научные новости',
        icon: '🔬',
      );

  static NewsCategory get entertainment => const NewsCategory(
        id: 'entertainment',
        name: 'Развлечения',
        description: 'Развлекательный контент',
        icon: '🎬',
      );

  static List<NewsCategory> get values => [
        technology,
        business,
        science,
        entertainment,
      ];
}

class UserReading {
  final String articleId;
  final DateTime readAt;
  final Duration readDuration;

  const UserReading({
    required this.articleId,
    required this.readAt,
    required this.readDuration,
  });
}

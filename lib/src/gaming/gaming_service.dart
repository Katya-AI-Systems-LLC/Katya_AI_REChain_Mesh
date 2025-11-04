import 'dart:async';
import 'dart:math';

/// Сервис геймификации - достижения, уровни, награды
class GamingService {
  static final GamingService _instance = GamingService._internal();
  factory GamingService() => _instance;
  static GamingService get instance => _instance;
  GamingService._internal();

  final StreamController<Achievement> _onAchievementUnlocked =
      StreamController.broadcast();
  final StreamController<LevelUp> _onLevelUp = StreamController.broadcast();
  final StreamController<Reward> _onRewardEarned = StreamController.broadcast();

  // Данные
  final Map<String, UserProgress> _userProgress = {};
  final Map<String, List<Achievement>> _userAchievements = {};
  final Map<String, List<Reward>> _userRewards = {};
  final Map<String, Achievement> _achievements = {};
  final Map<String, Reward> _rewards = {};

  Stream<Achievement> get onAchievementUnlocked =>
      _onAchievementUnlocked.stream;
  Stream<LevelUp> get onLevelUp => _onLevelUp.stream;
  Stream<Reward> get onRewardEarned => _onRewardEarned.stream;

  /// Инициализация сервиса
  Future<void> initialize() async {
    print('Initializing Gaming Service...');
    await _loadAchievements();
    await _loadRewards();
    print('Gaming Service initialized');
  }

  /// Получение прогресса пользователя
  UserProgress getUserProgress(String userId) {
    return _userProgress[userId] ??
        UserProgress(
          userId: userId,
          level: 1,
          experience: 0,
          totalExperience: 0,
          coins: 0,
          gems: 0,
          streak: 0,
          lastActivity: DateTime.now(),
        );
  }

  /// Добавление опыта
  Future<void> addExperience({
    required String userId,
    required int amount,
    required String source,
    String? description,
  }) async {
    final progress = getUserProgress(userId);
    final newTotalExp = progress.totalExperience + amount;
    final newLevel = _calculateLevel(newTotalExp);

    final updatedProgress = progress.copyWith(
      experience: newTotalExp - _getExperienceForLevel(newLevel),
      totalExperience: newTotalExp,
      level: newLevel,
      lastActivity: DateTime.now(),
    );

    _userProgress[userId] = updatedProgress;

    // Проверяем повышение уровня
    if (newLevel > progress.level) {
      final levelUp = LevelUp(
        userId: userId,
        oldLevel: progress.level,
        newLevel: newLevel,
        timestamp: DateTime.now(),
      );
      _onLevelUp.add(levelUp);
    }

    // Проверяем достижения
    await _checkAchievements(userId, source, amount);
  }

  /// Добавление монет
  Future<void> addCoins({
    required String userId,
    required int amount,
    required String source,
  }) async {
    final progress = getUserProgress(userId);
    final updatedProgress = progress.copyWith(
      coins: progress.coins + amount,
      lastActivity: DateTime.now(),
    );

    _userProgress[userId] = updatedProgress;

    // Проверяем достижения
    await _checkAchievements(userId, source, amount);
  }

  /// Добавление драгоценных камней
  Future<void> addGems({
    required String userId,
    required int amount,
    required String source,
  }) async {
    final progress = getUserProgress(userId);
    final updatedProgress = progress.copyWith(
      gems: progress.gems + amount,
      lastActivity: DateTime.now(),
    );

    _userProgress[userId] = updatedProgress;
  }

  /// Обновление серии (streak)
  Future<void> updateStreak({
    required String userId,
    required int days,
  }) async {
    final progress = getUserProgress(userId);
    final updatedProgress = progress.copyWith(
      streak: days,
      lastActivity: DateTime.now(),
    );

    _userProgress[userId] = updatedProgress;

    // Проверяем достижения
    await _checkAchievements(userId, 'streak', days);
  }

  /// Получение достижений пользователя
  List<Achievement> getUserAchievements(String userId) {
    return _userAchievements[userId] ?? [];
  }

  /// Получение доступных достижений
  List<Achievement> getAvailableAchievements() {
    return _achievements.values.toList();
  }

  /// Получить все доступные награды
  List<Reward> getAvailableRewards() {
    return _rewards.values.toList();
  }

  /// Получение наград пользователя
  List<Reward> getUserRewards(String userId) {
    return _userRewards[userId] ?? [];
  }

  /// Покупка награды
  Future<bool> purchaseReward({
    required String userId,
    required String rewardId,
  }) async {
    final reward = _rewards[rewardId];
    if (reward == null) {
      return false;
    }

    final progress = getUserProgress(userId);

    // Проверяем, достаточно ли ресурсов
    if (reward.costType == RewardCostType.coins &&
        progress.coins < reward.cost) {
      return false;
    }
    if (reward.costType == RewardCostType.gems && progress.gems < reward.cost) {
      return false;
    }

    // Списываем ресурсы
    final updatedProgress = progress.copyWith(
      coins: reward.costType == RewardCostType.coins
          ? progress.coins - reward.cost
          : progress.coins,
      gems: reward.costType == RewardCostType.gems
          ? progress.gems - reward.cost
          : progress.gems,
    );

    _userProgress[userId] = updatedProgress;

    // Добавляем награду
    final userRewards = _userRewards[userId] ?? [];
    userRewards.add(reward);
    _userRewards[userId] = userRewards;

    _onRewardEarned.add(reward);
    return true;
  }

  /// Получение статистики
  Map<String, dynamic> getStatistics() {
    final totalUsers = _userProgress.length;
    final totalAchievements = _achievements.length;
    final totalRewards = _rewards.length;

    final averageLevel = totalUsers > 0
        ? _userProgress.values.map((p) => p.level).reduce((a, b) => a + b) /
            totalUsers
        : 0.0;

    return {
      'total_users': totalUsers,
      'total_achievements': totalAchievements,
      'total_rewards': totalRewards,
      'average_level': averageLevel,
    };
  }

  // Приватные методы

  Future<void> _loadAchievements() async {
    final achievements = [
      const Achievement(
        id: 'first_message',
        title: 'Первое сообщение',
        description: 'Отправьте ваше первое сообщение',
        icon: '💬',
        category: AchievementCategory.communication,
        requirement: AchievementRequirement.messagesSent,
        requirementValue: 1,
        reward: AchievementReward(
          experience: 10,
          coins: 5,
          gems: 0,
        ),
      ),
      const Achievement(
        id: 'social_butterfly',
        title: 'Социальная бабочка',
        description: 'Добавьте 10 друзей',
        icon: '🦋',
        category: AchievementCategory.social,
        requirement: AchievementRequirement.friendsAdded,
        requirementValue: 10,
        reward: AchievementReward(
          experience: 50,
          coins: 25,
          gems: 2,
        ),
      ),
      const Achievement(
        id: 'mesh_master',
        title: 'Мастер Mesh',
        description: 'Отправьте 100 сообщений через mesh-сеть',
        icon: '🌐',
        category: AchievementCategory.network,
        requirement: AchievementRequirement.meshMessages,
        requirementValue: 100,
        reward: AchievementReward(
          experience: 100,
          coins: 50,
          gems: 5,
        ),
      ),
      const Achievement(
        id: 'voting_champion',
        title: 'Чемпион голосований',
        description: 'Создайте 5 голосований',
        icon: '🗳️',
        category: AchievementCategory.voting,
        requirement: AchievementRequirement.pollsCreated,
        requirementValue: 5,
        reward: AchievementReward(
          experience: 75,
          coins: 30,
          gems: 3,
        ),
      ),
      const Achievement(
        id: 'streak_master',
        title: 'Мастер серий',
        description: 'Войдите в приложение 7 дней подряд',
        icon: '🔥',
        category: AchievementCategory.activity,
        requirement: AchievementRequirement.dailyStreak,
        requirementValue: 7,
        reward: AchievementReward(
          experience: 200,
          coins: 100,
          gems: 10,
        ),
      ),
    ];

    for (final achievement in achievements) {
      _achievements[achievement.id] = achievement;
    }
  }

  Future<void> _loadRewards() async {
    final rewards = [
      const Reward(
        id: 'avatar_frame_1',
        title: 'Рамка аватара "Космос"',
        description: 'Красивая рамка для вашего аватара',
        icon: '🖼️',
        category: RewardCategory.cosmetic,
        cost: 50,
        costType: RewardCostType.coins,
      ),
      const Reward(
        id: 'theme_dark',
        title: 'Темная тема',
        description: 'Стильная темная тема интерфейса',
        icon: '🌙',
        category: RewardCategory.theme,
        cost: 100,
        costType: RewardCostType.coins,
      ),
      const Reward(
        id: 'ai_personality',
        title: 'Персонализация AI',
        description: 'Настройте характер вашего AI-ассистента',
        icon: '🤖',
        category: RewardCategory.ai,
        cost: 5,
        costType: RewardCostType.gems,
      ),
      const Reward(
        id: 'premium_features',
        title: 'Премиум функции',
        description: 'Доступ к расширенным возможностям',
        icon: '⭐',
        category: RewardCategory.premium,
        cost: 10,
        costType: RewardCostType.gems,
      ),
    ];

    for (final reward in rewards) {
      _rewards[reward.id] = reward;
    }
  }

  Future<void> _checkAchievements(
      String userId, String source, int value) async {
    final userAchievements = _userAchievements[userId] ?? [];
    final unlockedAchievementIds = userAchievements.map((a) => a.id).toSet();

    for (final achievement in _achievements.values) {
      if (unlockedAchievementIds.contains(achievement.id)) {
        continue;
      }

      bool shouldUnlock = false;

      switch (achievement.requirement) {
        case AchievementRequirement.messagesSent:
          if (source == 'message') shouldUnlock = true;
          break;
        case AchievementRequirement.friendsAdded:
          if (source == 'friend_added') shouldUnlock = true;
          break;
        case AchievementRequirement.meshMessages:
          if (source == 'mesh_message') shouldUnlock = true;
          break;
        case AchievementRequirement.pollsCreated:
          if (source == 'poll_created') shouldUnlock = true;
          break;
        case AchievementRequirement.dailyStreak:
          if (source == 'streak' && value >= achievement.requirementValue) {
            shouldUnlock = true;
          }
          break;
      }

      if (shouldUnlock) {
        userAchievements.add(achievement);
        _userAchievements[userId] = userAchievements;

        // Выдаем награду
        final progress = getUserProgress(userId);
        final updatedProgress = progress.copyWith(
          experience: progress.experience + achievement.reward.experience,
          totalExperience:
              progress.totalExperience + achievement.reward.experience,
          coins: progress.coins + achievement.reward.coins,
          gems: progress.gems + achievement.reward.gems,
        );
        _userProgress[userId] = updatedProgress;

        _onAchievementUnlocked.add(achievement);
      }
    }
  }

  int _calculateLevel(int totalExperience) {
    // Формула: level = sqrt(totalExperience / 100) + 1
    return (sqrt(totalExperience / 100) + 1).floor();
  }

  int _getExperienceForLevel(int level) {
    // Формула: exp = (level - 1)^2 * 100
    return ((level - 1) * (level - 1) * 100);
  }

  void dispose() {
    _onAchievementUnlocked.close();
    _onLevelUp.close();
    _onRewardEarned.close();
  }
}

// Модели данных

class UserProgress {
  final String userId;
  final int level;
  final int experience;
  final int totalExperience;
  final int coins;
  final int gems;
  final int streak;
  final DateTime lastActivity;

  const UserProgress({
    required this.userId,
    required this.level,
    required this.experience,
    required this.totalExperience,
    required this.coins,
    required this.gems,
    required this.streak,
    required this.lastActivity,
  });

  UserProgress copyWith({
    String? userId,
    int? level,
    int? experience,
    int? totalExperience,
    int? coins,
    int? gems,
    int? streak,
    DateTime? lastActivity,
  }) {
    return UserProgress(
      userId: userId ?? this.userId,
      level: level ?? this.level,
      experience: experience ?? this.experience,
      totalExperience: totalExperience ?? this.totalExperience,
      coins: coins ?? this.coins,
      gems: gems ?? this.gems,
      streak: streak ?? this.streak,
      lastActivity: lastActivity ?? this.lastActivity,
    );
  }
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final AchievementCategory category;
  final AchievementRequirement requirement;
  final int requirementValue;
  final AchievementReward reward;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    required this.requirement,
    required this.requirementValue,
    required this.reward,
  });
}

enum AchievementCategory {
  communication,
  social,
  network,
  voting,
  activity,
  exploration,
}

enum AchievementRequirement {
  messagesSent,
  friendsAdded,
  meshMessages,
  pollsCreated,
  dailyStreak,
  levelReached,
}

class AchievementReward {
  final int experience;
  final int coins;
  final int gems;

  const AchievementReward({
    required this.experience,
    required this.coins,
    required this.gems,
  });
}

class LevelUp {
  final String userId;
  final int oldLevel;
  final int newLevel;
  final DateTime timestamp;

  const LevelUp({
    required this.userId,
    required this.oldLevel,
    required this.newLevel,
    required this.timestamp,
  });
}

class Reward {
  final String id;
  final String title;
  final String description;
  final String icon;
  final RewardCategory category;
  final int cost;
  final RewardCostType costType;

  const Reward({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    required this.cost,
    required this.costType,
  });
}

enum RewardCategory {
  cosmetic,
  theme,
  ai,
  premium,
  utility,
}

enum RewardCostType {
  coins,
  gems,
}

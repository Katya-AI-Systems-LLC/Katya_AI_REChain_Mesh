import 'dart:async';
import 'dart:math';

/// Сервис социальных функций - профили, друзья, группы
class SocialService {
  static final SocialService _instance = SocialService._internal();
  factory SocialService() => _instance;
  static SocialService get instance => _instance;
  SocialService._internal();

  final StreamController<UserProfile> _onProfileUpdated =
      StreamController.broadcast();
  final StreamController<Friendship> _onFriendshipChanged =
      StreamController.broadcast();
  final StreamController<Group> _onGroupUpdated = StreamController.broadcast();

  // Данные
  final Map<String, UserProfile> _profiles = {};
  final Map<String, List<Friendship>> _friendships = {};
  final Map<String, Group> _groups = {};
  final Map<String, List<String>> _groupMembers = {};
  String? _currentUserId;

  String? get currentUserId => _currentUserId;

  /// Инициализация сервиса
  Future<void> initialize() async {
    print('Initializing Social Service...');
    _currentUserId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    await _loadSampleData();
    print('Social Service initialized');
  }

  /// Создание профиля пользователя
  Future<UserProfile> createProfile({
    required String userId,
    required String username,
    String? displayName,
    String? bio,
    String? avatarUrl,
    List<String>? interests,
  }) async {
    final profile = UserProfile(
      userId: userId,
      username: username,
      displayName: displayName ?? username,
      bio: bio ?? '',
      avatarUrl: avatarUrl,
      interests: interests ?? [],
      isOnline: true,
      lastSeen: DateTime.now(),
      createdAt: DateTime.now(),
      followersCount: 0,
      followingCount: 0,
      postsCount: 0,
    );

    _profiles[userId] = profile;
    _onProfileUpdated.add(profile);

    return profile;
  }

  /// Обновление профиля
  Future<UserProfile> updateProfile({
    required String userId,
    String? displayName,
    String? bio,
    String? avatarUrl,
    List<String>? interests,
  }) async {
    final currentProfile = _profiles[userId];
    if (currentProfile == null) {
      throw Exception('Profile not found');
    }

    final updatedProfile = currentProfile.copyWith(
      displayName: displayName ?? currentProfile.displayName,
      bio: bio ?? currentProfile.bio,
      avatarUrl: avatarUrl ?? currentProfile.avatarUrl,
      interests: interests ?? currentProfile.interests,
    );

    _profiles[userId] = updatedProfile;
    _onProfileUpdated.add(updatedProfile);

    return updatedProfile;
  }

  /// Поиск пользователей
  Future<List<UserProfile>> searchUsers({
    required String query,
    int limit = 20,
  }) async {
    final lowerQuery = query.toLowerCase();

    return _profiles.values
        .where((profile) =>
            profile.username.toLowerCase().contains(lowerQuery) ||
            profile.displayName.toLowerCase().contains(lowerQuery) ||
            profile.bio.toLowerCase().contains(lowerQuery))
        .take(limit)
        .toList();
  }

  /// Отправка запроса в друзья
  Future<Friendship> sendFriendRequest({
    required String fromUserId,
    required String toUserId,
  }) async {
    final friendship = Friendship(
      id: _generateId(),
      fromUserId: fromUserId,
      toUserId: toUserId,
      status: FriendshipStatus.pending,
      createdAt: DateTime.now(),
    );

    final userFriendships = _friendships[fromUserId] ?? [];
    userFriendships.add(friendship);
    _friendships[fromUserId] = userFriendships;

    _onFriendshipChanged.add(friendship);
    return friendship;
  }

  /// Принятие запроса в друзья
  Future<void> acceptFriendRequest(String friendshipId) async {
    for (final friendships in _friendships.values) {
      for (final friendship in friendships) {
        if (friendship.id == friendshipId) {
          friendships[friendships.indexOf(friendship)] = friendship.copyWith(
            status: FriendshipStatus.accepted,
          );
          _onFriendshipChanged.add(friendship.copyWith(
            status: FriendshipStatus.accepted,
          ));
          break;
        }
      }
    }
  }

  /// Получение списка друзей
  Future<List<UserProfile>> getFriends(String userId) async {
    final friendships = _friendships[userId] ?? [];
    final friendIds = friendships
        .where((f) => f.status == FriendshipStatus.accepted)
        .map((f) => f.fromUserId == userId ? f.toUserId : f.fromUserId)
        .toList();

    return friendIds
        .map((id) => _profiles[id])
        .where((profile) => profile != null)
        .cast<UserProfile>()
        .toList();
  }

  /// Создание группы
  Future<Group> createGroup({
    required String name,
    required String description,
    required String creatorId,
    String? avatarUrl,
    GroupType type = GroupType.public,
  }) async {
    final groupId = _generateId();

    final group = Group(
      id: groupId,
      name: name,
      description: description,
      creatorId: creatorId,
      avatarUrl: avatarUrl,
      type: type,
      membersCount: 1,
      createdAt: DateTime.now(),
      lastActivity: DateTime.now(),
    );

    _groups[groupId] = group;
    _groupMembers[groupId] = [creatorId];
    _onGroupUpdated.add(group);

    return group;
  }

  /// Присоединение к группе
  Future<void> joinGroup({
    required String groupId,
    required String userId,
  }) async {
    final group = _groups[groupId];
    if (group == null) {
      throw Exception('Group not found');
    }

    final members = _groupMembers[groupId] ?? [];
    if (!members.contains(userId)) {
      members.add(userId);
      _groupMembers[groupId] = members;

      _groups[groupId] = group.copyWith(
        membersCount: members.length,
        lastActivity: DateTime.now(),
      );
      _onGroupUpdated.add(_groups[groupId]!);
    }
  }

  /// Получение групп пользователя
  Future<List<Group>> getUserGroups(String userId) async {
    return _groups.values
        .where((group) => _groupMembers[group.id]?.contains(userId) ?? false)
        .toList();
  }

  /// Получение статистики
  Map<String, dynamic> getStatistics() {
    return {
      'total_profiles': _profiles.length,
      'total_friendships':
          _friendships.values.fold(0, (sum, list) => sum + list.length),
      'total_groups': _groups.length,
      'online_users': _profiles.values.where((p) => p.isOnline).length,
    };
  }

  // Приватные методы

  Future<void> _loadSampleData() async {
    // Создаем примеры профилей
    final profiles = [
      UserProfile(
        userId: 'user_1',
        username: 'alex_dev',
        displayName: 'Александр',
        bio: 'Flutter разработчик, любитель mesh-сетей',
        interests: ['flutter', 'bluetooth', 'ai'],
        isOnline: true,
        lastSeen: DateTime.now(),
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        followersCount: 150,
        followingCount: 200,
        postsCount: 45,
      ),
      UserProfile(
        userId: 'user_2',
        username: 'katya_ai',
        displayName: 'Катя AI',
        bio: 'Искусственный интеллект для mesh-сети',
        interests: ['ai', 'ml', 'nlp'],
        isOnline: true,
        lastSeen: DateTime.now(),
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        followersCount: 500,
        followingCount: 50,
        postsCount: 200,
      ),
      UserProfile(
        userId: 'user_3',
        username: 'mesh_master',
        displayName: 'Мастер Mesh',
        bio: 'Эксперт по mesh-сетям и криптографии',
        interests: ['mesh', 'crypto', 'security'],
        isOnline: false,
        lastSeen: DateTime.now().subtract(const Duration(hours: 2)),
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        followersCount: 300,
        followingCount: 100,
        postsCount: 80,
      ),
    ];

    for (final profile in profiles) {
      _profiles[profile.userId] = profile;
    }

    // Создаем примеры групп
    final groups = [
      Group(
        id: 'group_1',
        name: 'Flutter Developers',
        description: 'Сообщество Flutter разработчиков',
        creatorId: 'user_1',
        type: GroupType.public,
        membersCount: 25,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        lastActivity: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      Group(
        id: 'group_2',
        name: 'Mesh Network Enthusiasts',
        description: 'Любители mesh-сетей и оффлайн коммуникаций',
        creatorId: 'user_3',
        type: GroupType.public,
        membersCount: 15,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        lastActivity: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];

    for (final group in groups) {
      _groups[group.id] = group;
      _groupMembers[group.id] = ['user_1', 'user_2', 'user_3'];
    }
  }

  String _generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }

  void dispose() {
    _onProfileUpdated.close();
    _onFriendshipChanged.close();
    _onGroupUpdated.close();
  }
}

// Модели данных

class UserProfile {
  final String userId;
  final String username;
  final String displayName;
  final String bio;
  final String? avatarUrl;
  final List<String> interests;
  final bool isOnline;
  final DateTime lastSeen;
  final DateTime createdAt;
  final int followersCount;
  final int followingCount;
  final int postsCount;

  const UserProfile({
    required this.userId,
    required this.username,
    required this.displayName,
    required this.bio,
    this.avatarUrl,
    required this.interests,
    required this.isOnline,
    required this.lastSeen,
    required this.createdAt,
    required this.followersCount,
    required this.followingCount,
    required this.postsCount,
  });

  UserProfile copyWith({
    String? userId,
    String? username,
    String? displayName,
    String? bio,
    String? avatarUrl,
    List<String>? interests,
    bool? isOnline,
    DateTime? lastSeen,
    DateTime? createdAt,
    int? followersCount,
    int? followingCount,
    int? postsCount,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      interests: interests ?? this.interests,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      postsCount: postsCount ?? this.postsCount,
    );
  }
}

class Friendship {
  final String id;
  final String fromUserId;
  final String toUserId;
  final FriendshipStatus status;
  final DateTime createdAt;

  const Friendship({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.status,
    required this.createdAt,
  });

  Friendship copyWith({
    String? id,
    String? fromUserId,
    String? toUserId,
    FriendshipStatus? status,
    DateTime? createdAt,
  }) {
    return Friendship(
      id: id ?? this.id,
      fromUserId: fromUserId ?? this.fromUserId,
      toUserId: toUserId ?? this.toUserId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

enum FriendshipStatus {
  pending,
  accepted,
  rejected,
  blocked,
}

class Group {
  final String id;
  final String name;
  final String description;
  final String creatorId;
  final String? avatarUrl;
  final GroupType type;
  final int membersCount;
  final DateTime createdAt;
  final DateTime lastActivity;

  const Group({
    required this.id,
    required this.name,
    required this.description,
    required this.creatorId,
    this.avatarUrl,
    required this.type,
    required this.membersCount,
    required this.createdAt,
    required this.lastActivity,
  });

  Group copyWith({
    String? id,
    String? name,
    String? description,
    String? creatorId,
    String? avatarUrl,
    GroupType? type,
    int? membersCount,
    DateTime? createdAt,
    DateTime? lastActivity,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      creatorId: creatorId ?? this.creatorId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      type: type ?? this.type,
      membersCount: membersCount ?? this.membersCount,
      createdAt: createdAt ?? this.createdAt,
      lastActivity: lastActivity ?? this.lastActivity,
    );
  }
}

enum GroupType {
  public,
  private,
  secret,
}

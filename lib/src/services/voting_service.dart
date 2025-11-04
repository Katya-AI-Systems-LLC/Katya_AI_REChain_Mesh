import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'mesh_service_ble.dart';
import '../security/crypto_manager.dart';

/// Сервис голосований для управления опросами и голосами
class VotingService {
  static final VotingService _instance = VotingService._internal();
  factory VotingService() => _instance;
  static VotingService get instance => _instance;
  VotingService._internal();

  final StreamController<VotingPoll> _onPollCreated =
      StreamController.broadcast();
  final StreamController<Vote> _onVoteCasted = StreamController.broadcast();

  // Данные
  final Map<String, VotingPoll> _polls = {};
  final Map<String, List<Vote>> _votes = {};
  String? _currentUserId;

  Stream<VotingPoll> get onPollCreated => _onPollCreated.stream;
  Stream<Vote> get onVoteCasted => _onVoteCasted.stream;

  /// Инициализация сервиса
  Future<void> initialize() async {
    print('Initializing Voting Service...');
    _currentUserId = 'user_${DateTime.now().millisecondsSinceEpoch}';

    // Подписка на mesh-сообщения для синхронизации голосов
    final meshService = MeshServiceBLE.instance;
    meshService.onMessageReceived.listen(_handleMeshMessage);

    print('Voting Service initialized with mesh sync');
  }

  /// Обработка mesh-сообщений для синхронизации
  void _handleMeshMessage(MeshMessage message) {
    () async {
      try {
        final data = jsonDecode(message.message);

        if (data['type'] == 'voting_poll') {
          _handlePollSync(data);
        } else if (data['type'] == 'vote_cast') {
          await _handleVoteSync(data);
        }
      } catch (e) {
        print('Error handling mesh message: $e');
      }
    }();
  }

  /// Синхронизация голосования через mesh
  void _handlePollSync(Map<String, dynamic> data) {
    final pollId = data['pollId'] as String;
    final poll = VotingPoll.fromJson(data);

    if (!_polls.containsKey(pollId) ||
        poll.createdAt.isAfter(_polls[pollId]!.createdAt)) {
      _polls[pollId] = poll;
      _onPollCreated.add(poll);
      print('Poll synced from mesh: ${poll.title}');
    }
  }

  /// Синхронизация голоса через mesh
  Future<void> _handleVoteSync(Map<String, dynamic> data) async {
    // Optional signature verification
    final signature = data['signature'] as String?;
    final publicKey = data['publicKey'] as String?;
    final canonical = jsonEncode({
      'voteId': data['voteId'],
      'pollId': data['pollId'],
      'userId': data['userId'],
      'option': data['option'],
      'timestamp': data['timestamp'],
    });
    if (signature != null && publicKey != null) {
      final ok = await CryptoManager.verifyString(
        message: canonical,
        signatureBase64: signature,
        publicKeyBase64: publicKey,
      );
      if (!ok) {
        print('Dropping vote due to invalid signature');
        return;
      }
    }

    final vote = Vote(
      id: data['voteId'] as String,
      pollId: data['pollId'] as String,
      userId: data['userId'] as String,
      option: data['option'] as String,
      timestamp: DateTime.parse(data['timestamp'] as String),
    );

    // Проверяем, нет ли уже этого голоса
    final userVotes = _votes[vote.userId] ?? [];
    if (!userVotes.any((v) => v.id == vote.id)) {
      _votes[vote.userId] = userVotes..add(vote);

      // Обновляем голоса в опросе
      final poll = _polls[vote.pollId];
      if (poll != null) {
        final newVotes = Map<String, int>.from(poll.votes);
        newVotes[vote.option] = (newVotes[vote.option] ?? 0) + 1;

        _polls[vote.pollId] = VotingPoll(
          id: poll.id,
          title: poll.title,
          description: poll.description,
          options: poll.options,
          votes: newVotes,
          creatorId: poll.creatorId,
          createdAt: poll.createdAt,
          isActive: poll.isActive,
        );

        _onVoteCasted.add(vote);
        print('Vote synced from mesh: ${vote.option}');
      }
    }
  }

  /// Отправка голосования в mesh-сеть
  Future<void> _syncPollToMesh(VotingPoll poll) async {
    try {
      final meshService = MeshServiceBLE.instance;
      final data = {
        'type': 'voting_poll',
        'pollId': poll.id,
        'poll': poll.toJson(),
      };

      await meshService.sendMeshMessage('broadcast', jsonEncode(data));
    } catch (e) {
      print('Error syncing poll to mesh: $e');
    }
  }

  /// Отправка голоса в mesh-сеть
  Future<void> _syncVoteToMesh(Vote vote) async {
    try {
      final meshService = MeshServiceBLE.instance;
      final cm = CryptoManager.instance;
      final payload = {
        'type': 'vote_cast',
        'voteId': vote.id,
        'pollId': vote.pollId,
        'userId': vote.userId,
        'option': vote.option,
        'timestamp': vote.timestamp.toIso8601String(),
      };
      final canonical = jsonEncode({
        'voteId': vote.id,
        'pollId': vote.pollId,
        'userId': vote.userId,
        'option': vote.option,
        'timestamp': vote.timestamp.toIso8601String(),
      });
      final signature = await cm.signString(canonical);
      final pub = await cm.getPublicKeyBase64();
      final data = Map<String, dynamic>.from(payload)
        ..['signature'] = signature
        ..['publicKey'] = pub;

      await meshService.sendMeshMessage('broadcast', jsonEncode(data));
    } catch (e) {
      print('Error syncing vote to mesh: $e');
    }
  }

  /// Создание голосования
  Future<VotingPoll> createPoll({
    required String title,
    required String description,
    required List<String> options,
    required String creatorId,
  }) async {
    final pollId = _generateId();

    final poll = VotingPoll(
      id: pollId,
      title: title,
      description: description,
      options: options,
      votes: {for (final option in options) option: 0},
      creatorId: creatorId,
      createdAt: DateTime.now(),
      isActive: true,
    );

    _polls[pollId] = poll;
    _onPollCreated.add(poll);

    // Синхронизируем голосование в mesh-сеть
    await _syncPollToMesh(poll);

    return poll;
  }

  /// Получение списка голосований
  Future<List<VotingPoll>> getPolls({bool? activeOnly}) async {
    var polls = _polls.values.toList();

    if (activeOnly == true) {
      polls = polls.where((p) => p.isActive).toList();
    }

    polls.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return polls;
  }

  /// Голосование
  Future<void> vote({
    required String pollId,
    required String option,
  }) async {
    final poll = _polls[pollId];
    if (poll == null) {
      throw Exception('Poll not found');
    }

    if (!poll.isActive) {
      throw Exception('Poll is not active');
    }

    if (!poll.options.contains(option)) {
      throw Exception('Invalid option');
    }

    // Проверяем, не голосовал ли уже пользователь
    final userVotes = _votes[_currentUserId] ?? [];
    if (userVotes.any((v) => v.pollId == pollId)) {
      throw Exception('User has already voted');
    }

    final vote = Vote(
      id: _generateId(),
      pollId: pollId,
      userId: _currentUserId ?? 'anonymous',
      option: option,
      timestamp: DateTime.now(),
    );

    userVotes.add(vote);
    if (_currentUserId != null) {
      _votes[_currentUserId!] = userVotes;
    }

    poll.votes[option] = (poll.votes[option] ?? 0) + 1;
    _polls[pollId] = poll;

    _onVoteCasted.add(vote);

    // Синхронизируем голос в mesh-сеть для реального времени
    await _syncVoteToMesh(vote);
  }

  /// Получение результатов голосования
  Future<VotingResults> getResults(String pollId) async {
    final poll = _polls[pollId];
    if (poll == null) {
      throw Exception('Poll not found');
    }

    final totalVotes = poll.votes.values.fold(0, (sum, count) => sum + count);

    return VotingResults(
      pollId: pollId,
      pollTitle: poll.title,
      totalVotes: totalVotes,
      optionVotes: poll.votes,
      percentages: _calculatePercentages(poll.votes, totalVotes),
    );
  }

  /// Завершение голосования по majority-consensus оффлайн
  Future<void> finalizeByMajority(String pollId, {int quorum = 1}) async {
    final poll = _polls[pollId];
    if (poll == null) throw Exception('Poll not found');
    final total = poll.votes.values.fold(0, (s, v) => s + v);
    if (total < quorum) {
      throw Exception('Quorum not reached');
    }
    // Majority option
    String majority = poll.options.first;
    int best = -1;
    poll.votes.forEach((k, v) {
      if (v > best) {
        best = v;
        majority = k;
      }
    });
    // Mark inactive; can be synced later when online
    poll.isActive = false;
    _polls[pollId] = poll;
    print('Poll $pollId finalized by majority: $majority ($best)');
  }

  /// Пост-онлайн синхронизация результатов (стаб)
  Future<void> postOnlineSync(String pollId, Future<Map<String, dynamic>> Function() fetchAuthoritative) async {
    try {
      final authoritative = await fetchAuthoritative();
      // Merge strategy: trust authoritative tally if signature/proof is valid (out of scope here)
      final poll = _polls[pollId];
      if (poll == null) return;
      final newVotes = Map<String, int>.from(authoritative['votes'] as Map);
      _polls[pollId] = VotingPoll(
        id: poll.id,
        title: poll.title,
        description: poll.description,
        options: poll.options,
        votes: newVotes,
        creatorId: poll.creatorId,
        createdAt: poll.createdAt,
        isActive: false,
      );
    } catch (e) {
      print('postOnlineSync failed: $e');
    }
  }

  /// Закрытие голосования
  Future<void> closePoll(String pollId) async {
    final poll = _polls[pollId];
    if (poll == null) {
      throw Exception('Poll not found');
    }

    poll.isActive = false;
    _polls[pollId] = poll;
  }

  /// Получение статистики
  Map<String, dynamic> getStatistics() {
    final activePolls = _polls.values.where((p) => p.isActive).length;
    final totalVotes =
        _votes.values.fold(0, (sum, votes) => sum + votes.length);

    return {
      'total_polls': _polls.length,
      'active_polls': activePolls,
      'total_votes': totalVotes,
    };
  }

  // Приватные методы

  Map<String, double> _calculatePercentages(Map<String, int> votes, int total) {
    if (total == 0) {
      return {for (final option in votes.keys) option: 0.0};
    }

    return {
      for (final entry in votes.entries) entry.key: (entry.value / total) * 100
    };
  }

  String _generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }

  void dispose() {
    _onPollCreated.close();
    _onVoteCasted.close();
  }

  /// Очистка локальных данных (для демо/скринкаста)
  void clearLocal() {
    _polls.clear();
    _votes.clear();
  }
}

// Модели данных

class VotingPoll {
  final String id;
  final String title;
  final String description;
  final List<String> options;
  final Map<String, int> votes;
  final String creatorId;
  final DateTime createdAt;
  bool isActive;

  VotingPoll({
    required this.id,
    required this.title,
    required this.description,
    required this.options,
    required this.votes,
    required this.creatorId,
    required this.createdAt,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'options': options,
      'votes': votes,
      'creatorId': creatorId,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory VotingPoll.fromJson(Map<String, dynamic> json) {
    return VotingPoll(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      options: List<String>.from(json['options'] as List),
      votes: Map<String, int>.from(json['votes'] as Map),
      creatorId: json['creatorId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isActive: json['isActive'] as bool,
    );
  }
}

class Vote {
  final String id;
  final String pollId;
  final String userId;
  final String option;
  final DateTime timestamp;

  const Vote({
    required this.id,
    required this.pollId,
    required this.userId,
    required this.option,
    required this.timestamp,
  });
}

class VotingResults {
  final String pollId;
  final String pollTitle;
  final int totalVotes;
  final Map<String, int> optionVotes;
  final Map<String, double> percentages;

  const VotingResults({
    required this.pollId,
    required this.pollTitle,
    required this.totalVotes,
    required this.optionVotes,
    required this.percentages,
  });
}

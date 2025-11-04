import 'dart:async';
import 'dart:math';

/// Сервис чата для управления беседами и сообщениями
class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  static ChatService get instance => _instance;
  ChatService._internal();

  final StreamController<ChatMessage> _onMessageReceived = StreamController.broadcast();
  final StreamController<Conversation> _onConversationUpdated = StreamController.broadcast();

  // Данные
  final Map<String, Conversation> _conversations = {};
  final Map<String, List<ChatMessage>> _messages = {};
  String? _currentUserId;

  Stream<ChatMessage> get onMessageReceived => _onMessageReceived.stream;
  Stream<Conversation> get onConversationUpdated => _onConversationUpdated.stream;

  /// Инициализация сервиса
  Future<void> initialize() async {
    print('Initializing Chat Service...');
    _currentUserId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    print('Chat Service initialized');
  }

  /// Получение списка бесед
  Future<List<Conversation>> getConversations() async {
    return _conversations.values.toList()
      ..sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
  }

  /// Получение сообщений беседы
  Future<List<ChatMessage>> getMessages(String conversationId) async {
    return _messages[conversationId] ?? [];
  }

  /// Отправка сообщения
  Future<ChatMessage> sendMessage({
    required String conversationId,
    required String content,
    ChatMessageType type = ChatMessageType.text,
  }) async {
    final conversation = _conversations[conversationId];
    if (conversation == null) {
      throw Exception('Conversation not found');
    }

    final message = ChatMessage(
      id: _generateId(),
      conversationId: conversationId,
      senderId: _currentUserId!,
      senderName: 'Me',
      content: content,
      type: type,
      timestamp: DateTime.now(),
      isRead: false,
    );

    _addMessage(message);

    // Обновляем беседу
    _conversations[conversationId] = conversation.copyWith(
      lastMessage: content,
      lastMessageAt: message.timestamp,
    );
    _onConversationUpdated.add(_conversations[conversationId]!);

    return message;
  }

  /// Создание новой беседы
  Future<Conversation> createConversation({
    required String participantId,
    required String participantName,
  }) async {
    final conversationId = _generateId();

    final conversation = Conversation(
      id: conversationId,
      type: ConversationType.direct,
      participantIds: [participantId],
      participantNames: [participantName],
      lastMessage: '',
      lastMessageAt: DateTime.now(),
      unreadCount: 0,
    );

    _conversations[conversationId] = conversation;

    return conversation;
  }

  /// Отметка сообщений как прочитанных
  Future<void> markAsRead(String conversationId) async {
    final messages = _messages[conversationId] ?? [];
    for (final message in messages) {
      if (!message.isRead && message.senderId != _currentUserId) {
        _messages[conversationId]?[_messages[conversationId]!.indexOf(message)] =
            message.copyWith(isRead: true);
      }
    }

    final conversation = _conversations[conversationId];
    if (conversation != null) {
      _conversations[conversationId] = conversation.copyWith(unreadCount: 0);
      _onConversationUpdated.add(_conversations[conversationId]!);
    }
  }

  /// Получение статистики
  Map<String, dynamic> getStatistics() {
    return {
      'total_conversations': _conversations.length,
      'total_messages': _messages.values.fold(0, (sum, msgs) => sum + msgs.length),
      'active_conversations': _conversations.values.where((c) => c.unreadCount > 0).length,
    };
  }

  // Приватные методы

  void _addMessage(ChatMessage message) {
    final messages = _messages[message.conversationId] ?? [];
    messages.add(message);
    _messages[message.conversationId] = messages;
    _onMessageReceived.add(message);
  }

  String _generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }

  void dispose() {
    _onMessageReceived.close();
    _onConversationUpdated.close();
  }
}

// Модели данных

class Conversation {
  final String id;
  final ConversationType type;
  final List<String> participantIds;
  final List<String> participantNames;
  final String lastMessage;
  final DateTime lastMessageAt;
  final int unreadCount;

  const Conversation({
    required this.id,
    required this.type,
    required this.participantIds,
    required this.participantNames,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.unreadCount,
  });

  Conversation copyWith({
    String? id,
    ConversationType? type,
    List<String>? participantIds,
    List<String>? participantNames,
    String? lastMessage,
    DateTime? lastMessageAt,
    int? unreadCount,
  }) {
    return Conversation(
      id: id ?? this.id,
      type: type ?? this.type,
      participantIds: participantIds ?? this.participantIds,
      participantNames: participantNames ?? this.participantNames,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

enum ConversationType {
  direct,
  group,
}

class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String content;
  final ChatMessageType type;
  final DateTime timestamp;
  final bool isRead;

  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.type,
    required this.timestamp,
    required this.isRead,
  });

  ChatMessage copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? senderName,
    String? content,
    ChatMessageType? type,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}

enum ChatMessageType {
  text,
  image,
  audio,
  video,
  file,
  location,
  system,
}

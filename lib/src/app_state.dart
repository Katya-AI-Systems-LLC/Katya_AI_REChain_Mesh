import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/message.dart';

/// Глобальное состояние приложения
class AppState extends ChangeNotifier {
  static const String _messagesBoxName = 'messages';
  static const String _settingsBoxName = 'settings';

  late Box<Message> _messagesBox;
  late Box _settingsBox;

  final List<Message> _messages = [];
  bool _isInitialized = false;

  List<Message> get messages => List.unmodifiable(_messages);
  bool get isInitialized => _isInitialized;

  /// Инициализация Hive
  static Future<void> initHive() async {
    await Hive.initFlutter();

    // Регистрируем адаптеры
    Hive.registerAdapter(MessageAdapter());
  }

  /// Инициализация состояния
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Открываем боксы с таймаутом
      _messagesBox = await Hive.openBox<Message>(_messagesBoxName)
          .timeout(const Duration(seconds: 5));
      _settingsBox = await Hive.openBox(_settingsBoxName)
          .timeout(const Duration(seconds: 5));

      // Загружаем сообщения
      _messages.addAll(_messagesBox.values);

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('Error initializing app state: $e');
      // Создаем пустые боксы в памяти при ошибке
      _messagesBox = Hive.box<Message>(_messagesBoxName);
      _settingsBox = Hive.box(_settingsBoxName);
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Добавление сообщения
  Future<void> addMessage(Message message) async {
    try {
      _messages.add(message);
      await _messagesBox.put(message.id, message);
      notifyListeners();
    } catch (e) {
      print('Error adding message: $e');
    }
  }

  /// Обновление сообщения
  Future<void> updateMessage(Message message) async {
    try {
      final index = _messages.indexWhere((m) => m.id == message.id);
      if (index != -1) {
        _messages[index] = message;
        await _messagesBox.put(message.id, message);
        notifyListeners();
      }
    } catch (e) {
      print('Error updating message: $e');
    }
  }

  /// Удаление сообщения
  Future<void> deleteMessage(String messageId) async {
    try {
      _messages.removeWhere((m) => m.id == messageId);
      await _messagesBox.delete(messageId);
      notifyListeners();
    } catch (e) {
      print('Error deleting message: $e');
    }
  }

  /// Получение сообщений для конкретного чата
  List<Message> getMessagesForChat(String peerId) {
    return _messages
        .where((m) => m.fromId == peerId || m.toId == peerId)
        .toList()
      ..sort((a, b) => a.ts.compareTo(b.ts));
  }

  /// Получение непрочитанных сообщений
  int getUnreadCount(String peerId) {
    return _messages
        .where((m) => m.fromId == peerId && m.status != 'read')
        .length;
  }

  /// Отметка сообщений как прочитанных
  Future<void> markAsRead(String peerId) async {
    try {
      for (final message in _messages) {
        if (message.fromId == peerId && message.status != 'read') {
          final updatedMessage = message.copyWith(status: 'read');
          await updateMessage(updatedMessage);
        }
      }
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  /// Очистка всех сообщений
  Future<void> clearAllMessages() async {
    try {
      _messages.clear();
      await _messagesBox.clear();
      notifyListeners();
    } catch (e) {
      print('Error clearing messages: $e');
    }
  }

  /// Получение настроек
  T? getSetting<T>(String key, {T? defaultValue}) {
    return _settingsBox.get(key, defaultValue: defaultValue);
  }

  /// Установка настроек
  Future<void> setSetting<T>(String key, T value) async {
    try {
      await _settingsBox.put(key, value);
      notifyListeners();
    } catch (e) {
      print('Error setting $key: $e');
    }
  }

  /// Получение статистики
  Map<String, int> getStats() {
    return {
      'totalMessages': _messages.length,
      'sentMessages': _messages.where((m) => m.fromId == 'me').length,
      'receivedMessages': _messages.where((m) => m.fromId != 'me').length,
      'unreadMessages': _messages.where((m) => m.status != 'read').length,
    };
  }

  @override
  void dispose() {
    _messagesBox.close();
    _settingsBox.close();
    super.dispose();
  }
}

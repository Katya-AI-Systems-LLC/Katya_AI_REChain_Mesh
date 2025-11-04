import 'dart:async';

import '../../domain/message.dart';
import '../../domain/repositories/message_repository.dart';
import 'base_service.dart';

/// Service for handling messaging functionality
class MessageService implements LifecycleService, ErrorHandlingService {
  final MessageRepository _messageRepository;
  final StreamController<Message> _messageController = 
      StreamController<Message>.broadcast();
  final StreamController<MessageStatusUpdate> _statusController =
      StreamController<MessageStatusUpdate>.broadcast();
  final StreamController<ServiceError> _errorController = 
      StreamController<ServiceError>.broadcast();
  
  bool _isInitialized = false;
  bool _isRunning = false;
  
  /// Creates a new MessageService
  MessageService(this._messageRepository);
  
  @override
  String get serviceName => 'MessageService';
  
  @override
  bool get isInitialized => _isInitialized;
  
  @override
  bool get isRunning => _isRunning;
  
  @override
  Stream<ServiceError> get errors => _errorController.stream;
  
  /// Stream of incoming messages
  Stream<Message> get messages => _messageController.stream;
  
  /// Stream of message status updates
  Stream<MessageStatusUpdate> get statusUpdates => _statusController.stream;
  
  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await _messageRepository.initialize();
      _isInitialized = true;
    } catch (e, stackTrace) {
      _handleError(
        'Failed to initialize MessageService',
        e,
        stackTrace,
        ErrorSeverity.critical,
      );
      rethrow;
    }
  }
  
  @override
  Future<void> start() async {
    if (!_isInitialized) {
      throw StateError('MessageService must be initialized before starting');
    }
    
    if (_isRunning) return;
    _isRunning = true;
    
    // Start listening for new messages
    _startMessageListener();
  }
  
  @override
  Future<void> stop() async {
    _isRunning = false;
  }
  
  @override
  Future<void> dispose() async {
    await stop();
    await _messageController.close();
    await _statusController.close();
    await _errorController.close();
    await _messageRepository.dispose();
    _isInitialized = false;
  }
  
  /// Sends a message
  Future<Message> sendMessage(Message message) async {
    try {
      // Set initial status
      final messageToSend = message.copyWith(
        status: MessageStatus.sent,
        updatedAt: DateTime.now(),
      );
      
      // Save to repository
      final savedMessage = await _messageRepository.save(messageToSend);
      
      // Notify listeners
      _messageController.add(savedMessage);
      
      return savedMessage;
    } catch (e, stackTrace) {
      _handleError(
        'Failed to send message',
        e,
        stackTrace,
        ErrorSeverity.error,
      );
      rethrow;
    }
  }
  
  /// Receives a message
  Future<void> receiveMessage(Message message) async {
    try {
      // Update status to delivered
      final receivedMessage = message.copyWith(
        status: MessageStatus.delivered,
        updatedAt: DateTime.now(),
      );
      
      // Save to repository
      final savedMessage = await _messageRepository.save(receivedMessage);
      
      // Notify listeners
      _messageController.add(savedMessage);
      _notifyStatusUpdate(
        message.id,
        MessageStatus.sent,
        MessageStatus.delivered,
      );
    } catch (e, stackTrace) {
      _handleError(
        'Failed to receive message',
        e,
        stackTrace,
        ErrorSeverity.error,
      );
      rethrow;
    }
  }
  
  /// Marks a message as read
  Future<void> markAsRead(String messageId, String recipientId) async {
    try {
      final message = await _messageRepository.findById(messageId);
      if (message != null && message.status != MessageStatus.read) {
        await _messageRepository.markAsRead([messageId], recipientId);
        _notifyStatusUpdate(
          messageId,
          message.status,
          MessageStatus.read,
        );
      }
    } catch (e, stackTrace) {
      _handleError(
        'Failed to mark message as read',
        e,
        stackTrace,
        ErrorSeverity.warning,
      );
    }
  }
  
  /// Gets a message by ID
  Future<Message?> getMessage(String messageId) async {
    try {
      return await _messageRepository.findById(messageId);
    } catch (e, stackTrace) {
      _handleError(
        'Failed to get message',
        e,
        stackTrace,
        ErrorSeverity.warning,
      );
      return null;
    }
  }
  
  /// Gets a conversation between two peers
  Future<List<Message>> getConversation({
    required String peer1Id,
    required String peer2Id,
    DateTime? since,
    DateTime? until,
    int? limit,
    bool ascending = false,
  }) async {
    try {
      return await _messageRepository.findConversation(
        peer1Id: peer1Id,
        peer2Id: peer2Id,
        since: since,
        until: until,
        limit: limit,
        ascending: ascending,
      );
    } catch (e, stackTrace) {
      _handleError(
        'Failed to get conversation',
        e,
        stackTrace,
        ErrorSeverity.error,
      );
      return [];
    }
  }
  
  /// Gets unread messages for a peer
  Future<List<Message>> getUnreadMessages(String recipientId) async {
    try {
      return await _messageRepository.findUnreadMessages(recipientId);
    } catch (e, stackTrace) {
      _handleError(
        'Failed to get unread messages',
        e,
        stackTrace,
        ErrorSeverity.warning,
      );
      return [];
    }
  }
  
  /// Updates the status of a message
  Future<void> updateMessageStatus(
    String messageId, 
    MessageStatus newStatus,
  ) async {
    try {
      final message = await _messageRepository.findById(messageId);
      if (message != null && message.status != newStatus) {
        final updatedMessage = message.copyWith(
          status: newStatus,
          updatedAt: DateTime.now(),
        );
        
        await _messageRepository.save(updatedMessage);
        _notifyStatusUpdate(messageId, message.status, newStatus);
      }
    } catch (e, stackTrace) {
      _handleError(
        'Failed to update message status',
        e,
        stackTrace,
        ErrorSeverity.error,
      );
    }
  }
  
  /// Handles an error
  @override
  void handleError(ServiceError error) {
    _errorController.add(error);
  }
  
  // Starts listening for new messages
  void _startMessageListener() {
    // This would typically involve setting up a subscription to a message queue
    // or network socket. For now, we'll just log that we're starting.
    print('MessageService: Started listening for messages');
  }
  
  // Notifies listeners of a status update
  void _notifyStatusUpdate(
    String messageId,
    MessageStatus oldStatus,
    MessageStatus newStatus,
  ) {
    final update = MessageStatusUpdate(
      messageId: messageId,
      oldStatus: oldStatus,
      newStatus: newStatus,
      timestamp: DateTime.now(),
    );
    
    _statusController.add(update);
  }
  
  // Handles an error
  void _handleError(
    String message,
    dynamic error,
    StackTrace stackTrace, 
    ErrorSeverity severity,
  ) {
    final serviceError = ServiceError(
      message: '$message: $error',
      stackTrace: stackTrace,
      severity: severity,
    );
    _errorController.add(serviceError);
  }
}

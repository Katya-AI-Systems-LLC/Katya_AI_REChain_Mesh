import '../../domain/message.dart';
import 'base_repository.dart';

/// Mixin for repositories that need lifecycle management
abstract class LifecycleRepository {
  /// Initializes the repository
  Future<void> initialize();
  
  /// Disposes resources used by the repository
  Future<void> dispose();
}

/// Repository for managing Message entities
abstract class MessageRepository extends BaseRepository<Message> implements LifecycleRepository {
  /// Finds messages between two peers
  Future<List<Message>> findConversation({
    required String peer1Id,
    required String peer2Id,
    DateTime? since,
    DateTime? until,
    int? limit,
    bool ascending = false,
  });
  
  /// Finds unread messages for a peer
  Future<List<Message>> findUnreadMessages(String recipientId);
  
  /// Marks messages as read
  Future<int> markAsRead(List<String> messageIds, String recipientId);
  
  /// Finds messages by type
  Future<List<Message>> findByType(MessageType type, {String? peerId});
  
  /// Finds messages within a geofence
  Future<List<Message>> findInGeofence(GeoFence geofence, {MessageType? type});
  
  /// Stream of new messages for a peer
  Stream<Message> watchNewMessages(String recipientId);
  
  /// Stream of message status changes
  Stream<MessageStatusUpdate> watchMessageStatus(String messageId);
  
  /// Finds messages with a specific parent (for threading)
  Future<List<Message>> findReplies(String parentMessageId);
  
  /// Deletes messages older than the specified date
  Future<int> deleteOlderThan(DateTime date, {String? peerId});
}

/// Represents a message status update
class MessageStatusUpdate {
  final String messageId;
  final MessageStatus oldStatus;
  final MessageStatus newStatus;
  final DateTime timestamp;
  
  const MessageStatusUpdate({
    required this.messageId,
    required this.oldStatus,
    required this.newStatus,
    required this.timestamp,
  });
  
  @override
  String toString() => 'MessageStatusUpdate(' 
      'messageId: $messageId, ' 
      'status: $oldStatus -> $newStatus, ' 
      'at: $timestamp' 
      ')';
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../models/message.dart';
import '../theme.dart';
import 'conversation_page.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final msgs = state.messages;

    // Группируем сообщения по собеседникам
    final Map<String, List<Message>> conversations = {};
    for (final msg in msgs) {
      final peerId = msg.fromId == 'me' ? msg.toId : msg.fromId;
      conversations.putIfAbsent(peerId, () => []).add(msg);
    }

    return Container(
      margin: const EdgeInsets.all(20),
      child: conversations.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                final peerId = conversations.keys.elementAt(index);
                final peerMessages = conversations[peerId]!;
                final lastMessage = peerMessages.last;
                final unreadCount = peerMessages
                    .where((m) => m.fromId != 'me' && m.status != 'read')
                    .length;

                return _buildConversationCard(
                  context,
                  peerId,
                  lastMessage,
                  unreadCount,
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: KatyaTheme.accentGradient,
              boxShadow: KatyaTheme.spaceShadow,
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              size: 60,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Нет сообщений',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: KatyaTheme.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            'Начните общение с ближайшими устройствами',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: KatyaTheme.onSurface.withOpacity(0.7),
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              // Переключиться на вкладку устройств
              DefaultTabController.of(context).animateTo(1);
            },
            icon: const Icon(Icons.devices),
            label: const Text('Найти устройства'),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationCard(
    BuildContext context,
    String peerId,
    Message lastMessage,
    int unreadCount,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ConversationPage(peerId: peerId)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Аватар
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: KatyaTheme.accentGradient,
                    boxShadow: [
                      BoxShadow(
                        color: KatyaTheme.primary.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      peerId.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Информация о чате
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Device $peerId',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: KatyaTheme.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                          Text(
                            _formatTime(lastMessage.ts),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: KatyaTheme.onSurface.withOpacity(0.6),
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              lastMessage.body,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: KatyaTheme.onSurface.withOpacity(
                                      0.8,
                                    ),
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (unreadCount > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: KatyaTheme.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                unreadCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Статус сообщения
                Icon(
                  _getStatusIcon(lastMessage.status),
                  color: _getStatusColor(lastMessage.status),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}д';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}ч';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}м';
    } else {
      return 'сейчас';
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'sent':
        return Icons.check;
      case 'delivered':
        return Icons.done_all;
      case 'read':
        return Icons.done_all;
      default:
        return Icons.schedule;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'sent':
        return KatyaTheme.onSurface.withOpacity(0.6);
      case 'delivered':
        return KatyaTheme.onSurface.withOpacity(0.8);
      case 'read':
        return KatyaTheme.success;
      default:
        return KatyaTheme.warning;
    }
  }
}

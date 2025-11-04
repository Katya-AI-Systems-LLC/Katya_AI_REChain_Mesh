import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../app_state.dart';
import '../models/message.dart';
import '../theme.dart';
import '../services/mesh_service_ble.dart';
import '../services/ai_service.dart';

class ConversationPage extends StatefulWidget {
  final String peerId;
  const ConversationPage({super.key, required this.peerId});

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final uuid = const Uuid();
  final MeshServiceBLE _mesh = MeshServiceBLE.instance;
  final AIService _aiService = AIService();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _mesh.onMessageReceived.listen((meshMessage) {
      // listen for incoming messages
      if (meshMessage.fromId == widget.peerId) {
        final msg = Message(
          id: uuid.v4(),
          fromId: widget.peerId,
          toId: 'me',
          body: meshMessage.message,
          ts: meshMessage.timestamp,
          status: 'delivered',
        );
        Provider.of<AppState>(context, listen: false).addMessage(msg);
        _scrollToBottom();
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final msgs = state.messages
        .where((m) => m.toId == widget.peerId || m.fromId == widget.peerId)
        .toList()
      ..sort((a, b) => a.ts.compareTo(b.ts));

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: KatyaTheme.spaceGradient),
        child: Column(
          children: [
            // Кастомный AppBar
            Container(
              padding: const EdgeInsets.only(
                top: 50,
                left: 20,
                right: 20,
                bottom: 20,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: KatyaTheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Аватар
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: KatyaTheme.accentGradient,
                      boxShadow: KatyaTheme.spaceShadow,
                    ),
                    child: Center(
                      child: Text(
                        widget.peerId.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Информация о собеседнике
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Device ${widget.peerId}',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: KatyaTheme.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        Text(
                          'Mesh соединение',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: KatyaTheme.onSurface.withOpacity(0.7),
                              ),
                        ),
                      ],
                    ),
                  ),

                  // Статус подключения
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: KatyaTheme.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),

            // Список сообщений
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: msgs.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: msgs.length + (_isTyping ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == msgs.length && _isTyping) {
                            return _buildTypingIndicator();
                          }
                          return _buildMessageBubble(msgs[index]);
                        },
                      ),
              ),
            ),

            // Поле ввода
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: KatyaTheme.surface.withOpacity(0.8),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: KatyaTheme.primary.withOpacity(0.3)),
                boxShadow: KatyaTheme.spaceShadow,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      style: const TextStyle(color: KatyaTheme.onSurface),
                      decoration: const InputDecoration(
                        hintText: 'Введите сообщение...',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      maxLines: null,
                      onChanged: (text) {
                        setState(() {
                          _isTyping = text.trim().isNotEmpty;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: KatyaTheme.accentGradient,
                    ),
                    child: IconButton(
                      onPressed: _sendMessage,
                      icon: const Icon(Icons.send, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: KatyaTheme.accentGradient,
              boxShadow: KatyaTheme.spaceShadow,
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Начните общение',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: KatyaTheme.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            'Отправьте первое сообщение через mesh-сеть',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: KatyaTheme.onSurface.withOpacity(0.7),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    final isMe = message.fromId == 'me';
    final smartReplies = _aiService.generateSmartReplies(message.body);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: KatyaTheme.accentGradient,
              ),
              child: Center(
                child: Text(
                  widget.peerId.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe ? KatyaTheme.primary : KatyaTheme.surface,
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomLeft: isMe
                      ? const Radius.circular(20)
                      : const Radius.circular(4),
                  bottomRight: isMe
                      ? const Radius.circular(4)
                      : const Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isMe ? KatyaTheme.primary : KatyaTheme.surface)
                        .withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.body,
                    style: TextStyle(
                      color: isMe ? Colors.white : KatyaTheme.onSurface,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.ts),
                        style: TextStyle(
                          color: (isMe ? Colors.white : KatyaTheme.onSurface)
                              .withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _getStatusIcon(message.status),
                        size: 12,
                        color: _getStatusColor(message.status),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: KatyaTheme.accentGradient,
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: KatyaTheme.accentGradient,
            ),
            child: Center(
              child: Text(
                widget.peerId.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: KatyaTheme.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      KatyaTheme.accent,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Печатает...',
                  style: TextStyle(
                    color: KatyaTheme.onSurface.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;

    final msg = Message(
      id: uuid.v4(),
      fromId: 'me',
      toId: widget.peerId,
      body: text,
      ts: DateTime.now(),
      status: 'sending',
    );

    await Provider.of<AppState>(context, listen: false).addMessage(msg);
    _ctrl.clear();
    setState(() {
      _isTyping = false;
    });
    _scrollToBottom();

    // Отправка через BLE
    try {
      await _mesh.sendMessage(text);
      // Обновляем статус сообщения
      final updatedMsg = Message(
        id: msg.id,
        fromId: msg.fromId,
        toId: msg.toId,
        body: msg.body,
        ts: msg.ts,
        status: 'sent',
      );
      await Provider.of<AppState>(
        context,
        listen: false,
      ).addMessage(updatedMsg);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Сообщение отправлено'),
            backgroundColor: KatyaTheme.success,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Обновляем статус на ошибку
      final errorMsg = Message(
        id: msg.id,
        fromId: msg.fromId,
        toId: msg.toId,
        body: msg.body,
        ts: msg.ts,
        status: 'error',
      );
      await Provider.of<AppState>(context, listen: false).addMessage(errorMsg);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка отправки: $e'),
            backgroundColor: KatyaTheme.error,
          ),
        );
      }
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${time.day}.${time.month} ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } else if (difference.inHours > 0) {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } else if (difference.inMinutes > 0) {
      return '${time.minute}м назад';
    } else {
      return 'сейчас';
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'sending':
        return Icons.schedule;
      case 'sent':
        return Icons.check;
      case 'delivered':
        return Icons.done_all;
      case 'read':
        return Icons.done_all;
      case 'error':
        return Icons.error;
      default:
        return Icons.schedule;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'sending':
        return KatyaTheme.warning;
      case 'sent':
        return KatyaTheme.onSurface.withOpacity(0.6);
      case 'delivered':
        return KatyaTheme.onSurface.withOpacity(0.8);
      case 'read':
        return KatyaTheme.success;
      case 'error':
        return KatyaTheme.error;
      default:
        return KatyaTheme.warning;
    }
  }
}

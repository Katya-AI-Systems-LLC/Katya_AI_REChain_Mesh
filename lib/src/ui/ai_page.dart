import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/ai_service.dart';

class AIPage extends StatefulWidget {
  const AIPage({super.key});

  @override
  State<AIPage> createState() => _AIPageState();
}

class _AIPageState extends State<AIPage> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AIService _aiService = AIService();
  final List<AIMessage> _messages = [];
  late AnimationController _typingController;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _typingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Добавляем приветственное сообщение
    _messages.add(
      AIMessage(
        text:
            'Привет! Я Katya AI, ваш помощник в mesh-сети! 👽\n\nЯ могу помочь с:\n• Анализом сообщений\n• Умными подсказками\n• Вопросами по REChain\n• Общением в космосе! 🚀',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Заголовок
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: KatyaTheme.accentGradient,
                  boxShadow: KatyaTheme.spaceShadow,
                ),
                child: const Icon(
                  Icons.smart_toy,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Katya AI',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: KatyaTheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    Text(
                      'Ваш AI-помощник в mesh-сети',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: KatyaTheme.onSurface.withOpacity(0.7),
                          ),
                    ),
                  ],
                ),
              ),
              // Статус
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: KatyaTheme.success.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: KatyaTheme.success),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: KatyaTheme.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Online',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: KatyaTheme.success,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Список сообщений
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: KatyaTheme.surface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: KatyaTheme.primary.withOpacity(0.3)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _messages.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length + (_isTyping ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _messages.length && _isTyping) {
                            return _buildTypingIndicator();
                          }
                          return _buildMessageBubble(_messages[index]);
                        },
                      ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Поле ввода
          Container(
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
                    controller: _messageController,
                    style: const TextStyle(color: KatyaTheme.onSurface),
                    decoration: const InputDecoration(
                      hintText: 'Спросите Katya AI...',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    maxLines: null,
                    onSubmitted: (_) => _sendMessage(),
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

          // Быстрые действия
          const SizedBox(height: 16),
          _buildQuickActions(),
        ],
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
            child: const Icon(Icons.psychology, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            'Начните диалог с Katya AI',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: KatyaTheme.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            'Задайте любой вопрос или попросите помощь',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: KatyaTheme.onSurface.withOpacity(0.7),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(AIMessage message) {
    final isUser = message.isUser;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: KatyaTheme.accentGradient,
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? KatyaTheme.primary : KatyaTheme.surface,
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomLeft: isUser
                      ? const Radius.circular(20)
                      : const Radius.circular(4),
                  bottomRight: isUser
                      ? const Radius.circular(4)
                      : const Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isUser ? KatyaTheme.primary : KatyaTheme.surface)
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
                    message.text,
                    style: TextStyle(
                      color: isUser ? Colors.white : KatyaTheme.onSurface,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: (isUser ? Colors.white : KatyaTheme.onSurface)
                          .withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
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
            child: const Icon(Icons.smart_toy, color: Colors.white, size: 16),
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
                  'Katya AI печатает...',
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

  Widget _buildQuickActions() {
    final quickActions = [
      {
        'icon': Icons.help,
        'text': 'Помощь',
        'action': () => _sendQuickMessage('Помоги мне с mesh-сетью'),
      },
      {
        'icon': Icons.analytics,
        'text': 'Анализ',
        'action': () => _sendQuickMessage('Проанализируй мои сообщения'),
      },
      {
        'icon': Icons.settings,
        'text': 'Настройки',
        'action': () => _sendQuickMessage('Покажи настройки REChain'),
      },
      {
        'icon': Icons.info,
        'text': 'О приложении',
        'action': () => _sendQuickMessage('Расскажи о Katya AI REChain'),
      },
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: quickActions.map((action) {
        return ActionChip(
          avatar: Icon(
            action['icon'] as IconData,
            size: 16,
            color: KatyaTheme.primary,
          ),
          label: Text(action['text'] as String),
          onPressed: action['action'] as VoidCallback,
          backgroundColor: KatyaTheme.surface.withOpacity(0.5),
          labelStyle: const TextStyle(color: KatyaTheme.onSurface),
        );
      }).toList(),
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    _addUserMessage(text);
    _simulateAIResponse(text);
  }

  void _sendQuickMessage(String message) {
    _addUserMessage(message);
    _simulateAIResponse(message);
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add(
        AIMessage(text: text, isUser: true, timestamp: DateTime.now()),
      );
    });
    _scrollToBottom();
  }

  void _simulateAIResponse(String userMessage) {
    setState(() {
      _isTyping = true;
    });
    _typingController.repeat();

    // Симулируем задержку ответа AI
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _typingController.stop();
        });

        final aiResponse = _generateAIResponse(userMessage);
        _messages.add(
          AIMessage(text: aiResponse, isUser: false, timestamp: DateTime.now()),
        );
        _scrollToBottom();
      }
    });
  }

  String _generateAIResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();

    // Специальные ответы для Katya AI
    if (lowerMessage.contains('помощь') || lowerMessage.contains('help')) {
      return 'Конечно! Я Katya AI, ваш помощник в mesh-сети! 🚀\n\nЯ могу помочь с:\n• Настройкой Bluetooth соединений\n• Анализом сообщений\n• Созданием голосований\n• Объяснением работы REChain\n• Умными подсказками в чатах\n\nЧто именно вас интересует?';
    }

    if (lowerMessage.contains('анализ') || lowerMessage.contains('analyze')) {
      return 'Отлично! Давайте проанализируем ваши сообщения! 📊\n\nЯ вижу, что вы активно используете mesh-сеть. Вот что я заметил:\n• Вы общаетесь через Bluetooth\n• Используете шифрование AES-GCM\n• Участвуете в голосованиях\n\nХотите более детальный анализ?';
    }

    if (lowerMessage.contains('настройки') ||
        lowerMessage.contains('settings')) {
      return 'Настройки REChain Mesh: ⚙️\n\n• Bluetooth: Включен\n• Шифрование: AES-GCM 256-bit\n• Handshake: ECDH/X25519\n• Mesh-сеть: Активна\n• Katya AI: Online\n\nВсе работает отлично! 🎯';
    }

    if (lowerMessage.contains('о приложении') ||
        lowerMessage.contains('about')) {
      return 'Katya AI REChain Mesh - это революционное приложение! 👽\n\n🚀 Особенности:\n• Полностью оффлайн работа\n• Mesh-сеть через Bluetooth\n• Шифрование сообщений\n• AI-помощник Katya\n• Голосования в реальном времени\n• Поддержка Aurora OS\n\nМы делаем общение безопасным и независимым! 💫';
    }

    if (lowerMessage.contains('mesh') || lowerMessage.contains('сеть')) {
      return 'Mesh-сеть - это круто! 📡\n\nВ REChain мы используем:\n• Bluetooth для прямых соединений\n• Автоматическое обнаружение устройств\n• Безопасную передачу данных\n• Работу без интернета\n\nЭто будущее общения! 🌟';
    }

    // Используем стандартные ответы AI-сервиса
    final smartReplies = _aiService.generateSmartReplies(userMessage);
    return smartReplies.isNotEmpty
        ? smartReplies.first
        : 'Интересно! Расскажите больше! 🤔';
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
}

class AIMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  AIMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

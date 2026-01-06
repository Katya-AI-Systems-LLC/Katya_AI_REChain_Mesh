import 'dart:async';
import 'package:flutter/material.dart';
import 'package:katya_ai_rechain_mesh/src/enhanced_theme.dart';
import 'package:katya_ai_rechain_mesh/src/ui/components/enhanced_ui_components.dart';
import '../services/mesh_service_ble.dart';
import '../app_state.dart';
import '../models/message.dart' as model;
import '../services/ai/offline_ai_helper.dart';

/// Улучшенная страница мессенджера с лучшим UX/DX
class EnhancedMessengerPage extends StatefulWidget {
  const EnhancedMessengerPage({super.key});

  @override
  State<EnhancedMessengerPage> createState() => _EnhancedMessengerPageState();
}

class _EnhancedMessengerPageState extends State<EnhancedMessengerPage> {
  final MeshServiceBLE _mesh = MeshServiceBLE.instance;
  final OfflineAIHelper _ai = OfflineAIHelper.instance;
  final List<MeshMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  StreamSubscription<MeshMessage>? _sub;
  List<String> _aiSuggestions = [];
  bool _showSuggestions = false;
  bool _isLoading = false;
  bool _showTypingIndicator = false;

  @override
  void initState() {
    super.initState();
    _initializeMessenger();
  }

  Future<void> _initializeMessenger() async {
    setState(() => _isLoading = true);
    try {
      // Load persisted messages
      final app = AppState.instance;
      await app.initialize();
      _loadMessages();
      _listenForMessages();
    } catch (e) {
      print('Error initializing messenger: $e');
    }
    setState(() => _isLoading = false);
  }

  void _loadMessages() {
    // Load messages from AppState
    final app = AppState.instance;
    setState(() {
      _messages.clear();
      _messages.addAll(app.messages);
    });
  }

  void _listenForMessages() {
    _sub = _mesh.messageStream.listen((msg) {
      setState(() {
        _messages.insert(0, msg);
      });
      _updateAISuggestions();
    });
  }

  void _updateAISuggestions() async {
    if (_messages.isEmpty) return;
    // Get last message context
    final lastMessage = _messages.first;
    try {
      final suggestions = await _ai.generateSuggestions(lastMessage.content);
      setState(() {
        _aiSuggestions = suggestions;
        _showSuggestions = true;
      });
    } catch (e) {
      print('Error generating suggestions: $e');
    }
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    
    setState(() {
      _showTypingIndicator = true;
      _showSuggestions = false;
    });

    try {
      final msg = MeshMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: _mesh.deviceId,
        content: text,
        timestamp: DateTime.now(),
      );

      await _mesh.sendMessage(msg);
      
      setState(() {
        _messages.insert(0, msg);
        _showTypingIndicator = false;
      });

      _updateAISuggestions();
    } catch (e) {
      setState(() => _showTypingIndicator = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending message: $e')),
      );
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: EnhancedTheme.darkBg,
      child: Column(
        children: [
          Expanded(
            child: _messages.isEmpty && !_isLoading
                ? EmptyState(
                    icon: Icons.chat_outlined,
                    title: 'Нет сообщений',
                    subtitle: 'Начните разговор отправив первое сообщение',
                    action: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.send_rounded),
                      label: const Text('Отправить сообщение'),
                    ),
                  )
                : _messages.isEmpty && _isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(
                                EnhancedTheme.accent,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Загрузка сообщений...',
                              style: EnhancedTheme.bodyM,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length + (_showTypingIndicator ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == 0 && _showTypingIndicator) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _buildTypingIndicator(),
                            );
                          }
                          final actualIndex = _showTypingIndicator ? index - 1 : index;
                          final message = _messages[actualIndex];
                          final isOwn = message.sender == _mesh.deviceId;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _buildMessageBubble(message, isOwn),
                          );
                        },
                      ),
          ),
          // AI Suggestions
          if (_showSuggestions && _aiSuggestions.isNotEmpty)
            _buildSuggestionsBar(),
          // Input area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: EnhancedTheme.darkSurface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'Напишите сообщение...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: EnhancedTheme.border),
                        ),
                        filled: true,
                        fillColor: EnhancedTheme.darkSurfaceAlt,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        prefixIcon: const Icon(Icons.attach_file_rounded),
                        suffixIcon: _controller.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded),
                                onPressed: () {
                                  _controller.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton.extended(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send_rounded),
                    label: const Text('Отправить'),
                    backgroundColor: EnhancedTheme.accent,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MeshMessage message, bool isOwn) {
    return Row(
      mainAxisAlignment:
          isOwn ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: isOwn
                  ? EnhancedTheme.accentGradient
                  : LinearGradient(
                      colors: [
                        EnhancedTheme.darkSurfaceAlt,
                        EnhancedTheme.border,
                      ],
                    ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: EnhancedTheme.lightShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.content,
                  style: EnhancedTheme.bodyM.copyWith(
                    color: isOwn ? Colors.white : EnhancedTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(message.timestamp),
                  style: EnhancedTheme.labelS.copyWith(
                    color: isOwn
                        ? Colors.white.withOpacity(0.7)
                        : EnhancedTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypingIndicator() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: EnhancedTheme.darkSurfaceAlt,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              3,
              (index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.6, end: 1.0).animate(
                    CurvedAnimation(
                      parent: AlwaysStoppedAnimation(0.5),
                      curve: Curves.elasticInOut,
                    ),
                  ),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: EnhancedTheme.accent.withOpacity(0.7),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionsBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: EnhancedTheme.darkSurfaceAlt,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Text(
              'Suggestion от Katya:',
              style: EnhancedTheme.labelM,
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _aiSuggestions
                  .map(
                    (suggestion) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ModernChip(
                        label: suggestion,
                        onSelected: () {
                          _controller.text = suggestion;
                          setState(() {});
                          Future.delayed(
                            const Duration(milliseconds: 100),
                            _sendMessage,
                          );
                        },
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDay = DateTime(time.year, time.month, time.day);

    if (messageDay == today) {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } else if (messageDay == yesterday) {
      return 'Вчера ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}

// Модель MeshMessage для примера
class MeshMessage {
  final String id;
  final String sender;
  final String content;
  final DateTime timestamp;

  MeshMessage({
    required this.id,
    required this.sender,
    required this.content,
    required this.timestamp,
  });
}

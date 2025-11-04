import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:katya_ai_rechain_mesh/src/mesh/mesh_service.dart';
import 'package:katya_ai_rechain_mesh/src/mesh/mesh_service_impl.dart';
import 'package:katya_ai_rechain_mesh/src/mesh/models/mesh_message.dart';
import 'package:katya_ai_rechain_mesh/src/mesh/models/peer_info.dart';

class MeshChatScreen extends StatefulWidget {
  final String peerId;
  final String peerName;
  final MeshService meshService;

  const MeshChatScreen({
    super.key,
    required this.peerId,
    required this.peerName,
    required this.meshService,
  });

  @override
  _MeshChatScreenState createState() => _MeshChatScreenState();
}

class _MeshChatScreenState extends State<MeshChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  late final StreamSubscription<MeshMessage> _messageSubscription;
  late final StreamSubscription<MeshConnectionState> _connectionSubscription;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _setupMessageListener();
    _setupConnectionListener();
    _connectToPeer();
  }

  @override
  void dispose() {
    _messageSubscription.cancel();
    _connectionSubscription.cancel();
    _messageController.dispose();
    super.dispose();
  }

  void _setupMessageListener() {
    _messageSubscription = widget.meshService.messageStream.listen((message) {
      if (message.senderId == widget.peerId) {
        setState(() {
          _messages.add({
            'text': message.text ?? 'Binary message',
            'isMe': false,
            'timestamp': DateTime.now(),
          });
        });
      }
    });
  }

  void _setupConnectionListener() {
    _connectionSubscription = widget.meshService.connectionStateStream.listen((state) {
      setState(() {
        _isConnected = state == MeshConnectionState.connected;
      });
    });
  }

  Future<void> _connectToPeer() async {
    try {
      await widget.meshService.connect(widget.peerId);
      setState(() {
        _isConnected = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect: $e')),
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final message = MeshMessage.text(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: widget.meshService.localPeerId,
      text: text,
      recipientIds: [widget.peerId],
    );

    try {
      await widget.meshService.sendMessage(widget.peerId, message);
      setState(() {
        _messages.add({
          'text': text,
          'isMe': true,
          'timestamp': DateTime.now(),
        });
        _messageController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              _isConnected ? Icons.circle : Icons.circle_outlined,
              color: _isConnected ? Colors.green : Colors.grey,
              size: 12,
            ),
            const SizedBox(width: 8),
            Text(widget.peerName),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Align(
                  alignment: message['isMe']
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: message['isMe']
                          ? Theme.of(context).primaryColor.withOpacity(0.2)
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Column(
                      crossAxisAlignment: message['isMe']
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(message['text']),
                        const SizedBox(height: 4),
                        Text(
                          '${message['timestamp'].hour}:${message['timestamp'].minute.toString().padLeft(2, '0')}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

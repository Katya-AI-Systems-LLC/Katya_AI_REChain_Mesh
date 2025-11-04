import 'package:flutter/material.dart';
import 'messenger_page.dart';
import 'voting_screen.dart';
import 'widgets/mesh_map_view.dart';
import '../theme.dart';
import 'components/particle_background.dart';
import 'components/connection_status.dart';
import 'components/glass_card.dart';
import 'components/animated_button.dart';
import 'settings_page.dart';
import 'devices_page.dart';
import 'package:flutter/services.dart';
import 'markdown_viewer.dart';
import 'components/mesh_hud.dart';
import '../services/ai/offline_ai_helper.dart';
import '../services/mesh_service_ble.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ParticleBackground(
        child: Container(
          decoration: const BoxDecoration(gradient: KatyaTheme.spaceGradient),
          child: Column(
            children: [
              // Кастомный AppBar
              GlassCard(
                margin: const EdgeInsets.only(
                  top: 50,
                  left: 20,
                  right: 20,
                  bottom: 20,
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Логотип
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: KatyaTheme.spaceShadow,
                      ),
                      child: const Icon(
                        Icons.rocket_launch,
                        color: KatyaTheme.accent,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Заголовок
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Katya AI',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            'REChain Mesh',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(color: KatyaTheme.accent),
                          ),
                        ],
                      ),
                    ),

                    // Статус подключения
                    ConnectionStatus(
                      isConnected: true,
                      deviceName: 'Device-001',
                      signalStrength: -45,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const SettingsPage()),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // TabBar
              GlassCard(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: EdgeInsets.zero,
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: KatyaTheme.accentGradient,
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: KatyaTheme.onSurface.withOpacity(0.6),
                  labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                  isScrollable: true,
                  tabs: const [
                    Tab(icon: Icon(Icons.chat), text: 'Чаты'),
                    Tab(icon: Icon(Icons.devices), text: 'Устройства'),
                    Tab(icon: Icon(Icons.how_to_vote), text: 'Голосование'),
                    Tab(icon: Icon(Icons.map), text: 'Mesh Map'),
                    Tab(icon: Icon(Icons.smart_toy), text: 'Katya AI'),
                    Tab(icon: Icon(Icons.info_outline), text: 'About'),
                  ],
                ),
              ),

              // TabBarView
              Expanded(
                child: Stack(
                  children: [
                    TabBarView(
                      controller: _tabController,
                      children: const [
                        MessengerPage(),
                        DevicesPage(),
                        VotingScreen(),
                        Scaffold(body: Center(child: MeshMapView())),
                        AIPage(),
                        AboutPage(),
                      ],
                    ),
                    const MeshHud(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Временная заглушка для страницы голосования
class VotingPage extends StatelessWidget {
  const VotingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [
          GlassCard(
            child: Column(
              children: [
                const Icon(
                  Icons.how_to_vote,
                  size: 64,
                  color: KatyaTheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Голосование',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Создавайте голосования и голосуйте в реальном времени через mesh-сеть',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                AnimatedButton(
                  text: 'Создать голосование',
                  icon: Icons.add,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Функция голосования в разработке'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// AI Page with demo chat
class AIPage extends StatefulWidget {
  const AIPage({super.key});

  @override
  State<AIPage> createState() => _AIPageState();
}

class _AIPageState extends State<AIPage> {
  final TextEditingController _inputController = TextEditingController();
  final List<Map<String, String>> _chatHistory = [];
  bool _thinking = false;

  Future<void> _askAI(String prompt) async {
    if (prompt.trim().isEmpty) return;
    
    setState(() {
      _chatHistory.add({'role': 'user', 'text': prompt});
      _thinking = true;
    });
    _inputController.clear();

    try {
      final ai = OfflineAIHelper.instance;
      final ctx = {
        'peers': MeshServiceBLE.instance.connectedPeers.length,
        'timestamp': DateTime.now().toIso8601String(),
      };
      final response = await ai.generate({'prompt': prompt, 'context': ctx});
      
      if (mounted) {
        setState(() {
          _chatHistory.add({'role': 'ai', 'text': response['text'] as String? ?? 'Ошибка'});
          _thinking = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _chatHistory.add({'role': 'ai', 'text': 'Ошибка: $e'});
          _thinking = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [
          GlassCard(
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.psychology, size: 32, color: KatyaTheme.accent),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Katya AI', style: Theme.of(context).textTheme.titleLarge),
                          Text('Оффлайн AI-помощник', style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Анализирую сообщения, подсказываю ответы, анализирую голосования — всё без интернета!',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GlassCard(
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      reverse: true,
                      itemCount: _chatHistory.length + (_thinking ? 1 : 0),
                      itemBuilder: (ctx, i) {
                        if (i == 0 && _thinking) {
                          return const ListTile(
                            leading: CircularProgressIndicator(),
                            title: Text('Katya думает...'),
                          );
                        }
                        final idx = _thinking ? i - 1 : i;
                        if (idx < 0 || idx >= _chatHistory.length) return const SizedBox.shrink();
                        final msg = _chatHistory[_chatHistory.length - 1 - idx];
                        return ListTile(
                          leading: Icon(
                            msg['role'] == 'user' ? Icons.person : Icons.psychology,
                            color: msg['role'] == 'user' ? KatyaTheme.primary : KatyaTheme.accent,
                          ),
                          title: Text(msg['text'] ?? ''),
                          subtitle: Text(msg['role'] == 'user' ? 'Вы' : 'Katya AI'),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _inputController,
                            decoration: const InputDecoration(hintText: 'Спросите Katya AI...'),
                            onSubmitted: _askAI,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => _askAI(_inputController.text),
                          icon: const Icon(Icons.send),
                          label: const Text('Отправить'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Minimal About page linking to RU/EN docs
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const _links = [
    {
      'title': '🌌 Manifest (RU)',
      'path': 'docs/MANIFEST_RU.md',
      'url': 'https://github.com/REChain-Network-Solutions/AIPlatform',
    },
    {
      'title': '🚀 Press Release (RU)',
      'path': 'docs/PRESS_RELEASE_RU.md',
      'url': 'https://github.com/REChain-Network-Solutions/AIPlatform',
    },
    {
      'title': '🌌 Manifest (EN)',
      'path': 'docs/MANIFEST_EN.md',
      'url': 'https://github.com/REChain-Network-Solutions/AIPlatform',
    },
    {
      'title': '🚀 Press Release (EN)',
      'path': 'docs/PRESS_RELEASE_EN.md',
      'url': 'https://github.com/REChain-Network-Solutions/AIPlatform',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline, color: KatyaTheme.accent, size: 28),
                    const SizedBox(width: 8),
                    Text('About / Docs', style: Theme.of(context).textTheme.titleLarge),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Quick links for demo: manifesto and press release (RU/EN). Use Copy to get file path, or open repo URL.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                ..._links.map((e) => _DocRow(title: e['title']!, path: e['path']!, url: e['url']!)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DocRow extends StatelessWidget {
  final String title;
  final String path;
  final String url;
  const _DocRow({required this.title, required this.path, required this.url});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                Text(path, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MarkdownViewerPage(title: title, assetPath: path),
                ),
              );
            },
            child: const Text('Open'),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: path));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Path copied')));
            },
            child: const Text('Copy path'),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: url));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Repo URL copied')));
            },
            child: const Text('Copy URL'),
          ),
        ],
      ),
    );
  }
}

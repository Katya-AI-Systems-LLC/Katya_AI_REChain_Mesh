import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:katya_ai_rechain_mesh/src/enhanced_theme.dart';
import 'package:katya_ai_rechain_mesh/src/ui/components/enhanced_ui_components.dart';
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

/// Главная страница приложения с улучшенной навигацией
class EnhancedHomePage extends ConsumerStatefulWidget {
  const EnhancedHomePage({super.key});

  @override
  ConsumerState<EnhancedHomePage> createState() => _EnhancedHomePageState();
}

class _EnhancedHomePageState extends ConsumerState<EnhancedHomePage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;
  late PageController _pageController;

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.chat_rounded,
      label: 'Чаты',
      page: const MessengerPage(),
    ),
    NavigationItem(
      icon: Icons.devices_rounded,
      label: 'Устройства',
      page: const DevicesPage(),
    ),
    NavigationItem(
      icon: Icons.how_to_vote_rounded,
      label: 'Голосование',
      page: const VotingScreen(),
    ),
    NavigationItem(
      icon: Icons.map_rounded,
      label: 'Mesh Map',
      page: const Scaffold(body: Center(child: MeshMapView())),
    ),
    NavigationItem(
      icon: Icons.smart_toy_rounded,
      label: 'Katya AI',
      page: const AIPage(),
    ),
    NavigationItem(
      icon: Icons.info_rounded,
      label: 'Информация',
      page: const AboutPage(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _navigationItems.length, vsync: this);
    _pageController = PageController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onNavigationItemSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EnhancedTheme.darkBg,
      body: Stack(
        children: [
          // Фон с частицами
          Container(
            decoration: const BoxDecoration(gradient: EnhancedTheme.spaceGradient),
            child: const ParticleBackground(),
          ),
          // Основной контент
          Column(
            children: [
              // Кастомный AppBar
              ModernAppBar(
                title: _navigationItems[_currentIndex].label,
                showBackButton: false,
                actions: [
                  if (_currentIndex == 4)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: IconButton(
                        icon: const Icon(Icons.settings_rounded),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SettingsPage(),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
              // Статус соединения
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ConnectionStatus(
                  isConnected: true,
                  deviceName: 'Device-001',
                  signalStrength: -45,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SettingsPage(),
                      ),
                    );
                  },
                ),
              ),
              // Страницы с PageView для гладкой анимации
              Expanded(
                child: Stack(
                  children: [
                    PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      children: _navigationItems
                          .map((item) => SingleChildScrollView(child: item.page))
                          .toList(),
                    ),
                    // Mesh HUD поверх контента
                    const MeshHud(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      // Современный BottomNavigationBar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: EnhancedTheme.darkSurface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            onTap: _onNavigationItemSelected,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: EnhancedTheme.accent,
            unselectedItemColor:
                EnhancedTheme.textSecondary.withOpacity(0.6),
            items: _navigationItems
                .map(
                  (item) => BottomNavigationBarItem(
                    icon: AnimatedIconButton(
                      icon: item.icon,
                      color: _currentIndex == _navigationItems.indexOf(item)
                          ? EnhancedTheme.accent
                          : EnhancedTheme.textSecondary.withOpacity(0.6),
                      onPressed: () => _onNavigationItemSelected(
                        _navigationItems.indexOf(item),
                      ),
                    ),
                    label: item.label,
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

/// Модель для элемента навигации
class NavigationItem {
  final IconData icon;
  final String label;
  final Widget page;

  NavigationItem({
    required this.icon,
    required this.label,
    required this.page,
  });
}

// Остальные страницы остаются прежними, но можно их улучшить

/// Улучшенная страница голосования
class VotingPage extends StatelessWidget {
  const VotingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [
          ModernCard(
            child: Column(
              children: [
                Icon(
                  Icons.how_to_vote_rounded,
                  size: 64,
                  color: EnhancedTheme.accent,
                ),
                const SizedBox(height: 16),
                Text(
                  'Голосование',
                  style: EnhancedTheme.headingS,
                ),
                const SizedBox(height: 8),
                Text(
                  'Создавайте голосования и голосуйте в реальном времени через mesh-сеть',
                  style: EnhancedTheme.bodyM,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Создать голосование'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Страница Katya AI
class AIPage extends StatefulWidget {
  const AIPage({super.key});

  @override
  State<AIPage> createState() => _AIPageState();
}

class _AIPageState extends State<AIPage> {
  final OfflineAIHelper _ai = OfflineAIHelper.instance;
  final TextEditingController _inputController = TextEditingController();
  String _response = '';
  bool _loading = false;

  Future<void> _askAI(String question) async {
    if (question.isEmpty) return;

    setState(() {
      _loading = true;
      _response = '';
    });

    try {
      final response = await _ai.generateResponse(question);
      setState(() {
        _response = response;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _response = 'Error: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [
          ModernCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.smart_toy_rounded,
                      color: EnhancedTheme.accent,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Katya AI Помощник',
                            style: EnhancedTheme.titleL,
                          ),
                          Text(
                            'On-device AI на вашем устройстве',
                            style: EnhancedTheme.bodyS,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_response.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: EnhancedTheme.darkSurfaceAlt,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: EnhancedTheme.accent.withOpacity(0.3)),
                    ),
                    child: Text(
                      _response,
                      style: EnhancedTheme.bodyM,
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _inputController,
                        decoration: InputDecoration(
                          hintText: 'Спросите Katya...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: EnhancedTheme.darkSurfaceAlt,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _askAI(_inputController.text),
                      icon: const Icon(Icons.send_rounded),
                      label: const Text('Отправить'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Страница "О приложении"
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
          ModernCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_rounded, color: EnhancedTheme.accent, size: 28),
                    const SizedBox(width: 8),
                    Text('About / Docs', style: EnhancedTheme.titleL),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Quick links for demo: manifesto and press release (RU/EN). Use Copy to get file path, or open repo URL.',
                  style: EnhancedTheme.bodyM,
                ),
                const SizedBox(height: 16),
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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: EnhancedTheme.labelL.copyWith(fontWeight: FontWeight.w600)),
                Text(path, style: EnhancedTheme.bodyS),
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
        ],
      ),
    );
  }
}

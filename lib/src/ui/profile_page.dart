import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:katya_ai_rechain_mesh/src/enhanced_theme.dart';
import 'package:katya_ai_rechain_mesh/src/social/social_service.dart';
import 'package:katya_ai_rechain_mesh/src/ui/components/glass_card.dart';
import 'package:katya_ai_rechain_mesh/src/ui/components/particle_background.dart';
import 'home_page.dart';
import 'settings_page.dart';
import 'messenger_page.dart';
import 'devices_page.dart';
import 'voting_screen.dart';
import 'ai_page.dart' as ai;

/// Страница профиля пользователя с навигацией по проекту
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage>
    with TickerProviderStateMixin {
  late UserProfile currentProfile;
  late TabController _navigationController;

  final List<NavigationMenuItem> _navigationMenu = [
    NavigationMenuItem(
      title: 'Главная',
      icon: Icons.home_rounded,
      description: 'Перейти на главную страницу',
      page: const HomePage(),
    ),
    NavigationMenuItem(
      title: 'Сообщения',
      icon: Icons.chat_rounded,
      description: 'Мессенджер и общение',
      page: const MessengerPage(),
    ),
    NavigationMenuItem(
      title: 'Устройства',
      icon: Icons.devices_rounded,
      description: 'Управление устройствами',
      page: const DevicesPage(),
    ),
    NavigationMenuItem(
      title: 'Голосования',
      icon: Icons.how_to_vote_rounded,
      description: 'Участие в голосованиях',
      page: const VotingScreen(),
    ),
    NavigationMenuItem(
      title: 'Katya AI',
      icon: Icons.smart_toy_rounded,
      description: 'Общение с ИИ помощником',
      page: const ai.AIPage(),
    ),
    NavigationMenuItem(
      title: 'Настройки',
      icon: Icons.settings_rounded,
      description: 'Параметры приложения',
      page: const SettingsPage(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _navigationController = TabController(
      length: _navigationMenu.length,
      vsync: this,
    );
    _loadUserProfile();
  }

  @override
  void dispose() {
    _navigationController.dispose();
    super.dispose();
  }

  void _loadUserProfile() {
    final socialService = SocialService.instance;
    final userId = socialService.currentUserId ?? 'user_${DateTime.now().millisecondsSinceEpoch}';
    
    // Получаем текущий профиль или создаем новый
    currentProfile = UserProfile(
      userId: userId,
      username: 'user_${userId.hashCode.abs() % 10000}',
      displayName: 'Мой профиль',
      bio: 'Добро пожаловать в REChain Mesh! 🚀',
      avatarUrl: null,
      interests: ['mesh', 'ai', 'crypto'],
      isOnline: true,
      lastSeen: DateTime.now(),
      createdAt: DateTime.now(),
      followersCount: 42,
      followingCount: 28,
      postsCount: 15,
    );
  }

  void _navigateToPage(int index) {
    final selectedMenu = _navigationMenu[index];
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => selectedMenu.page,
      ),
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
            decoration: const BoxDecoration(
              gradient: EnhancedTheme.spaceGradient,
            ),
            child: const ParticleBackground(
              child: SizedBox.expand(),
            ),
          ),
          // Основной контент
          SingleChildScrollView(
            child: Column(
              children: [
                // Заголовок
                Container(
                  padding: const EdgeInsets.only(
                    top: 50,
                    left: 20,
                    right: 20,
                    bottom: 20,
                  ),
                  child: Text(
                    'Мой профиль',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                // Карточка профиля
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Аватар
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: EnhancedTheme.accentGradient,
                            boxShadow: EnhancedTheme.primaryShadow,
                          ),
                          child: Icon(
                            Icons.person_rounded,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Имя
                        Text(
                          currentProfile.displayName,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        // Ник
                        Text(
                          '@${currentProfile.username}',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: EnhancedTheme.accent,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        // Статус
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.green,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withValues(alpha: 0.5),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Online',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.green,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Биография
                        if (currentProfile.bio.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            child: Text(
                              currentProfile.bio,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.white70,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Статистика
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Подписчики',
                          value: currentProfile.followersCount.toString(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: 'Подписки',
                          value: currentProfile.followingCount.toString(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: 'Посты',
                          value: currentProfile.postsCount.toString(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Интересы
                if (currentProfile.interests.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Интересы',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                color: Colors.white,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: currentProfile.interests
                              .map(
                                (interest) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: EnhancedTheme.accentGradient,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    interest,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 32),
                // Меню навигации
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Навигация проекта',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                      const SizedBox(height: 12),
                      ...List.generate(
                        _navigationMenu.length,
                        (index) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _NavigationTile(
                            item: _navigationMenu[index],
                            onTap: () => _navigateToPage(index),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: EnhancedTheme.accent,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _NavigationTile extends StatefulWidget {
  final NavigationMenuItem item;
  final VoidCallback onTap;

  const _NavigationTile({
    required this.item,
    required this.onTap,
  });

  @override
  State<_NavigationTile> createState() => _NavigationTileState();
}

class _NavigationTileState extends State<_NavigationTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: GlassCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                widget.item.icon,
                color: _isHovered ? EnhancedTheme.accent : Colors.white.withValues(alpha: 0.7),
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.item.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white54,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                color:
                    _isHovered ? EnhancedTheme.accent : Colors.white.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NavigationMenuItem {
  final String title;
  final IconData icon;
  final String description;
  final Widget page;

  NavigationMenuItem({
    required this.title,
    required this.icon,
    required this.description,
    required this.page,
  });
}

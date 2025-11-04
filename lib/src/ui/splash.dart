import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import 'home_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _particleController;
  late Animation<double> _logoAnimation;
  late Animation<double> _textAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _textAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeInOut),
    );

    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.linear),
    );

    _startAnimations();
  }

  void _startAnimations() async {
    await _logoController.forward();
    await _textController.forward();
    _particleController.repeat();

    // Переход к главной странице через 3 секунды
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      // Используем правильную навигацию для Navigator.pages
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: KatyaTheme.spaceGradient),
        child: Stack(
          children: [
            // Анимированные частицы
            ...List.generate(20, (index) => _buildParticle(index)),

            // Основной контент
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Логотип с анимацией - используем Icon вместо SVG для надежности
                  AnimatedBuilder(
                    animation: _logoAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _logoAnimation.value,
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: KatyaTheme.accentGradient,
                            boxShadow: KatyaTheme.spaceShadow,
                          ),
                          child: const Icon(
                            Icons.rocket_launch,
                            color: Colors.white,
                            size: 80,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Текст с анимацией
                  AnimatedBuilder(
                    animation: _textAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _textAnimation.value,
                        child: Column(
                          children: [
                            Text(
                              'Katya AI',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineLarge
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'REChain Mesh',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    color: KatyaTheme.accent,
                                    fontWeight: FontWeight.w300,
                                    letterSpacing: 1,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Advanced Blockchain AI Platform',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: KatyaTheme.onSurface.withOpacity(
                                      0.8,
                                    ),
                                  ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Индикатор загрузки
            const Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      KatyaTheme.accent,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticle(int index) {
    return AnimatedBuilder(
      animation: _particleAnimation,
      builder: (context, child) {
        final offset = _particleAnimation.value * 2 * 3.14159;
        final x = (MediaQuery.of(context).size.width * 0.5) +
            (100 * (index % 3 - 1) * (1 + 0.5 * (index % 2))) +
            (50 * (index % 2 == 0 ? 1 : -1) * math.sin(offset + index * 0.5));
        final y = (MediaQuery.of(context).size.height * 0.5) +
            (100 * (index % 2 - 0.5) * (1 + 0.3 * (index % 3))) +
            (30 * (index % 3 == 0 ? 1 : -1) * math.cos(offset + index * 0.3));

        return Positioned(
          left: x,
          top: y,
          child: Opacity(
            opacity: (1 - _particleAnimation.value).clamp(0.0, 1.0),
            child: Container(
              width: 4 + (index % 3),
              height: 4 + (index % 3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index % 2 == 0 ? KatyaTheme.accent : KatyaTheme.primary,
                boxShadow: [
                  BoxShadow(
                    color: (index % 2 == 0
                            ? KatyaTheme.accent
                            : KatyaTheme.primary)
                        .withOpacity(0.6),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

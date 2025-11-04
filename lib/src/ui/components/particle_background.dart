import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme.dart';

class ParticleBackground extends StatefulWidget {
  final Widget child;
  final int particleCount;
  final Duration animationDuration;
  final Color? particleColor;

  const ParticleBackground({
    super.key,
    required this.child,
    this.particleCount = 20,
    this.animationDuration = const Duration(seconds: 3),
    this.particleColor,
  });

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  final List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));

    _initializeParticles();
    _animationController.repeat();
  }

  void _initializeParticles() {
    final random = math.Random();
    _particles.clear();

    for (int i = 0; i < widget.particleCount; i++) {
      _particles.add(Particle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: 2 + random.nextDouble() * 4,
        speed: 0.5 + random.nextDouble() * 1.5,
        direction: random.nextDouble() * 2 * math.pi,
        color: widget.particleColor ??
            (random.nextBool() ? KatyaTheme.accent : KatyaTheme.primary),
        opacity: 0.3 + random.nextDouble() * 0.7,
      ));
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return CustomPaint(
              painter: ParticlePainter(
                particles: _particles,
                animationValue: _animation.value,
              ),
              size: Size.infinite,
            );
          },
        ),
      ],
    );
  }
}

class Particle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double direction;
  final Color color;
  final double opacity;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.direction,
    required this.color,
    required this.opacity,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;

  ParticlePainter({
    required this.particles,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.opacity)
        ..style = PaintingStyle.fill;

      // Вычисляем позицию частицы с учетом анимации
      final offset = animationValue * particle.speed;
      final newX = (particle.x * size.width +
              math.cos(particle.direction) * offset * 100) %
          size.width;
      final newY = (particle.y * size.height +
              math.sin(particle.direction) * offset * 100) %
          size.height;

      // Рисуем частицу
      canvas.drawCircle(
        Offset(newX, newY),
        particle.size,
        paint,
      );

      // Добавляем свечение
      final glowPaint = Paint()
        ..color = particle.color.withOpacity(particle.opacity * 0.3)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      canvas.drawCircle(
        Offset(newX, newY),
        particle.size * 2,
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

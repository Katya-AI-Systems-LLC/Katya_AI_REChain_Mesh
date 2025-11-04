import 'package:flutter/material.dart';
import 'package:katya_ai_rechain_mesh/quantum/src/quantum_state.dart';

class QuantumStateViewer extends StatelessWidget {
  final QuantumState state;
  final double size;
  final Color? baseColor;
  final bool showLabels;

  const QuantumStateViewer({
    super.key,
    required this.state,
    this.size = 200.0,
    this.baseColor,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = baseColor ?? colorScheme.primary;

    return CustomPaint(
      size: Size(size, size),
      painter: _QuantumStatePainter(
        state: state,
        color: color,
        showLabels: showLabels,
        textStyle: theme.textTheme.bodyMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _QuantumStatePainter extends CustomPainter {
  final QuantumState state;
  final Color color;
  final bool showLabels;
  final TextStyle? textStyle;

  _QuantumStatePainter({
    required this.state,
    required this.color,
    required this.showLabels,
    this.textStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;

    // Draw the Bloch sphere
    _drawBlochSphere(canvas, center, radius);

    // Draw the quantum state vector
    _drawStateVector(canvas, center, radius);

    // Draw labels if enabled
    if (showLabels) {
      _drawLabels(canvas, size);
    }
  }

  void _drawBlochSphere(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw the main circle
    canvas.drawCircle(center, radius, paint);

    // Draw the equator
    canvas.drawCircle(center, radius, paint);

    // Draw the vertical circle (perpendicular to the view)
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, 0, 3.14159 * 2, false, paint);
  }

  void _drawStateVector(Canvas canvas, Offset center, double radius) {
    // For simplicity, we'll just draw a line from center to surface
    // In a real implementation, this would use the actual quantum state
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Draw the state vector
    canvas.drawLine(
      center,
      Offset(center.dx + radius * 0.7, center.dy - radius * 0.7),
      paint,
    );

    // Draw the arrow head
    final arrowPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(center.dx + radius * 0.9, center.dy - radius * 0.9);
    path.lineTo(center.dx + radius * 0.7, center.dy - radius * 0.7);
    path.lineTo(center.dx + radius * 0.8, center.dy - radius * 0.5);
    path.close();

    canvas.drawPath(path, arrowPaint);
  }

  void _drawLabels(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    // Draw |0> and |1> labels
    _drawLabel(canvas, '|0⟩', Offset(size.width / 2, 10), textPainter);
    _drawLabel(
        canvas, '|1⟩', Offset(size.width / 2, size.height - 20), textPainter);
    _drawLabel(
        canvas, '|+⟩', Offset(size.width - 20, size.height / 2), textPainter);
    _drawLabel(canvas, '|-⟩', Offset(10, size.height / 2), textPainter);
  }

  void _drawLabel(
      Canvas canvas, String text, Offset position, TextPainter textPainter) {
    textPainter.text = TextSpan(
      text: text,
      style: textStyle,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      position - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _QuantumStatePainter oldDelegate) {
    return oldDelegate.state != state ||
        oldDelegate.color != color ||
        oldDelegate.showLabels != showLabels;
  }
}

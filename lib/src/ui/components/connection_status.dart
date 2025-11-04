import 'package:flutter/material.dart';
import '../../theme.dart';

class ConnectionStatus extends StatefulWidget {
  final bool isConnected;
  final String? deviceName;
  final int? signalStrength;
  final VoidCallback? onTap;

  const ConnectionStatus({
    super.key,
    required this.isConnected,
    this.deviceName,
    this.signalStrength,
    this.onTap,
  });

  @override
  State<ConnectionStatus> createState() => _ConnectionStatusState();
}

class _ConnectionStatusState extends State<ConnectionStatus>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    if (widget.isConnected) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(ConnectionStatus oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isConnected && !oldWidget.isConnected) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isConnected && oldWidget.isConnected) {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color _getStatusColor() {
    if (widget.isConnected) {
      if (widget.signalStrength != null) {
        if (widget.signalStrength! > -50) return KatyaTheme.success;
        if (widget.signalStrength! > -70) return KatyaTheme.warning;
        return KatyaTheme.error;
      }
      return KatyaTheme.success;
    }
    return KatyaTheme.onSurface.withOpacity(0.5);
  }

  String _getStatusText() {
    if (widget.isConnected) {
      if (widget.deviceName != null) {
        return 'Подключено к ${widget.deviceName}';
      }
      return 'Подключено';
    }
    return 'Не подключено';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _getStatusColor().withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _getStatusColor().withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: widget.isConnected ? _pulseAnimation.value : 1.0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _getStatusColor(),
                      shape: BoxShape.circle,
                      boxShadow: widget.isConnected
                          ? [
                              BoxShadow(
                                color: _getStatusColor().withOpacity(0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
            Text(
              _getStatusText(),
              style: TextStyle(
                color: _getStatusColor(),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (widget.signalStrength != null) ...[
              const SizedBox(width: 8),
              _buildSignalIndicator(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSignalIndicator() {
    final strength = widget.signalStrength!;
    final bars = <Widget>[];

    // Определяем количество полосок в зависимости от силы сигнала
    int barCount = 0;
    if (strength > -50) {
      barCount = 4;
    } else if (strength > -60)
      barCount = 3;
    else if (strength > -70)
      barCount = 2;
    else if (strength > -80) barCount = 1;

    for (int i = 0; i < 4; i++) {
      bars.add(
        Container(
          width: 3,
          height: 4 + (i * 2),
          margin: const EdgeInsets.only(right: 1),
          decoration: BoxDecoration(
            color: i < barCount
                ? _getStatusColor()
                : _getStatusColor().withOpacity(0.3),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: bars,
    );
  }
}

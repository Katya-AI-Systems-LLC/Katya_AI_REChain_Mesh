import 'package:flutter/material.dart';

class QuantumLoading extends StatefulWidget {
  final bool isLoading;
  final Widget child;
  final String? loadingText;
  final double opacity;
  final Color? color;
  final Widget? progressIndicator;

  const QuantumLoading({
    super.key,
    required this.isLoading,
    required this.child,
    this.loadingText,
    this.opacity = 0.7,
    this.color,
    this.progressIndicator,
  });

  @override
  _QuantumLoadingState createState() => _QuantumLoadingState();
}

class _QuantumLoadingState extends State<QuantumLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final defaultColor = colorScheme.primary.withOpacity(0.7);

    return Stack(
      children: [
        // Main content
        widget.child,

        // Loading overlay
        if (widget.isLoading)
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              color: (widget.color ?? defaultColor).withOpacity(
                widget.isLoading ? widget.opacity : 0.0,
              ),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: widget.isLoading ? 1.0 : 0.0,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated progress indicator
                      ScaleTransition(
                        scale: _animation,
                        child: widget.progressIndicator ??
                            const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 3.0,
                            ),
                      ),

                      // Loading text
                      if (widget.loadingText != null) ...[
                        const SizedBox(height: 16.0),
                        Text(
                          widget.loadingText!,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// Example usage:
/*
QuantumLoading(
  isLoading: _isLoading,
  loadingText: 'Entangling qubits...',
  child: YourWidget(),
)
*/

import 'package:flutter/material.dart';
import '../../enhanced_theme.dart';

/// Современный AppBar с поддержкой кастомизации
class ModernAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final bool showDivider;

  const ModernAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.onBackPressed,
    this.backgroundColor,
    this.showDivider = true,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? EnhancedTheme.darkSurface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: AppBar(
        title: Text(title, style: EnhancedTheme.headingS),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: showBackButton
            ? leading ??
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: onBackPressed ?? () => Navigator.pop(context),
                )
            : leading,
        actions: actions,
        centerTitle: true,
      ),
    );
  }
}

/// Современная карточка с улучшенным дизайном
class ModernCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final Color? backgroundColor;
  final double borderRadius;
  final bool enableHover;
  final Duration animationDuration;
  final List<BoxShadow>? shadows;

  const ModernCard({
    Key? key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.all(8),
    this.backgroundColor,
    this.borderRadius = 16,
    this.enableHover = true,
    this.animationDuration = const Duration(milliseconds: 200),
    this.shadows,
  }) : super(key: key);

  @override
  State<ModernCard> createState() => _ModernCardState();
}

class _ModernCardState extends State<ModernCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => widget.enableHover ? setState(() => _isHovered = true) : null,
      onExit: (_) => widget.enableHover ? setState(() => _isHovered = false) : null,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: widget.animationDuration,
          margin: widget.margin,
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? EnhancedTheme.darkSurface,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: widget.shadows ??
                [
                  BoxShadow(
                    color: Colors.black.withOpacity(_isHovered ? 0.2 : 0.1),
                    blurRadius: _isHovered ? 12 : 8,
                    offset: Offset(0, _isHovered ? 4 : 2),
                  ),
                ],
          ),
          transform: _isHovered
              ? Matrix4.identity()..scale(1.02)
              : Matrix4.identity(),
          child: Padding(
            padding: widget.padding,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Анимированная кнопка с эффектами
class AnimatedIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final double size;
  final Duration animationDuration;
  final bool showLabel;
  final String? label;

  const AnimatedIconButton({
    Key? key,
    required this.icon,
    this.onPressed,
    this.color,
    this.size = 24,
    this.animationDuration = const Duration(milliseconds: 200),
    this.showLabel = false,
    this.label,
  }) : super(key: key);

  @override
  State<AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<AnimatedIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handlePressed() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ScaleTransition(
          scale: _scaleAnimation,
          child: IconButton(
            icon: Icon(widget.icon),
            onPressed: _handlePressed,
            color: widget.color ?? EnhancedTheme.accent,
            iconSize: widget.size,
            tooltip: widget.label,
          ),
        ),
        if (widget.showLabel && widget.label != null)
          Text(
            widget.label!,
            style: EnhancedTheme.labelS,
          ),
      ],
    );
  }
}

/// Загружающийся элемент с shimmer эффектом
class ShimmerLoading extends StatefulWidget {
  final double height;
  final double width;
  final BorderRadius borderRadius;

  const ShimmerLoading({
    Key? key,
    this.height = 16,
    this.width = double.infinity,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  }) : super(key: key);

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: LinearGradient(
              begin: Alignment(-1.0 + (_animationController.value * 2.0), 0),
              end: Alignment(1.0 + (_animationController.value * 2.0), 0),
              colors: [
                EnhancedTheme.shimmerBase,
                EnhancedTheme.shimmerHighlight,
                EnhancedTheme.shimmerBase,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Контейнер для отображения пустого состояния
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  const EmptyState({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: EnhancedTheme.accent.withOpacity(0.6),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: EnhancedTheme.headingM,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: EnhancedTheme.bodyM,
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[
            const SizedBox(height: 24),
            action!,
          ],
        ],
      ),
    );
  }
}

/// Чип с поддержкой различных состояний
class ModernChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onSelected;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? labelColor;
  final EdgeInsets padding;

  const ModernChip({
    Key? key,
    required this.label,
    this.selected = false,
    this.onSelected,
    this.icon,
    this.backgroundColor,
    this.labelColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: padding,
        decoration: BoxDecoration(
          color: selected
              ? (backgroundColor ?? EnhancedTheme.accent)
              : EnhancedTheme.darkSurfaceAlt,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? EnhancedTheme.accent : EnhancedTheme.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: selected ? Colors.white : EnhancedTheme.accent,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: EnhancedTheme.labelM.copyWith(
                color: selected ? Colors.white : (labelColor ?? EnhancedTheme.textPrimary),
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Современный divider с опциональным текстом
class ModernDivider extends StatelessWidget {
  final String? text;
  final Color? color;
  final double height;
  final EdgeInsets padding;

  const ModernDivider({
    Key? key,
    this.text,
    this.color,
    this.height = 16,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (text == null || text!.isEmpty) {
      return Padding(
        padding: padding,
        child: Divider(
          color: color ?? EnhancedTheme.border,
          height: height,
        ),
      );
    }

    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: color ?? EnhancedTheme.border,
              height: height,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              text!,
              style: EnhancedTheme.labelM,
            ),
          ),
          Expanded(
            child: Divider(
              color: color ?? EnhancedTheme.border,
              height: height,
            ),
          ),
        ],
      ),
    );
  }
}

/// Индикатор статуса с анимацией
class StatusIndicator extends StatefulWidget {
  final bool isActive;
  final Color? activeColor;
  final Color? inactiveColor;
  final double size;
  final String? label;

  const StatusIndicator({
    Key? key,
    required this.isActive,
    this.activeColor,
    this.inactiveColor,
    this.size = 12,
    this.label,
  }) : super(key: key);

  @override
  State<StatusIndicator> createState() => _StatusIndicatorState();
}

class _StatusIndicatorState extends State<StatusIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    if (widget.isActive) {
      _animationController.repeat();
    }
  }

  @override
  void didUpdateWidget(StatusIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _animationController.repeat();
      } else {
        _animationController.stop();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.2).animate(
            CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
          ),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.isActive
                  ? (widget.activeColor ?? EnhancedTheme.success)
                  : (widget.inactiveColor ?? EnhancedTheme.textSecondary),
              boxShadow: widget.isActive
                  ? [
                      BoxShadow(
                        color: (widget.activeColor ?? EnhancedTheme.success)
                            .withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
          ),
        ),
        if (widget.label != null) ...[
          const SizedBox(width: 8),
          Text(
            widget.label!,
            style: EnhancedTheme.bodyS,
          ),
        ],
      ],
    );
  }
}

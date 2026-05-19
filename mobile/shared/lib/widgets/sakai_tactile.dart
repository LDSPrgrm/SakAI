import 'package:flutter/material.dart';

/// A premium micro-interaction wrapper widget that animates its child scale down slightly
/// on user interaction (touch/tap down) and returns to normal on release or cancel,
/// providing tactile and organic physical button feedback.
class SakaiTactile extends StatefulWidget {
  const SakaiTactile({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.96,
    this.duration = const Duration(milliseconds: 100),
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final Duration duration;

  @override
  State<SakaiTactile> createState() => _SakaiTactileState();
}

class _SakaiTactileState extends State<SakaiTactile> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scale).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isInteractive = widget.onTap != null;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: isInteractive ? (_) => _controller.forward() : null,
      onTapUp: isInteractive
          ? (_) async {
              await _controller.reverse();
              widget.onTap?.call();
            }
          : null,
      onTapCancel: isInteractive ? () => _controller.reverse() : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

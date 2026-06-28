import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Driver-side reveal for a passenger tip on completed rides.
///
/// Renders a centered icon + amount that animates in with a soft
/// elastic bounce and gentle scale; suitable for use inside a modal,
/// a Hero on the ride_complete screen, or stacked above the earnings
/// total during the post-ride fade.
///
/// Pure UI — no haptics or sound triggered from here. Callers that want
/// either should drive them from outside so this widget remains safe to
/// composite in tests / golden snapshots.
class SakaiTipCelebration extends StatefulWidget {
  /// Tip amount in PHP. Rendered as `₱<amount>` with no decimals when
  /// the value is whole; up to two decimals otherwise.
  final double amount;

  /// Label rendered under the amount. Defaults to "Passenger tip".
  final String label;

  /// Optional secondary line (e.g. "Thanks for the smooth ride!").
  final String? subtitle;

  const SakaiTipCelebration({
    super.key,
    required this.amount,
    this.label = 'Passenger tip',
    this.subtitle,
  });

  @override
  State<SakaiTipCelebration> createState() => _SakaiTipCelebrationState();
}

class _SakaiTipCelebrationState extends State<SakaiTipCelebration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.6, end: 1.08).chain(
          CurveTween(curve: Curves.easeOutCubic),
        ),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.08, end: 1.0).chain(
          CurveTween(curve: Curves.easeInOutCubic),
        ),
        weight: 40,
      ),
    ]).animate(_controller);
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatted() {
    if (widget.amount == widget.amount.roundToDouble()) {
      return NumberFormat.currency(
        locale: 'en_PH',
        symbol: '₱',
        decimalDigits: 0,
      ).format(widget.amount);
    }
    return NumberFormat.currency(
      locale: 'en_PH',
      symbol: '₱',
      decimalDigits: 2,
    ).format(widget.amount);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return ScaleTransition(
      scale: _scale,
      child: FadeTransition(
        opacity: _opacity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: scheme.primaryContainer,
              child: Icon(
                Icons.celebration_outlined,
                color: scheme.onPrimaryContainer,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _formatted(),
              style: text.displaySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(widget.label, style: text.titleMedium),
            if (widget.subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                widget.subtitle!,
                style: text.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

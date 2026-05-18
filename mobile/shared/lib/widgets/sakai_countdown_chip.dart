import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/sakai_design_tokens.dart';
import '../theme/sakai_semantic_colors.dart';

/// Live countdown chip toward [deadline]. Pulses scale and switches to the
/// danger palette once `remaining <= dangerThreshold`. Internal Ticker is
/// subtree-confined so the parent does not rebuild every second.
class SakaiCountdownChip extends StatefulWidget {
  const SakaiCountdownChip({
    super.key,
    required this.deadline,
    this.dangerThreshold = const Duration(seconds: 5),
    this.onExpired,
    this.icon = Icons.timer_outlined,
  });

  final DateTime deadline;
  final Duration dangerThreshold;
  final VoidCallback? onExpired;
  final IconData icon;

  @override
  State<SakaiCountdownChip> createState() => _SakaiCountdownChipState();
}

class _SakaiCountdownChipState extends State<SakaiCountdownChip>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      lowerBound: 1.0,
      upperBound: 1.05,
    );
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (!mounted) return;
      setState(() {});
      if (_remaining <= Duration.zero) {
        _timer?.cancel();
        widget.onExpired?.call();
      }
    });
  }

  Duration get _remaining {
    final r = widget.deadline.difference(DateTime.now());
    return r.isNegative ? Duration.zero : r;
  }

  bool get _danger => _remaining <= widget.dangerThreshold;

  @override
  void dispose() {
    _timer?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = SakaiDesignTokens.of(context);
    final s = SakaiSemanticColors.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final r = _remaining;
    final fg = _danger ? s.danger : scheme.onSurface;
    final bg = _danger ? s.dangerSubtle : scheme.surfaceContainerHighest;

    if (_danger) {
      if (!_pulse.isAnimating) _pulse.repeat(reverse: true);
    } else if (_pulse.isAnimating) {
      _pulse.stop();
      _pulse.value = 1.0;
    }

    final text = r.inSeconds >= 60
        ? '${r.inMinutes}:${(r.inSeconds % 60).toString().padLeft(2, '0')}'
        : '${r.inSeconds}s';

    return ScaleTransition(
      scale: _pulse,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: t.spaceMd,
          vertical: t.spaceSm,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(t.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, size: 16, color: fg),
            SizedBox(width: t.spaceXs),
            Text(
              text,
              style: theme.textTheme.labelLarge?.copyWith(
                color: fg,
                fontFeatures: const [FontFeature.tabularFigures()],
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// A column that fades + slides its children in one-by-one with a small
/// per-row stagger. Used by the receipt + earnings breakdown screens so
/// the fare components feel like they're being tallied rather than
/// dumped on screen all at once.
///
/// Each child is wrapped in its own [AnimatedSlide] / [AnimatedOpacity]
/// pair driven by a [Future.delayed] tick — no controller plumbing
/// required at the call site.
class SakaiPhasedReveal extends StatefulWidget {
  /// The rows to reveal. Order is preserved.
  final List<Widget> children;

  /// Stagger between successive rows. Default 90 ms matches the rhythm
  /// of the rest of the SakAI motion library (see `SakaiTactile`).
  final Duration stagger;

  /// Duration of each row's own fade/slide animation.
  final Duration rowDuration;

  /// How far each row starts below its final position, in logical
  /// pixels. The slide is rendered via [AnimatedSlide]'s `Offset.dy`
  /// proportional to the parent height, so this is approximate — values
  /// between 8 and 16 read well in practice.
  final double slideY;

  /// Cross-axis alignment forwarded to the underlying [Column].
  final CrossAxisAlignment crossAxisAlignment;

  /// Spacing inserted between successive children. Matches the existing
  /// design-token spacing convention.
  final double spacing;

  const SakaiPhasedReveal({
    super.key,
    required this.children,
    this.stagger = const Duration(milliseconds: 90),
    this.rowDuration = const Duration(milliseconds: 280),
    this.slideY = 12,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
    this.spacing = 8,
  });

  @override
  State<SakaiPhasedReveal> createState() => _SakaiPhasedRevealState();
}

class _SakaiPhasedRevealState extends State<SakaiPhasedReveal> {
  late List<bool> _revealed;

  @override
  void initState() {
    super.initState();
    _revealed = List<bool>.filled(widget.children.length, false);
    _schedule();
  }

  @override
  void didUpdateWidget(covariant SakaiPhasedReveal oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-stagger if the list length changed (e.g. data loaded after
    // an empty initial render). Existing entries stay revealed.
    if (widget.children.length != _revealed.length) {
      final previous = _revealed;
      _revealed = List<bool>.generate(
        widget.children.length,
        (i) => i < previous.length ? previous[i] : false,
      );
      _schedule();
    }
  }

  void _schedule() {
    for (var i = 0; i < _revealed.length; i++) {
      if (_revealed[i]) continue;
      final index = i;
      Future.delayed(widget.stagger * index, () {
        if (!mounted) return;
        setState(() => _revealed[index] = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: widget.crossAxisAlignment,
      children: [
        for (var i = 0; i < widget.children.length; i++) ...[
          if (i > 0) SizedBox(height: widget.spacing),
          AnimatedSlide(
            duration: widget.rowDuration,
            curve: Curves.easeOutCubic,
            offset: _revealed[i]
                ? Offset.zero
                : Offset(0, widget.slideY / 100),
            child: AnimatedOpacity(
              duration: widget.rowDuration,
              curve: Curves.easeOut,
              opacity: _revealed[i] ? 1 : 0,
              child: widget.children[i],
            ),
          ),
        ],
      ],
    );
  }
}

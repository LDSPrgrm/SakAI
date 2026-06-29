import 'package:flutter/material.dart';

import '../theme/sakai_design_tokens.dart';

/// Shimmer placeholders for list / card / line loading states. Hand-rolled
/// gradient sweep — no third-party shimmer dependency.
class SakaiSkeleton extends StatefulWidget {
  const SakaiSkeleton._({
    this.width,
    required this.height,
    this.radius,
    this.shape = BoxShape.rectangle,
  });

  factory SakaiSkeleton.line({double? width, double height = 12}) =>
      SakaiSkeleton._(width: width, height: height);

  factory SakaiSkeleton.card({double height = 96}) =>
      SakaiSkeleton._(height: height, radius: 16);

  factory SakaiSkeleton.circle({double size = 48}) => SakaiSkeleton._(
        width: size,
        height: size,
        shape: BoxShape.circle,
      );

  /// Vertical stack of [itemCount] card skeletons separated by token spacing.
  static Widget list({int itemCount = 4, double itemHeight = 88}) {
    return _SkeletonList(itemCount: itemCount, itemHeight: itemHeight);
  }

  final double? width;
  final double height;
  final double? radius;
  final BoxShape shape;

  @override
  State<SakaiSkeleton> createState() => _SakaiSkeletonState();
}

class _SkeletonList extends StatelessWidget {
  const _SkeletonList({required this.itemCount, required this.itemHeight});

  final int itemCount;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    final t = SakaiDesignTokens.of(context);
    return ListView.separated(
      padding: EdgeInsets.all(t.spaceMd),
      itemCount: itemCount,
      separatorBuilder: (_, _) => SizedBox(height: t.spaceSm),
      itemBuilder: (_, _) => SakaiSkeleton.card(height: itemHeight),
    );
  }
}

class _SakaiSkeletonState extends State<SakaiSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = scheme.surfaceContainerHighest;
    final highlight = Color.lerp(base, scheme.onSurface.withValues(alpha: 0.08), 0.5)!;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) {
        final v = _ctrl.value;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            shape: widget.shape,
            borderRadius: widget.shape == BoxShape.rectangle
                ? BorderRadius.circular(widget.radius ?? 8)
                : null,
            gradient: LinearGradient(
              begin: Alignment(-1 + 2 * v, 0),
              end: Alignment(1 + 2 * v, 0),
              colors: [base, highlight, base],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

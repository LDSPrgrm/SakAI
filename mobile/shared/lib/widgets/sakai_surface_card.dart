import 'package:flutter/material.dart';

import '../theme/sakai_design_tokens.dart';

/// Card container using theme card shape and padding from design tokens.
class SakaiSurfaceCard extends StatelessWidget {
  const SakaiSurfaceCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final t = SakaiDesignTokens.of(context);
    final inset = padding ?? EdgeInsets.all(t.spaceMd);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: inset,
          child: child,
        ),
      ),
    );
  }
}

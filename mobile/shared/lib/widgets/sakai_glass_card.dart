import 'dart:ui';
import 'package:flutter/material.dart';

import '../theme/sakai_design_tokens.dart';

/// A card with glassmorphism effect (blur + semi-transparent background).
class SakaiGlassCard extends StatelessWidget {
  const SakaiGlassCard({
    super.key,
    required this.child,
    this.blur = 15.0,
    this.opacity = 0.1,
    this.padding,
    this.borderRadius,
    this.borderOpacity = 0.2,
  });

  final Widget child;
  final double blur;
  final double opacity;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final double borderOpacity;

  @override
  Widget build(BuildContext context) {
    final tokens = SakaiDesignTokens.of(context);
    final radius = borderRadius ?? BorderRadius.circular(tokens.radiusLg);
    final inset = padding ?? EdgeInsets.all(tokens.spaceMd);
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: opacity),
            borderRadius: radius,
            border: Border.all(
              color: colorScheme.onSurface.withValues(alpha: borderOpacity),
              width: 1.5,
            ),
          ),
          child: Padding(padding: inset, child: child),
        ),
      ),
    );
  }
}

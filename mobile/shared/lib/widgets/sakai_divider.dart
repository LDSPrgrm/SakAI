import 'package:flutter/material.dart';

import '../theme/sakai_design_tokens.dart';

/// Optional horizontal inset bucket for [SakaiDivider]. Use [sm] for tight
/// lists, [md] for sectioned screens, and [none] when the divider should
/// span edge-to-edge.
enum SakaiDividerInset { none, sm, md }

/// Hairline horizontal rule using the theme's outline-variant color and the
/// design system's hairline thickness. Pads the rule horizontally based on
/// [inset] so it can sit cleanly inside cards or full-bleed sections.
class SakaiDivider extends StatelessWidget {
  const SakaiDivider({super.key, this.inset = SakaiDividerInset.none});

  final SakaiDividerInset inset;

  @override
  Widget build(BuildContext context) {
    final tokens = SakaiDesignTokens.of(context);
    final scheme = Theme.of(context).colorScheme;
    final pad = switch (inset) {
      SakaiDividerInset.none => 0.0,
      SakaiDividerInset.sm => tokens.spaceSm,
      SakaiDividerInset.md => tokens.spaceMd,
    };
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: pad),
      child: Divider(
        height: tokens.borderHairline + tokens.spaceXs * 2,
        thickness: tokens.borderHairline,
        color: scheme.outlineVariant,
      ),
    );
  }
}

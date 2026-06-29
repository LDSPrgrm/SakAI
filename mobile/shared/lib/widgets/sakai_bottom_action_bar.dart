import 'package:flutter/material.dart';

import '../theme/sakai_design_tokens.dart';

/// Sticky bottom action surface with safe-area padding and a hairline top
/// border. Designed for screen body use — do **not** mount as
/// `Scaffold.bottomNavigationBar` (SafeArea would double-pad).
///
/// Children are laid out horizontally with equal spacing; expand them via
/// `Expanded` if you want them to fill available width.
class SakaiBottomActionBar extends StatelessWidget {
  const SakaiBottomActionBar({
    super.key,
    required this.actions,
    this.stickToSafeArea = true,
    this.background,
  });

  final List<Widget> actions;
  final bool stickToSafeArea;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final t = SakaiDesignTokens.of(context);
    final scheme = Theme.of(context).colorScheme;
    final bg = background ?? scheme.surface;

    final bar = Container(
      padding: EdgeInsets.symmetric(
        horizontal: t.spaceMd,
        vertical: t.spaceSm,
      ),
      decoration: BoxDecoration(
        color: bg,
        border: Border(
          top: BorderSide(color: scheme.outlineVariant, width: t.borderHairline),
        ),
      ),
      child: Row(
        children: [
          for (var i = 0; i < actions.length; i++) ...[
            if (i > 0) SizedBox(width: t.spaceSm),
            Expanded(child: actions[i]),
          ],
        ],
      ),
    );

    if (!stickToSafeArea) return bar;
    return SafeArea(
      top: false,
      minimum: EdgeInsets.only(bottom: t.spaceSm),
      child: bar,
    );
  }
}

import 'package:flutter/material.dart';

import '../theme/sakai_design_tokens.dart';

/// Static helper for showing themed modal bottom sheets that match the
/// SakAI design tokens (radius, elevation, surface color, drag handle).
///
/// Always prefer this over [showModalBottomSheet] directly so the chrome
/// stays consistent and screens don't redefine shape/elevation in every
/// call site.
class SakaiModalSheet {
  SakaiModalSheet._();

  /// Opens a themed modal bottom sheet and returns the value the caller
  /// pops with (or `null` if the user dismisses by tapping the barrier).
  ///
  /// * [builder] is wrapped in a `Flexible` so its content can grow up to
  ///   [maxHeightFactor] of the screen height before scrolling kicks in.
  /// * [dragHandle] adds the small pill at the top of the sheet. Disable
  ///   when the body already provides a visual grab affordance.
  /// * [isScrollControlled] mirrors [showModalBottomSheet]'s parameter and
  ///   should stay `true` for keyboards / dynamic content.
  static Future<T?> show<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    bool isScrollControlled = true,
    bool dragHandle = true,
    double maxHeightFactor = 0.9,
  }) {
    final tokens = SakaiDesignTokens.of(context);
    final scheme = Theme.of(context).colorScheme;
    final maxHeight = MediaQuery.of(context).size.height * maxHeightFactor;

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: scheme.surface,
      elevation: tokens.elevationModal,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(tokens.radiusLg)),
      ),
      constraints: BoxConstraints(maxHeight: maxHeight),
      builder: (ctx) {
        final insets = MediaQuery.of(ctx).viewInsets;
        return Padding(
          padding: EdgeInsets.only(bottom: insets.bottom),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (dragHandle) ...[
                  SizedBox(height: tokens.spaceSm),
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: scheme.outlineVariant,
                      borderRadius: BorderRadius.circular(tokens.radiusFull),
                    ),
                  ),
                  SizedBox(height: tokens.spaceSm),
                ],
                Flexible(child: builder(ctx)),
              ],
            ),
          ),
        );
      },
    );
  }
}

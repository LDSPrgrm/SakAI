import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sakai_shared/sakai_shared.dart' hide LatLng;

import '../../view_models/home_notifier.dart';

class HomeLocationChip extends ConsumerWidget {
  const HomeLocationChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = SakaiDesignTokens.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final state = ref.watch(homeNotifierProvider);
    final pickupAddress = state.pickup?.address;
    final label = pickupAddress != null && pickupAddress.isNotEmpty
        ? pickupAddress
        : (state.status == HomeStatus.locating
              ? 'Finding location…'
              : 'Current location');

    return Semantics(
      label: 'Current location: $label',
      child: Container(
        constraints: const BoxConstraints(maxWidth: 200),
        padding: EdgeInsets.symmetric(horizontal: tokens.spaceMd, vertical: 10),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(tokens.radiusFull),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: scheme.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.4),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: scheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

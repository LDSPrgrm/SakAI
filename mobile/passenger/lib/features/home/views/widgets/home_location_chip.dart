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
        constraints: const BoxConstraints(maxWidth: 220),
        padding: EdgeInsets.symmetric(
          horizontal: tokens.spaceMd,
          vertical: tokens.spaceSm,
        ),
        decoration: BoxDecoration(
          color: scheme.surface.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(tokens.radiusFull),
          boxShadow: tokens.elevationSm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.my_location,
              size: tokens.iconSm,
              color: scheme.primary,
            ),
            SizedBox(width: tokens.spaceXs),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

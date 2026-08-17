import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../../../../app/routes.dart';
import '../../../ride_history/models/ride_history_item.dart';
import '../../../ride_history/view_models/ride_history_list_view_model.dart';

class HomeRecentTrips extends ConsumerStatefulWidget {
  const HomeRecentTrips({super.key});

  @override
  ConsumerState<HomeRecentTrips> createState() => _HomeRecentTripsState();
}

class _HomeRecentTripsState extends ConsumerState<HomeRecentTrips> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final state = ref.read(rideHistoryListNotifierProvider);
      if (state.status == RideHistoryStatus.initial) {
        ref.read(rideHistoryListNotifierProvider.notifier).loadHistory();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = SakaiDesignTokens.of(context);
    final state = ref.watch(rideHistoryListNotifierProvider);

    if (state.status == RideHistoryStatus.loading && state.items.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: tokens.spaceLg),
        child: Column(
          children: List.generate(2, (_) {
            return Padding(
              padding: EdgeInsets.only(bottom: tokens.spaceSm),
              child: SakaiSkeleton.card(height: 72),
            );
          }),
        ),
      );
    }

    if (state.status == RideHistoryStatus.empty || state.items.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.spaceLg,
          vertical: tokens.spaceMd,
        ),
        child: Container(
          padding: EdgeInsets.all(tokens.spaceLg),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(tokens.radiusLg),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.history_rounded,
                color: Theme.of(context).colorScheme.outline,
                size: 32,
              ),
              SizedBox(height: tokens.spaceSm),
              Text(
                'No recent trips yet. Your journey starts here!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final visible = state.items.take(3).toList();
    return Column(
      key: const Key('home_recent_trips_list'),
      children: visible.map((item) => _RecentTripCard(item: item)).toList(),
    );
  }
}

// ── Recent Trip Card ──────────────────────────────────────────────────────────

class _RecentTripCard extends StatelessWidget {
  const _RecentTripCard({required this.item});

  final RideHistoryItem item;

  String _dateLabel(DateTime when) {
    final now = DateTime.now();
    final diff = now.difference(when);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${when.month}/${when.day}';
  }

  @override
  Widget build(BuildContext context) {
    final tokens = SakaiDesignTokens.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final semantic = SakaiSemanticColors.of(context);
    final fareValue = item.fare ?? item.estimatedFare;

    final isCancelled = item.status == RideStatus.cancelled;
    final isCompleted = item.status == RideStatus.completed;
    final isOngoing = !isCancelled && !isCompleted;

    // ── State-specific visuals ──────────────────────────────────────
    final Color iconColor;
    final Color iconBg;
    final Color borderColor;
    final Color? cardTint;
    final List<BoxShadow> shadows;
    final IconData statusIcon;

    if (isOngoing) {
      iconColor = scheme.primary;
      iconBg = scheme.primaryContainer.withValues(alpha: 0.7);
      borderColor = scheme.primary.withValues(alpha: 0.5);
      cardTint = scheme.primaryContainer.withValues(alpha: 0.07);
      shadows = [
        BoxShadow(
          color: scheme.primary.withValues(alpha: 0.14),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ];
      statusIcon = Icons.directions_car_rounded;
    } else if (isCompleted) {
      iconColor = semantic.success;
      iconBg = semantic.successSubtle;
      borderColor = semantic.success.withValues(alpha: 0.3);
      cardTint = semantic.success.withValues(alpha: 0.04);
      shadows = [
        BoxShadow(
          color: semantic.success.withValues(alpha: 0.08),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ];
      statusIcon = Icons.check_circle_rounded;
    } else {
      // cancelled
      iconColor = scheme.onSurfaceVariant.withValues(alpha: 0.5);
      iconBg = scheme.surfaceContainerHighest.withValues(alpha: 0.4);
      borderColor = scheme.outlineVariant.withValues(alpha: 0.3);
      cardTint = null;
      shadows = [];
      statusIcon = Icons.cancel_rounded;
    }

    return Opacity(
      opacity: isCancelled ? 0.72 : 1.0,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          tokens.spaceLg,
          0,
          tokens.spaceLg,
          tokens.spaceMd,
        ),
        child: SakaiTactile(
          onTap: () =>
              context.push(Routes.rideDetail.replaceFirst(':rideId', item.id)),
          child: Container(
            padding: EdgeInsets.all(tokens.spaceMd),
            decoration: BoxDecoration(
              color: cardTint != null
                  ? Color.alphaBlend(cardTint, scheme.surface)
                  : scheme.surface,
              borderRadius: BorderRadius.circular(tokens.radiusLg),
              border: Border.all(
                color: borderColor,
                width: isOngoing ? 1.5 : 1.0,
              ),
              boxShadow: shadows,
            ),
            child: Row(
              children: [
                // ── Status icon ───────────────────────────────────────
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: iconBg,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(statusIcon, size: 20, color: iconColor),
                    ),
                    // Pulsing dot for ongoing
                    if (isOngoing) _SmallPulseDot(color: scheme.primary),
                  ],
                ),

                SizedBox(width: tokens.spaceMd),

                // ── Text content ──────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.destinationAddress,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          color: isCancelled
                              ? scheme.onSurface.withValues(alpha: 0.55)
                              : scheme.onSurface,
                          decoration: isCancelled
                              ? TextDecoration.lineThrough
                              : null,
                          decorationColor: scheme.onSurface.withValues(
                            alpha: 0.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Text(
                            _dateLabel(item.createdAt),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant.withValues(
                                alpha: isCancelled ? 0.6 : 1,
                              ),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Text(
                              '·',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: scheme.outlineVariant,
                              ),
                            ),
                          ),
                          // Colored status label
                          Text(
                            item.statusLabel,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isOngoing
                                  ? scheme.primary
                                  : isCompleted
                                  ? semantic.success
                                  : semantic.danger.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(width: tokens.spaceSm),

                // ── Fare + chevron ────────────────────────────────────
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      SakaiCurrency.format(fareValue),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: isCancelled
                            ? scheme.onSurface.withValues(alpha: 0.4)
                            : isCompleted
                            ? semantic.success
                            : scheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: isCancelled
                          ? scheme.outlineVariant
                          : scheme.outline,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Tiny pulsing dot for ongoing ─────────────────────────────────────────────

class _SmallPulseDot extends StatefulWidget {
  const _SmallPulseDot({required this.color});
  final Color color;

  @override
  State<_SmallPulseDot> createState() => _SmallPulseDotState();
}

class _SmallPulseDotState extends State<_SmallPulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) => Container(
        width: 11,
        height: 11,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color,
          // Ring matches the card surface so the dot reads as a cutout,
          // correct in both light and dark surfaces.
          border: Border.all(color: scheme.surface, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: 0.5 * _ctrl.value),
              blurRadius: 6,
              spreadRadius: 2 * _ctrl.value,
            ),
          ],
        ),
      ),
    );
  }
}

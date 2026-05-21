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
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(tokens.radiusLg),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Icon(Icons.history_rounded, color: Theme.of(context).colorScheme.outline, size: 32),
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
    final fareValue = item.fare ?? item.estimatedFare;

    return Padding(
      padding: EdgeInsets.fromLTRB(tokens.spaceLg, 0, tokens.spaceLg, tokens.spaceMd),
      child: SakaiTactile(
        onTap: () => context.push(Routes.rideDetail.replaceFirst(':rideId', item.id)),
        child: Container(
          padding: EdgeInsets.all(tokens.spaceMd),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(tokens.radiusLg),
            border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.history_rounded,
                  size: 20,
                  color: scheme.outline,
                ),
              ),
              SizedBox(width: tokens.spaceMd),
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
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '${_dateLabel(item.createdAt)} · ${item.statusLabel}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: tokens.spaceMd),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₱${fareValue.toStringAsFixed(0)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Icon(Icons.chevron_right_rounded, size: 16, color: scheme.outline),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

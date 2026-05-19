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
              child: SakaiSkeleton.card(height: 64),
            );
          }),
        ),
      );
    }

    if (state.status == RideHistoryStatus.empty || state.items.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.spaceLg,
          vertical: tokens.spaceSm,
        ),
        child: Text(
          'No recent trips yet. Book your first ride above.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final visible = state.items.take(3).toList();
    return Column(
      key: const Key('home_recent_trips_list'),
      children: visible.map((item) => _RecentTripTile(item: item)).toList(),
    );
  }
}

class _RecentTripTile extends StatelessWidget {
  const _RecentTripTile({required this.item});

  final RideHistoryItem item;

  String _dateLabel(DateTime when) {
    final now = DateTime.now();
    final diff = now.difference(when);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${when.month}/${when.day}/${when.year % 100}';
  }

  @override
  Widget build(BuildContext context) {
    final tokens = SakaiDesignTokens.of(context);
    final scheme = Theme.of(context).colorScheme;
    final fareValue = item.fare ?? item.estimatedFare;

    return MergeSemantics(
      child: SakaiListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(tokens.radiusSm),
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.place_outlined,
            size: tokens.iconMd,
            color: scheme.primary,
          ),
        ),
        title: Text(
          item.destinationAddress,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('${_dateLabel(item.createdAt)} · ${item.statusLabel}'),
        trailing: Text(
          '₱${fareValue.toStringAsFixed(0)}',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        onTap: () =>
            context.push(Routes.rideDetail.replaceFirst(':rideId', item.id)),
        dense: true,
      ),
    );
  }
}

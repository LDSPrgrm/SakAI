import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sakai_api_client/sakai_api_client.dart' as api;
import 'package:sakai_shared/sakai_shared.dart';

import '../../../app/router.dart';
import '../view_models/trip_history_notifier.dart';

class TripHistoryListScreen extends ConsumerWidget {
  const TripHistoryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tripHistoryNotifierProvider);
    final notifier = ref.read(tripHistoryNotifierProvider.notifier);
    final t = SakaiDesignTokens.of(context);

    return Scaffold(
      appBar: const SakaiAppBar(title: Text('Trip history')),
      body: RefreshIndicator(
        onRefresh: notifier.load,
        child: _body(context, state, notifier, t),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    TripHistoryState state,
    TripHistoryNotifier notifier,
    SakaiDesignTokens t,
  ) {
    if (state.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.errorMessage != null) {
      return SakaiEmptyState(
        icon: Icons.error_outline,
        title: 'Couldn\'t load history',
        message: state.errorMessage,
        primaryLabel: 'Retry',
        onPrimary: notifier.load,
      );
    }
    if (state.items.isEmpty) {
      return SakaiEmptyState(
        icon: Icons.directions_car_outlined,
        title: 'No trips yet',
        message: 'Once you complete trips they\'ll show up here.',
      );
    }
    return ListView.separated(
      padding: EdgeInsets.all(t.spaceMd),
      itemCount: state.items.length,
      separatorBuilder: (_, _) => SizedBox(height: t.spaceXs),
      itemBuilder: (context, i) => _RideTile(state.items[i]),
    );
  }
}

class _RideTile extends StatelessWidget {
  const _RideTile(this.ride);
  final api.RideResponse ride;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = DateFormat.yMMMd().add_jm().format(ride.updatedAt);
    final fare = ride.actualFare ?? ride.fare ?? ride.estimatedFare;
    return SakaiSurfaceCard(
      onTap: () => context.push(Routes.tripDetail, extra: ride),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dateStr, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  ride.status.name,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (fare != null)
            Text(
              NumberFormat.currency(symbol: '\$').format(fare),
              style: theme.textTheme.titleMedium,
            ),
        ],
      ),
    );
  }
}

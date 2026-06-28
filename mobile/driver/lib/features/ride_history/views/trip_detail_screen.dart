import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sakai_api_client/sakai_api_client.dart' as api;
import 'package:sakai_shared/sakai_shared.dart';

class TripDetailScreen extends StatelessWidget {
  const TripDetailScreen({super.key, required this.ride});
  final api.RideResponse ride;

  @override
  Widget build(BuildContext context) {
    final t = SakaiDesignTokens.of(context);
    final theme = Theme.of(context);
    final fare = ride.actualFare ?? ride.fare ?? ride.estimatedFare;

    return Scaffold(
      appBar: const SakaiAppBar(title: Text('Trip details')),
      body: ListView(
        padding: EdgeInsets.all(t.spaceMd),
        children: [
          SakaiSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Trip', style: theme.textTheme.titleMedium),
                SizedBox(height: t.spaceXs),
                _kv(theme, 'Ride ID', ride.id),
                _kv(theme, 'Status', ride.status.name),
                _kv(
                  theme,
                  'Created',
                  DateFormat.yMMMd().add_jm().format(ride.createdAt),
                ),
                _kv(
                  theme,
                  'Updated',
                  DateFormat.yMMMd().add_jm().format(ride.updatedAt),
                ),
              ],
            ),
          ),
          SizedBox(height: t.spaceMd),
          SakaiSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Route', style: theme.textTheme.titleMedium),
                SizedBox(height: t.spaceXs),
                _kv(theme, 'Pickup', ride.originAddress ?? '—'),
                _kv(theme, 'Drop-off', ride.destinationAddress ?? '—'),
              ],
            ),
          ),
          SizedBox(height: t.spaceMd),
          if (fare != null)
            SakaiSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Fare', style: theme.textTheme.titleMedium),
                  SizedBox(height: t.spaceXs),
                  _kv(
                    theme,
                    'Total',
                    NumberFormat.currency(symbol: '\$').format(fare),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _kv(ThemeData theme, String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              k,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Text(v, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

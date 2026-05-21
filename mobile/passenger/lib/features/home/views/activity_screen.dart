import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../../../app/routes.dart';
import '../../ride_history/models/ride_history_item.dart';
import '../../ride_history/view_models/ride_history_list_view_model.dart';

class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        ref.read(rideHistoryListNotifierProvider.notifier).loadHistory();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rideHistoryListNotifierProvider);
    final tokens = SakaiDesignTokens.of(context);

    return Scaffold(
      appBar: SakaiAppBar(
        title: const Text('Activity'),
        actions: [
          IconButton(
            onPressed: () => context.push(Routes.rideHistory),
            icon: const Icon(Icons.filter_list_rounded),
            tooltip: 'All Activity',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(rideHistoryListNotifierProvider.notifier).refresh(),
        child: _buildBody(context, state, tokens),
      ),
    );
  }

  Widget _buildBody(BuildContext context, RideHistoryListState state, SakaiDesignTokens tokens) {
    if (state.status == RideHistoryStatus.loading && state.items.isEmpty) {
      return ListView.builder(
        padding: EdgeInsets.all(tokens.spaceLg),
        itemCount: 5,
        itemBuilder: (context, index) => Padding(
          padding: EdgeInsets.only(bottom: tokens.spaceMd),
          child: SakaiSkeleton.card(height: 100),
        ),
      );
    }

    if (state.status == RideHistoryStatus.empty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.history_rounded,
                size: 64,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No past activity yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Your completed trips will appear here.',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            SakaiPrimaryButton(
              label: 'Book your first ride',
              onPressed: () {
                // Logic to go back to home tab would be handled by parent state
                // but for now we'll just show info
                SakaiSnackBar.info(context, 'Switch to Home tab to start!');
              },
            ),
          ],
        ),
      );
    }

    if (state.status == RideHistoryStatus.error && state.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(state.error ?? 'Failed to load activity'),
              const SizedBox(height: 16),
              SakaiPrimaryButton(
                label: 'Retry',
                onPressed: () => ref.read(rideHistoryListNotifierProvider.notifier).loadHistory(),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(tokens.spaceLg),
      itemCount: state.items.length + (state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.items.length) {
          if (!state.isLoadingMore) {
            Future.microtask(() => ref.read(rideHistoryListNotifierProvider.notifier).loadMore());
          }
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        final item = state.items[index];
        return _ActivityItemCard(item: item);
      },
    );
  }
}

class _ActivityItemCard extends StatelessWidget {
  const _ActivityItemCard({required this.item});

  final RideHistoryItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tokens = SakaiDesignTokens.of(context);
    final dateStr = DateFormat('MMM dd, yyyy · hh:mm a').format(item.createdAt);
    final amount = item.fare ?? item.estimatedFare;
    final fareStr = '₱${amount.toStringAsFixed(0)}';

    return Padding(
      padding: EdgeInsets.only(bottom: tokens.spaceMd),
      child: SakaiTactile(
        onTap: () => context.push('${Routes.rideHistory}/${item.id}'),
        child: Container(
          padding: const EdgeInsets.all(16),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getStatusColor(item.status, scheme).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getStatusIcon(item.status),
                  color: _getStatusColor(item.status, scheme),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.destinationAddress,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          fareStr,
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateStr,
                      style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getStatusColor(item.status, scheme).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(tokens.radiusFull),
                      ),
                      child: Text(
                        item.statusLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: _getStatusColor(item.status, scheme),
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getStatusIcon(RideStatus status) {
    switch (status) {
      case RideStatus.completed:
        return Icons.check_circle_rounded;
      case RideStatus.cancelled:
        return Icons.cancel_rounded;
      default:
        return Icons.directions_car_rounded;
    }
  }

  Color _getStatusColor(RideStatus status, ColorScheme scheme) {
    switch (status) {
      case RideStatus.completed:
        return Colors.green;
      case RideStatus.cancelled:
        return scheme.error;
      default:
        return scheme.primary;
    }
  }
}

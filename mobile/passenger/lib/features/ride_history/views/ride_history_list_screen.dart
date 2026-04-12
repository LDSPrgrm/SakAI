import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../../../app/routes.dart';
import '../models/ride_history_item.dart';
import '../view_models/ride_history_list_view_model.dart'
    show
        rideHistoryListNotifierProvider,
        RideHistoryListState,
        RideHistoryStatus;

/// Full-screen ride history list with pagination, pull-to-refresh, and filter.
class RideHistoryListScreen extends ConsumerStatefulWidget {
  const RideHistoryListScreen({super.key});

  @override
  ConsumerState<RideHistoryListScreen> createState() =>
      _RideHistoryListScreenState();
}

class _RideHistoryListScreenState extends ConsumerState<RideHistoryListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Load history on first build
    Future.microtask(
      () => ref.read(rideHistoryListNotifierProvider.notifier).loadHistory(),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(rideHistoryListNotifierProvider.notifier).loadMore();
    }
  }

  void _onItemTapped(RideHistoryItem item) {
    context.push(
      Routes.rideDetail.replaceFirst(':rideId', item.id),
      extra: item.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rideHistoryListNotifierProvider);
    final tokens = SakaiDesignTokens.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride History'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter by status',
            onSelected: (value) {
              final filter = value == 'all' ? null : value;
              ref
                  .read(rideHistoryListNotifierProvider.notifier)
                  .setFilter(filter);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All')),
              const PopupMenuItem(value: 'completed', child: Text('Completed')),
              const PopupMenuItem(value: 'cancelled', child: Text('Cancelled')),
            ],
          ),
        ],
      ),
      body: _buildBody(state, tokens, theme),
    );
  }

  Widget _buildBody(
    RideHistoryListState state,
    SakaiDesignTokens tokens,
    ThemeData theme,
  ) {
    switch (state.status) {
      case RideHistoryStatus.initial:
      case RideHistoryStatus.loading:
        return const Center(child: CircularProgressIndicator());

      case RideHistoryStatus.empty:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.directions_car, size: 64, color: Colors.grey[400]),
              SizedBox(height: tokens.spaceMd),
              Text(
                'No rides yet',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: tokens.spaceSm),
              Text(
                'Your ride history will appear here',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        );

      case RideHistoryStatus.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              SizedBox(height: tokens.spaceMd),
              Text(
                state.error ?? 'An error occurred',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              SizedBox(height: tokens.spaceMd),
              ElevatedButton.icon(
                onPressed: () => ref
                    .read(rideHistoryListNotifierProvider.notifier)
                    .loadHistory(),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        );

      case RideHistoryStatus.success:
        return RefreshIndicator(
          onRefresh: () =>
              ref.read(rideHistoryListNotifierProvider.notifier).refresh(),
          child: ListView.builder(
            // PERFORMANCE: ListView.builder lazily creates items,
            // ensuring constant memory usage regardless of total ride count.
            // cacheExtent pre-builds items one viewport beyond the visible area
            // for smooth scrolling at 60fps even with 100+ rides.
            cacheExtent: 500.0,
            controller: _scrollController,
            padding: EdgeInsets.all(tokens.spaceSm),
            itemCount: state.items.length + (state.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == state.items.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return _RideHistoryTile(
                item: state.items[index],
                onTap: () => _onItemTapped(state.items[index]),
              );
            },
          ),
        );
    }
  }
}

class _RideHistoryTile extends StatelessWidget {
  const _RideHistoryTile({required this.item, required this.onTap});

  final RideHistoryItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = SakaiDesignTokens.of(context);
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, yyyy h:mm a');

    return SakaiSurfaceCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        child: Padding(
          padding: EdgeInsets.all(tokens.spaceMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      dateFormat.format(item.createdAt.toLocal()),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  _StatusBadge(status: item.status, label: item.statusLabel),
                ],
              ),
              SizedBox(height: tokens.spaceSm),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.circle, size: 10, color: Colors.green),
                  SizedBox(width: tokens.spaceSm),
                  Expanded(
                    child: Text(
                      item.originAddress,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              SizedBox(height: tokens.spaceXs),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on, size: 10, color: Colors.red),
                  SizedBox(width: tokens.spaceSm),
                  Expanded(
                    child: Text(
                      item.destinationAddress,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              SizedBox(height: tokens.spaceSm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.displayFare,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (item.driverName != null)
                    Text(
                      item.driverName!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.label});

  final RideStatus status;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _badgeColors(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: colors.color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  _BadgeColors _badgeColors(RideStatus status) {
    if (status == RideStatus.completed) {
      return _BadgeColors(Colors.green[700]!, Colors.green[50]);
    }
    if (status == RideStatus.cancelled) {
      return _BadgeColors(Colors.red[700]!, Colors.red[50]);
    }
    // requested, accepted, arrived, inProgress
    return _BadgeColors(Colors.blue[700]!, Colors.blue[50]);
  }
}

class _BadgeColors {
  _BadgeColors(this.color, this.bg);
  final Color color;
  final Color? bg;
}

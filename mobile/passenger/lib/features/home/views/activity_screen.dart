import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../../../app/routes.dart';
import '../../ride_history/models/ride_history_item.dart';
import '../../ride_history/view_models/ride_history_list_view_model.dart';

class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key, this.isStandalone = false});

  final bool isStandalone;

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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: SakaiAppBar(
        backgroundColor: Colors.transparent,
        title: widget.isStandalone
            ? Text(
                'Activity',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              )
            : null,
        showBack: widget.isStandalone,
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: SakaiAnimatedBackdrop()),
          RefreshIndicator(
            onRefresh: () =>
                ref.read(rideHistoryListNotifierProvider.notifier).refresh(),
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(context, state, tokens),
                  _buildFilterBar(context, state, tokens, theme),
                  Expanded(
                    child: _buildBody(context, state, tokens),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    RideHistoryListState state,
    SakaiDesignTokens tokens,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final totalRides = state.items.length;

    return Padding(
      padding: EdgeInsets.fromLTRB(tokens.spaceLg, tokens.spaceMd, tokens.spaceLg, tokens.spaceMd),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ride History',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${state.activeFilter == null ? 'All' : state.activeFilter!.toUpperCase()} • $totalRides rides',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.history_rounded, color: scheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(
    BuildContext context,
    RideHistoryListState state,
    SakaiDesignTokens tokens,
    ThemeData theme,
  ) {
    final filters = [
      {'label': 'All', 'value': null},
      {'label': 'Ongoing', 'value': 'ongoing'},
      {'label': 'Completed', 'value': 'completed'},
      {'label': 'Cancelled', 'value': 'cancelled'},
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: tokens.spaceLg),
        itemCount: filters.length,
        separatorBuilder: (_, __) => SizedBox(width: tokens.spaceSm),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = state.activeFilter == filter['value'];
          return _FilterPill(
            label: filter['label'] as String,
            isSelected: isSelected,
            onTap: () {
              ref
                  .read(rideHistoryListNotifierProvider.notifier)
                  .setFilter(filter['value'] as String?);
            },
          );
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    RideHistoryListState state,
    SakaiDesignTokens tokens,
  ) {
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
      final scheme = Theme.of(context).colorScheme;
      return Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.history_rounded,
                  size: 64,
                  color: scheme.outline,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No past activity yet',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your completed trips will appear here.',
                style: TextStyle(color: scheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SakaiPrimaryButton(
                label: 'Book your first ride',
                onPressed: () {
                  SakaiSnackBar.info(context, 'Switch to Book tab to start!');
                },
              ),
            ],
          ),
        ),
      );
    }

    if (state.status == RideHistoryStatus.error && state.items.isEmpty) {
      final scheme = Theme.of(context).colorScheme;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                state.error ?? 'Failed to load activity',
                style: TextStyle(color: scheme.onSurface),
              ),
              const SizedBox(height: 16),
              SakaiPrimaryButton(
                label: 'Retry',
                onPressed: () => ref
                    .read(rideHistoryListNotifierProvider.notifier)
                    .loadHistory(),
              ),
            ],
          ),
        ),
      );
    }

    final Map<String, List<RideHistoryItem>> groupedItems = {};
    for (final item in state.items) {
      final date = DateFormat.yMMMd().format(item.createdAt.toLocal());
      groupedItems.putIfAbsent(date, () => []).add(item);
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spaceLg,
        vertical: tokens.spaceMd,
      ),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: groupedItems.keys.length + (state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == groupedItems.keys.length) {
          if (!state.isLoadingMore) {
            Future.microtask(
              () =>
                  ref.read(rideHistoryListNotifierProvider.notifier).loadMore(),
            );
          }
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        final date = groupedItems.keys.elementAt(index);
        final items = groupedItems[date]!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: tokens.spaceMd, bottom: tokens.spaceSm),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(tokens.radiusSm),
                ),
                child: Text(
                  date.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            ...items.map((item) => _ActivityItemCard(item: item)),
          ],
        );
      },
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tokens = SakaiDesignTokens.of(context);

    return SakaiTactile(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.spaceMd,
          vertical: tokens.spaceXs,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? scheme.primary
              : scheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(tokens.radiusFull),
          border: isSelected
              ? null
              : Border.all(
                  color: scheme.outlineVariant.withValues(alpha: 0.2),
                ),
        ),
        child: Center(
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: isSelected ? scheme.onPrimary : scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
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
    final semantic = SakaiSemanticColors.of(context);
    final dateFormat = DateFormat('h:mm a');

    final isCompleted = item.status == RideStatus.completed;
    final isCancelled = item.status == RideStatus.cancelled;
    final isOngoing = !isCompleted && !isCancelled;

    final double cardOpacity = isCancelled ? 0.72 : 1.0;
    final double borderWidth = isOngoing ? 1.6 : (isCancelled ? 0.8 : 1.0);
    final Color borderColor = isOngoing
        ? scheme.primary.withValues(alpha: 0.75)
        : (isCancelled
              ? scheme.outlineVariant.withValues(alpha: 0.18)
              : scheme.outlineVariant.withValues(alpha: 0.35));

    final List<Color> cardGradient = isOngoing
        ? [
            scheme.primaryContainer.withValues(alpha: 0.15),
            scheme.surface.withValues(alpha: 0.8),
          ]
        : (isCancelled
              ? [
                  scheme.surface.withValues(alpha: 0.5),
                  scheme.surface.withValues(alpha: 0.4),
                ]
              : [
                  scheme.surface.withValues(alpha: 0.9),
                  scheme.surface.withValues(alpha: 0.7),
                ]);

    final List<BoxShadow> cardShadow = isOngoing
        ? [
            BoxShadow(
              color: scheme.primary.withValues(alpha: 0.12),
              blurRadius: 14,
              spreadRadius: 1.5,
              offset: const Offset(0, 4),
            ),
          ]
        : (isCancelled
              ? const []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]);

    final Color timelineConnectorColor = isOngoing
        ? scheme.primary.withValues(alpha: 0.8)
        : (isCancelled
              ? theme.dividerColor.withValues(alpha: 0.15)
              : theme.dividerColor.withValues(alpha: 0.3));
    final double timelineConnectorWidth = isOngoing ? 2.2 : 1.5;

    final Color destinationPinColor = isCancelled
        ? semantic.neutral.withValues(alpha: 0.5)
        : semantic.danger;

    final Color fareBgColor = isOngoing
        ? scheme.primaryContainer.withValues(alpha: 0.12)
        : (isCancelled
              ? scheme.errorContainer.withValues(alpha: 0.08)
              : semantic.success.withValues(alpha: 0.12));
    final Color fareTextColor = isOngoing
        ? scheme.primary
        : (isCancelled
              ? scheme.error.withValues(alpha: 0.7)
              : semantic.success);
    final String fareText = isOngoing
        ? '${item.displayFare} (Est.)'
        : item.displayFare;

    return Padding(
      padding: EdgeInsets.only(bottom: tokens.spaceMd),
      child: Opacity(
        opacity: cardOpacity,
        child: SakaiTactile(
          onTap: () => context.push('${Routes.rideHistory}/${item.id}'),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(tokens.radiusLg),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                padding: EdgeInsets.all(tokens.spaceMd),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: cardGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(tokens.radiusLg),
                  border: Border.all(color: borderColor, width: borderWidth),
                  boxShadow: cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 16,
                              color: scheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              dateFormat.format(item.createdAt.toLocal()),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SakaiStatusBadge(
                          status: _statusFor(item.status),
                          label: item.statusLabel,
                          dense: true,
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Divider(
                        height: 1,
                        thickness: 0.8,
                        color: scheme.outlineVariant.withValues(
                          alpha: isCancelled ? 0.15 : 0.3,
                        ),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            const SizedBox(height: 6),
                            Icon(
                              Icons.circle,
                              size: 8,
                              color: isCancelled
                                  ? semantic.success.withValues(alpha: 0.5)
                                  : semantic.success,
                            ),
                            Container(
                              width: timelineConnectorWidth,
                              height: 28,
                              color: timelineConnectorColor,
                            ),
                            Icon(
                              Icons.location_on_rounded,
                              size: 12,
                              color: destinationPinColor,
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.originAddress,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: scheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                item.destinationAddress,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: scheme.onSurface,
                                  decoration: isCancelled
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Divider(
                        height: 1,
                        thickness: 0.8,
                        color: scheme.outlineVariant.withValues(
                          alpha: isCancelled ? 0.15 : 0.3,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: fareBgColor,
                            borderRadius: BorderRadius.circular(
                              tokens.radiusSm,
                            ),
                          ),
                          child: Text(
                            fareText,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: fareTextColor,
                            ),
                          ),
                        ),
                        if (item.driverName != null)
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: scheme.surfaceContainerHighest
                                      .withValues(
                                        alpha: 0.5,
                                      ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.person_rounded,
                                  size: 12,
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                item.driverName!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  SakaiStatus _statusFor(RideStatus s) {
    if (s == RideStatus.completed) return SakaiStatus.success;
    if (s == RideStatus.cancelled) return SakaiStatus.danger;
    return SakaiStatus.info;
  }
}

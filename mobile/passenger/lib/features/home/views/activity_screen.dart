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
  const ActivityScreen({
    super.key,
    this.isStandalone = false,
  });

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
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent, // Immersive glass
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              onPressed: () => _showFilterBottomSheet(context, state, tokens, theme),
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    Icons.filter_list_rounded,
                    color: state.activeFilter != null ? scheme.primary : scheme.onSurface,
                  ),
                  if (state.activeFilter != null)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.scaffoldBackgroundColor,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              tooltip: 'Filter Activity',
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Dynamic organic blobs backdrop matching the overall premium app theme
          const Positioned.fill(
            child: SakaiAnimatedBackdrop(),
          ),
          RefreshIndicator(
            onRefresh: () => ref.read(rideHistoryListNotifierProvider.notifier).refresh(),
            child: SafeArea(
              child: _buildBody(context, state, tokens),
            ),
          ),
        ],
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
              const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                state.error ?? 'Failed to load activity',
                style: TextStyle(color: scheme.onSurface),
              ),
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
      padding: EdgeInsets.symmetric(horizontal: tokens.spaceLg, vertical: tokens.spaceMd),
      physics: const AlwaysScrollableScrollPhysics(),
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

  void _showFilterBottomSheet(
    BuildContext context,
    RideHistoryListState state,
    SakaiDesignTokens tokens,
    ThemeData theme,
  ) {
    final scheme = theme.colorScheme;
    final semantic = SakaiSemanticColors.of(context);

    // Count per category from current loaded items
    final allCount = state.items.length;
    final completedCount = state.items.where((i) => i.status == RideStatus.completed).length;
    final cancelledCount = state.items.where((i) => i.status == RideStatus.cancelled).length;
    final ongoingCount = state.items.where((i) => i.status != RideStatus.completed && i.status != RideStatus.cancelled).length;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: scheme.surface.withValues(alpha: 0.92),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(
                  color: scheme.outlineVariant.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Drag handle
                      Center(
                        child: Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: scheme.onSurfaceVariant.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: scheme.primaryContainer.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.tune_rounded, size: 18, color: scheme.primary),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Filter Rides',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              Text(
                                'Showing $allCount rides total',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Filter tiles grid (2 columns)
                      GridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 2.2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _FilterTile(
                            label: 'All Rides',
                            subtitle: '$allCount rides',
                            icon: Icons.history_rounded,
                            iconColor: scheme.primary,
                            iconBg: scheme.primaryContainer.withValues(alpha: 0.6),
                            isSelected: state.activeFilter == null,
                            onTap: () {
                              ref.read(rideHistoryListNotifierProvider.notifier).setFilter(null);
                              Navigator.pop(ctx);
                            },
                            scheme: scheme,
                            theme: theme,
                            tokens: tokens,
                          ),
                          _FilterTile(
                            label: 'Ongoing',
                            subtitle: '$ongoingCount active',
                            icon: Icons.directions_car_rounded,
                            iconColor: scheme.primary,
                            iconBg: scheme.primaryContainer.withValues(alpha: 0.5),
                            isSelected: state.activeFilter == 'ongoing',
                            onTap: () {
                              ref.read(rideHistoryListNotifierProvider.notifier).setFilter('ongoing');
                              Navigator.pop(ctx);
                            },
                            scheme: scheme,
                            theme: theme,
                            tokens: tokens,
                          ),
                          _FilterTile(
                            label: 'Completed',
                            subtitle: '$completedCount rides',
                            icon: Icons.check_circle_rounded,
                            iconColor: semantic.success,
                            iconBg: semantic.successSubtle,
                            isSelected: state.activeFilter == 'completed',
                            onTap: () {
                              ref.read(rideHistoryListNotifierProvider.notifier).setFilter('completed');
                              Navigator.pop(ctx);
                            },
                            scheme: scheme,
                            theme: theme,
                            tokens: tokens,
                          ),
                          _FilterTile(
                            label: 'Cancelled',
                            subtitle: '$cancelledCount rides',
                            icon: Icons.cancel_rounded,
                            iconColor: semantic.danger,
                            iconBg: semantic.dangerSubtle,
                            isSelected: state.activeFilter == 'cancelled',
                            onTap: () {
                              ref.read(rideHistoryListNotifierProvider.notifier).setFilter('cancelled');
                              Navigator.pop(ctx);
                            },
                            scheme: scheme,
                            theme: theme,
                            tokens: tokens,
                          ),
                        ],
                      ),

                      if (state.activeFilter != null) ...[
                        const SizedBox(height: 16),
                        SakaiTactile(
                          onTap: () {
                            ref.read(rideHistoryListNotifierProvider.notifier).setFilter(null);
                            Navigator.pop(ctx);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: scheme.errorContainer.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(tokens.radiusMd),
                              border: Border.all(
                                color: scheme.error.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.filter_list_off_rounded, size: 16, color: scheme.error),
                                const SizedBox(width: 8),
                                Text(
                                  'Clear Filter',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: scheme.error,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
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
    final semantic = SakaiSemanticColors.of(context);
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');

    final isCompleted = item.status == RideStatus.completed;
    final isCancelled = item.status == RideStatus.cancelled;
    final isOngoing = !isCompleted && !isCancelled;

    // Define distinguishable styling variables
    final double cardOpacity = isCancelled ? 0.72 : 1.0;
    
    // Card decoration
    final double borderWidth = isOngoing ? 1.6 : (isCancelled ? 0.8 : 1.0);
    final Color borderColor = isOngoing 
        ? scheme.primary.withValues(alpha: 0.75) 
        : (isCancelled ? scheme.outlineVariant.withValues(alpha: 0.18) : scheme.outlineVariant.withValues(alpha: 0.35));
    
    final Color cardBgColor = isOngoing
        ? scheme.primaryContainer.withValues(alpha: 0.08)
        : (isCancelled ? scheme.surface.withValues(alpha: 0.45) : scheme.surface.withValues(alpha: 0.65));

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

    // Timeline stepper colors
    final Color timelineConnectorColor = isOngoing
        ? scheme.primary.withValues(alpha: 0.8)
        : (isCancelled ? theme.dividerColor.withValues(alpha: 0.15) : theme.dividerColor.withValues(alpha: 0.3));
    final double timelineConnectorWidth = isOngoing ? 2.2 : 1.5;
    
    final Color destinationPinColor = isCancelled
        ? semantic.neutral.withValues(alpha: 0.5) // destination never reached!
        : semantic.danger;

    // Fare styling
    final Color fareBgColor = isOngoing
        ? scheme.primaryContainer.withValues(alpha: 0.12)
        : (isCancelled ? scheme.errorContainer.withValues(alpha: 0.08) : semantic.success.withValues(alpha: 0.12));
    final Color fareTextColor = isOngoing
        ? scheme.primary
        : (isCancelled ? scheme.error.withValues(alpha: 0.7) : semantic.success);
    final String fareText = isOngoing ? '${item.displayFare} (Est.)' : item.displayFare;

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
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(tokens.radiusLg),
                  border: Border.all(
                    color: borderColor,
                    width: borderWidth,
                  ),
                  boxShadow: cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date & Status Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.directions_car_rounded,
                              size: 16,
                              color: isOngoing 
                                  ? scheme.primary 
                                  : (isCancelled ? scheme.onSurfaceVariant.withValues(alpha: 0.5) : scheme.primary.withValues(alpha: 0.7)),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              dateFormat.format(item.createdAt.toLocal()),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isCancelled ? scheme.onSurfaceVariant.withValues(alpha: 0.6) : scheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isOngoing) ...[
                              _PulsingLiveDot(color: scheme.primary),
                              const SizedBox(width: 8),
                            ],
                            SakaiStatusBadge(
                              status: _statusFor(item.status),
                              label: item.statusLabel,
                              dense: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Divider(
                        height: 1,
                        thickness: 0.8,
                        color: scheme.outlineVariant.withValues(alpha: isCancelled ? 0.15 : 0.3),
                      ),
                    ),
                    
                    // Origin/Destination Connected Timeline
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
                                  color: isCancelled ? scheme.onSurface.withValues(alpha: 0.6) : scheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                item.destinationAddress,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isCancelled ? scheme.onSurface.withValues(alpha: 0.5) : scheme.onSurface,
                                  decoration: isCancelled ? TextDecoration.lineThrough : null,
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
                        color: scheme.outlineVariant.withValues(alpha: isCancelled ? 0.15 : 0.3),
                      ),
                    ),

                    // Fare & Driver Footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: fareBgColor,
                            borderRadius: BorderRadius.circular(tokens.radiusSm),
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
                                  color: scheme.surfaceContainerHighest.withValues(alpha: isCancelled ? 0.25 : 0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.person_rounded,
                                  size: 12,
                                  color: isCancelled ? scheme.onSurfaceVariant.withValues(alpha: 0.5) : scheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                item.driverName!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: isCancelled ? scheme.onSurfaceVariant.withValues(alpha: 0.6) : scheme.onSurfaceVariant,
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

class _PulsingLiveDot extends StatefulWidget {
  const _PulsingLiveDot({required this.color});
  final Color color;

  @override
  State<_PulsingLiveDot> createState() => _PulsingLiveDotState();
}

class _PulsingLiveDotState extends State<_PulsingLiveDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withValues(alpha: 0.4 + (_controller.value * 0.6)),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.4 * _controller.value),
                blurRadius: 6,
                spreadRadius: 3 * _controller.value,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Filter Tile (2-column grid inside bottom sheet) ──────────────────────────

class _FilterTile extends StatelessWidget {
  const _FilterTile({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.isSelected,
    required this.onTap,
    required this.scheme,
    required this.theme,
    required this.tokens,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final bool isSelected;
  final VoidCallback onTap;
  final ColorScheme scheme;
  final ThemeData theme;
  final SakaiDesignTokens tokens;

  @override
  Widget build(BuildContext context) {
    return SakaiTactile(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? iconColor.withValues(alpha: 0.08)
              : scheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          border: Border.all(
            color: isSelected ? iconColor.withValues(alpha: 0.6) : scheme.outlineVariant.withValues(alpha: 0.3),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: iconColor.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected ? iconColor.withValues(alpha: 0.15) : iconBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: iconColor),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? iconColor : scheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isSelected ? iconColor.withValues(alpha: 0.75) : scheme.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, size: 14, color: iconColor),
          ],
        ),
      ),
    );
  }
}


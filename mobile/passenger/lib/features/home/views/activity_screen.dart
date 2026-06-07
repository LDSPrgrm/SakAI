import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../../../app/routes.dart';
import '../../ride_history/models/ride_history_item.dart';
import '../../ride_history/view_models/ride_history_list_view_model.dart';

// ─── Status ───────────────────────────────────────────────────────────────────

enum _RideStatus { ongoing, completed, cancelled }

_RideStatus _statusOf(RideHistoryItem item) {
  if (item.isCompleted) return _RideStatus.completed;
  if (item.isCancelled) return _RideStatus.cancelled;
  return _RideStatus.ongoing;
}

extension _StatusX on _RideStatus {
  Color accent(SakaiSemanticColors sem) => switch (this) {
        _RideStatus.ongoing   => sem.success,
        _RideStatus.completed => sem.accentBlue,
        _RideStatus.cancelled => sem.danger,
      };

  Color tint(SakaiSemanticColors sem) => switch (this) {
        _RideStatus.ongoing   => sem.successSubtle,
        _RideStatus.completed => sem.accentBlue.withValues(alpha: 0.12),
        _RideStatus.cancelled => sem.dangerSubtle,
      };

  IconData get icon => switch (this) {
        _RideStatus.ongoing   => Icons.radio_button_checked_rounded,
        _RideStatus.completed => Icons.check_circle_rounded,
        _RideStatus.cancelled => Icons.cancel_rounded,
      };

  String get label => switch (this) {
        _RideStatus.ongoing   => 'In Progress',
        _RideStatus.completed => 'Completed',
        _RideStatus.cancelled => 'Cancelled',
      };
}

// ─── Screen ───────────────────────────────────────────────────────────────────

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
    final t = SakaiDesignTokens.of(context);

    return Scaffold(
      appBar: SakaiAppBar(
        title: const Text('Activity'),
        showBack: widget.isStandalone,
        bottom: _SegmentedFilterControl(
          activeFilter: state.activeFilter,
          onSelect: (v) => ref
              .read(rideHistoryListNotifierProvider.notifier)
              .setFilter(v),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(rideHistoryListNotifierProvider.notifier).refresh(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: SizedBox(height: t.spaceMd)),

            if (state.status == RideHistoryStatus.loading &&
                state.items.isEmpty)
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: t.spaceMd),
                sliver: SliverList.builder(
                  itemCount: 4,
                  itemBuilder: (_, __) => Padding(
                    padding: EdgeInsets.only(bottom: t.spaceSm),
                    child: SakaiSkeleton.card(height: 130),
                  ),
                ),
              )
            else if (state.status == RideHistoryStatus.error &&
                state.items.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: SakaiEmptyState(
                  icon: Icons.cloud_off_rounded,
                  title: 'Could not load activity',
                  message: state.error ?? 'Something went wrong.',
                  primaryLabel: 'Retry',
                  onPrimary: () => ref
                      .read(rideHistoryListNotifierProvider.notifier)
                      .loadHistory(),
                ),
              )
            else if (state.status == RideHistoryStatus.empty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: SakaiEmptyState(
                  icon: Icons.directions_car_filled_rounded,
                  title: 'No trips yet',
                  message:
                      'Your ride history will appear here once you complete a trip.',
                  primaryLabel: 'Book your first ride',
                  onPrimary: () =>
                      SakaiSnackBar.info(context, 'Switch to Book tab!'),
                ),
              )
            else
              _ActivityList(state: state),

            SliverToBoxAdapter(child: SizedBox(height: 80 + t.spaceLg)),
          ],
        ),
      ),
    );
  }
}

// ─── Segmented Filter Control ──────────────────────────────────────────────────

class _SegmentedFilterControl extends StatelessWidget implements PreferredSizeWidget {
  const _SegmentedFilterControl({
    required this.activeFilter,
    required this.onSelect,
  });

  final String? activeFilter;
  final ValueChanged<String?> onSelect;

  static const _filters = [
    (label: 'All', value: null),
    (label: 'Active', value: 'ongoing'),
    (label: 'Completed', value: 'completed'),
    (label: 'Cancelled', value: 'cancelled'),
  ];

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final t = SakaiDesignTokens.of(context);

    final selectedIndex = _filters.indexWhere((f) => f.value == activeFilter);
    final index = selectedIndex == -1 ? 0 : selectedIndex;

    // Calculate alignment x coordinate from -1.0 to 1.0
    final double alignX = -1.0 + (index * 2.0 / (_filters.length - 1));

    return Container(
      width: double.infinity,
      height: 56,
      color: scheme.surface,
      padding: EdgeInsets.symmetric(horizontal: t.spaceMd, vertical: t.spaceSm),
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(t.radiusFull),
        ),
        padding: const EdgeInsets.all(4),
        child: Stack(
          children: [
            // Sliding thumb background indicator
            AnimatedAlign(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOutCubic,
              alignment: Alignment(alignX, 0.0),
              child: FractionallySizedBox(
                widthFactor: 1 / _filters.length,
                child: Container(
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: BorderRadius.circular(t.radiusFull),
                    boxShadow: [
                      BoxShadow(
                        color: scheme.primary.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Segment labels
            Row(
              children: List.generate(_filters.length, (i) {
                final f = _filters[i];
                final isSelected = i == index;
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onSelect(f.value),
                    child: Center(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          color: isSelected ? scheme.onPrimary : scheme.onSurfaceVariant,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                          fontSize: 13,
                        ),
                        child: Text(f.label),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── List ─────────────────────────────────────────────────────────────────────

class _ActivityList extends ConsumerWidget {
  const _ActivityList({required this.state});
  final RideHistoryListState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = SakaiDesignTokens.of(context);

    // Group by date label
    final Map<String, List<RideHistoryItem>> grouped = {};
    for (final item in state.items) {
      final key = _dateLabel(item.createdAt.toLocal());
      grouped.putIfAbsent(key, () => []).add(item);
    }

    final sections = grouped.entries.toList();

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: t.spaceMd),
      sliver: SliverList.builder(
        itemCount: sections.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, i) {
          if (i == sections.length) {
            if (!state.isLoadingMore) {
              Future.microtask(
                () => ref
                    .read(rideHistoryListNotifierProvider.notifier)
                    .loadMore(),
              );
            }
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          final entry = sections[i];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DateLabel(label: entry.key),
              ...entry.value.map(
                (item) => _RideCard(item: item),
              ),
            ],
          );
        },
      ),
    );
  }

  static String _dateLabel(DateTime dt) {
    final today = DateTime.now();
    final d     = DateTime(dt.year, dt.month, dt.day);
    final now   = DateTime(today.year, today.month, today.day);
    if (d == now) return 'Today';
    if (d == now.subtract(const Duration(days: 1))) return 'Yesterday';
    if (now.difference(d).inDays < 7) {
      return DateFormat('EEEE').format(dt); // "Monday"
    }
    return DateFormat('MMM d').format(dt);  // "Jun 3"
  }
}

// ─── Date label ───────────────────────────────────────────────────────────────

class _DateLabel extends StatelessWidget {
  const _DateLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final t      = SakaiDesignTokens.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: t.spaceMd),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(t.radiusFull),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.4),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Ride card ────────────────────────────────────────────────────────────────

class _RideCard extends StatelessWidget {
  const _RideCard({required this.item});
  final RideHistoryItem item;

  static IconData _payIcon(String m) {
    final s = m.toLowerCase();
    if (s.contains('cash'))  return Icons.payments_rounded;
    if (s.contains('card'))  return Icons.credit_card_rounded;
    if (s.contains('gcash')) return Icons.account_balance_wallet_rounded;
    return Icons.paid_rounded;
  }

  static String _payLabel(String m) {
    final s = m.toLowerCase();
    if (s.contains('cash'))  return 'Cash';
    if (s.contains('card'))  return 'Card';
    if (s.contains('gcash')) return 'GCash';
    return m;
  }

  @override
  Widget build(BuildContext context) {
    final theme       = Theme.of(context);
    final scheme      = theme.colorScheme;
    final sem         = SakaiSemanticColors.of(context);
    final t           = SakaiDesignTokens.of(context);
    final status      = _statusOf(item);
    final accent      = status.accent(sem);
    final isOngoing   = status == _RideStatus.ongoing;
    final isCancelled = status == _RideStatus.cancelled;

    return Padding(
      padding: EdgeInsets.only(bottom: t.spaceSm),
      child: SakaiSurfaceCard(
        padding: EdgeInsets.zero,
        onTap: () => context.push('${Routes.rideHistory}/${item.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Accent Line
            Container(
              height: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accent, accent.withValues(alpha: 0.3)],
                ),
              ),
            ),

            // Header Row (Status & Time)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: t.spaceMd, vertical: t.spaceSm),
              child: Row(
                children: [
                  if (isOngoing)
                    _PulseDot(color: accent)
                  else
                    Icon(status.icon, size: 14, color: accent),
                  const SizedBox(width: 8),
                  Text(
                    status.label.toUpperCase(),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  // Time Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(t.radiusFull),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time_filled_rounded,
                          size: 12,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('h:mm a').format(item.createdAt.toLocal()),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 1),

            // Route details & Fare details
            Padding(
              padding: EdgeInsets.all(t.spaceMd),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _RouteTimeline(
                      item: item,
                      accent: accent,
                      isCancelled: isCancelled,
                      scheme: scheme,
                      theme: theme,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Fare Display
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        isOngoing ? 'EST. FARE' : 'FINAL FARE',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.displayFare,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: isCancelled
                              ? scheme.onSurfaceVariant.withValues(alpha: 0.5)
                              : scheme.onSurface,
                          decoration: isCancelled ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 1),

            // Footer: Chips and chevron
            Padding(
              padding: EdgeInsets.symmetric(horizontal: t.spaceMd, vertical: t.spaceSm),
              child: Row(
                children: [
                  if (item.driverName != null) ...[
                    _Chip(
                      icon: Icons.person_rounded,
                      label: item.driverName!,
                      scheme: scheme,
                      t: t,
                    ),
                    const SizedBox(width: 8),
                  ],
                  _Chip(
                    icon: _payIcon(item.paymentMethod),
                    label: _payLabel(item.paymentMethod),
                    scheme: scheme,
                    t: t,
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Route timeline ───────────────────────────────────────────────────────────

class _RouteTimeline extends StatelessWidget {
  const _RouteTimeline({
    required this.item,
    required this.accent,
    required this.isCancelled,
    required this.scheme,
    required this.theme,
  });

  final RideHistoryItem item;
  final Color accent;
  final bool isCancelled;
  final ColorScheme scheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dots and connecting vertical line
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Column(
            children: [
              // Pickup dot: Green outer circle with inner white core
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF00C853),
                ),
              ),
              // Connecting line
              Container(
                width: 1.5,
                height: 28,
                color: scheme.outlineVariant.withValues(alpha: 0.6),
              ),
              // Dropoff dot: Status color
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Addresses
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AddressRow(
                label: 'PICKUP',
                address: item.originAddress,
                muted: false,
                cancelled: false,
                scheme: scheme,
                theme: theme,
              ),
              const SizedBox(height: 14),
              _AddressRow(
                label: 'DROP-OFF',
                address: item.destinationAddress,
                muted: false,
                cancelled: isCancelled,
                scheme: scheme,
                theme: theme,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Address row ──────────────────────────────────────────────────────────────

class _AddressRow extends StatelessWidget {
  const _AddressRow({
    required this.label,
    required this.address,
    required this.muted,
    required this.cancelled,
    required this.scheme,
    required this.theme,
  });

  final String label;
  final String address;
  final bool muted;
  final bool cancelled;
  final ColorScheme scheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          address,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            height: 1.2,
            color: muted ? scheme.onSurfaceVariant : scheme.onSurface,
            decoration: cancelled ? TextDecoration.lineThrough : null,
          ),
        ),
      ],
    );
  }
}

// ─── Footer chip ──────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  const _Chip({
    required this.icon,
    required this.label,
    required this.scheme,
    required this.t,
  });

  final IconData icon;
  final String label;
  final ColorScheme scheme;
  final SakaiDesignTokens t;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(t.radiusFull),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.25),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: scheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Pulsing dot ──────────────────────────────────────────────────────────────

class _PulseDot extends StatefulWidget {
  const _PulseDot({required this.color});
  final Color color;

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _scale, _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _scale   = Tween(begin: 0.75, end: 1.25).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _opacity = Tween(begin: 0.55, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => Transform.scale(
          scale: _scale.value,
          child: Opacity(
            opacity: _opacity.value,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: widget.color, shape: BoxShape.circle,
                boxShadow: [BoxShadow(
                  color: widget.color.withValues(alpha: 0.55),
                  blurRadius: 5, spreadRadius: 1,
                )],
              ),
            ),
          ),
        ),
      );
}

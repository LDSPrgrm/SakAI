import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../../../../app/routes.dart';

class HomeQuickActionsGrid extends StatelessWidget {
  const HomeQuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = SakaiDesignTokens.of(context);
    final actions = <_QuickAction>[
      _QuickAction(
        key: const Key('home_qa_saved_places'),
        icon: Icons.bookmark_rounded,
        label: 'Saved Places',
        onTap: () => context.push(Routes.savedPlaces),
      ),
      _QuickAction(
        key: const Key('home_qa_schedule_ride'),
        icon: Icons.calendar_today_rounded,
        label: 'Schedule Ride',
        onTap: () => context.push(Routes.comingSoon, extra: 'Schedule Ride'),
      ),
      _QuickAction(
        key: const Key('home_qa_promotions'),
        icon: Icons.auto_awesome_rounded,
        label: 'Promotions',
        onTap: () => context.push(Routes.promotions),
      ),
      _QuickAction(
        key: const Key('home_qa_ride_history'),
        icon: Icons.history_rounded,
        label: 'Ride History',
        onTap: () => context.push(Routes.rideHistory),
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: tokens.spaceLg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: actions.map((a) => Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: tokens.spaceXs),
            child: _QuickActionTile(a),
          ),
        )).toList(),
      ),
    );
  }
}

class _QuickAction {
  const _QuickAction({
    required this.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final Key key;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile(this.action);

  final _QuickAction action;

  @override
  Widget build(BuildContext context) {
    final tokens = SakaiDesignTokens.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Semantics(
      button: true,
      label: action.label,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SakaiTactile(
            key: action.key,
            onTap: action.onTap,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(tokens.radiusLg),
                border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  action.icon,
                  size: 24,
                  color: scheme.primary,
                ),
              ),
            ),
          ),
          SizedBox(height: tokens.spaceSm),
          Text(
            action.label,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

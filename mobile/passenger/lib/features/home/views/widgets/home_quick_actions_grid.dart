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
        icon: Icons.bookmark_outline,
        label: 'Saved Places',
        onTap: () => context.push(Routes.savedPlaces),
      ),
      _QuickAction(
        key: const Key('home_qa_schedule_ride'),
        icon: Icons.schedule,
        label: 'Schedule Ride',
        onTap: () => context.push(Routes.comingSoon, extra: 'Schedule Ride'),
      ),
      _QuickAction(
        key: const Key('home_qa_promotions'),
        icon: Icons.local_offer_outlined,
        label: 'Promotions',
        onTap: () => context.push(Routes.promotions),
      ),
      _QuickAction(
        key: const Key('home_qa_ride_history'),
        icon: Icons.history,
        label: 'Ride History',
        onTap: () => context.push(Routes.rideHistory),
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: tokens.spaceLg),
      child: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: tokens.spaceMd,
        crossAxisSpacing: tokens.spaceMd,
        childAspectRatio: 2.0,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: actions.map(_QuickActionTile.new).toList(),
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
      child: SakaiTactile(
        key: action.key,
        onTap: action.onTap,
        child: Container(
          constraints: BoxConstraints(minHeight: tokens.touchTargetMin * 2),
          padding: EdgeInsets.all(tokens.spaceMd),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(tokens.radiusMd),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(tokens.radiusSm),
                ),
                alignment: Alignment.center,
                child: Icon(
                  action.icon,
                  size: tokens.iconMd,
                  color: scheme.onPrimaryContainer,
                ),
              ),
              SizedBox(width: tokens.spaceMd),
              Expanded(
                child: Text(
                  action.label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

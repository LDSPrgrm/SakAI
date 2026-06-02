import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../../../../app/routes.dart';

/// Callback invoked when the user taps a service that triggers ride booking
/// (i.e. the "Transport" tile).
typedef OnTransportTap = void Function();

/// 8-item Grab-style services grid rendered in 2 rows of 4.
class HomeServicesGrid extends StatelessWidget {
  const HomeServicesGrid({super.key, required this.onTransportTap});

  final OnTransportTap onTransportTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final items = _buildItems(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.sublist(0, 4).map(_ServiceTile.new).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.sublist(4).map(_ServiceTile.new).toList(),
          ),
        ],
      ),
    );
  }

  List<_ServiceItem> _buildItems(BuildContext context) => [
        _ServiceItem(
          icon: Icons.fastfood_rounded,
          label: 'Food',
          color: const Color(0xFFFF6B35),
          onTap: () {
            HapticFeedback.lightImpact();
            context.push(Routes.comingSoon, extra: 'Food');
          },
        ),
        _ServiceItem(
          icon: Icons.shopping_cart_rounded,
          label: 'Mart',
          color: const Color(0xFF0284C7),
          onTap: () {
            HapticFeedback.lightImpact();
            context.push(Routes.comingSoon, extra: 'Mart');
          },
        ),
        _ServiceItem(
          icon: Icons.bolt_rounded,
          label: 'Express',
          color: const Color(0xFFEAB308),
          onTap: () {
            HapticFeedback.lightImpact();
            context.push(Routes.comingSoon, extra: 'Express');
          },
        ),
        _ServiceItem(
          icon: Icons.directions_car_rounded,
          label: 'Transport',
          color: const Color(0xFF00C472),
          onTap: () {
            HapticFeedback.mediumImpact();
            onTransportTap();
          },
          isHighlighted: true,
        ),
        _ServiceItem(
          icon: Icons.local_mall_rounded,
          label: 'Shopping',
          color: const Color(0xFF9333EA),
          onTap: () {
            HapticFeedback.lightImpact();
            context.push(Routes.comingSoon, extra: 'Shopping');
          },
        ),
        _ServiceItem(
          icon: Icons.auto_awesome_rounded,
          label: 'Offers',
          color: const Color(0xFFEC4899),
          onTap: () {
            HapticFeedback.lightImpact();
            context.push(Routes.promotions);
          },
        ),
        _ServiceItem(
          icon: Icons.card_giftcard_rounded,
          label: 'Gift Cards',
          color: const Color(0xFFEF4444),
          onTap: () {
            HapticFeedback.lightImpact();
            context.push(Routes.comingSoon, extra: 'Gift Cards');
          },
        ),
        _ServiceItem(
          icon: Icons.apps_rounded,
          label: 'More',
          color: const Color(0xFF6B7280),
          onTap: () {
            HapticFeedback.lightImpact();
            context.push(Routes.comingSoon, extra: 'More');
          },
        ),
      ];
}

class _ServiceItem {
  const _ServiceItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isHighlighted = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isHighlighted;
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile(this.item);
  final _ServiceItem item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: item.onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: item.isHighlighted
                    ? item.color.withValues(alpha: 0.15)
                    : scheme.surfaceContainerHighest.withValues(alpha: 0.6),
                shape: BoxShape.circle,
                border: item.isHighlighted
                    ? Border.all(color: item.color.withValues(alpha: 0.4), width: 1.5)
                    : null,
              ),
              alignment: Alignment.center,
              child: Icon(item.icon, color: item.color, size: 26),
            ),
            const SizedBox(height: 6),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface.withValues(alpha: 0.85),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

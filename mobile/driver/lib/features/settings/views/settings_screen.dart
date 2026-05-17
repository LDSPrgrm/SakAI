import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../../../app/router.dart';

class DriverSettingsScreen extends StatelessWidget {
  const DriverSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = SakaiDesignTokens.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: EdgeInsets.all(t.spaceMd),
        children: [
          _Section(
            title: 'Driver',
            tiles: [
              _Tile(
                icon: Icons.access_time,
                label: 'Availability',
                onTap: () => context.push(Routes.availability),
              ),
              _Tile(
                icon: Icons.person_outline,
                label: 'Profile',
                onTap: () => context.push(Routes.profile),
              ),
              _Tile(
                icon: Icons.directions_car,
                label: 'Vehicle',
                onTap: () => context.push(Routes.vehicleInfo),
              ),
              _Tile(
                icon: Icons.description_outlined,
                label: 'Documents',
                onTap: () => context.push(Routes.documents),
              ),
            ],
          ),
          SizedBox(height: t.spaceMd),
          _Section(
            title: 'Support',
            tiles: [
              _Tile(
                icon: Icons.help_outline,
                label: 'Driver support',
                onTap: () => context.push(Routes.support),
              ),
              _Tile(
                icon: Icons.notifications_none,
                label: 'Notifications',
                onTap: () => context.push(Routes.notifications),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.tiles});
  final String title;
  final List<_Tile> tiles;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = SakaiDesignTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: t.spaceSm, bottom: t.spaceXs),
          child: Text(
            title,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        SakaiSurfaceCard(
          padding: EdgeInsets.zero,
          child: Column(children: tiles),
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

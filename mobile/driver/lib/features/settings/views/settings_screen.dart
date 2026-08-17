import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../../../app/router.dart';

class DriverSettingsScreen extends ConsumerWidget {
  const DriverSettingsScreen({super.key});

  static String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  static void _showThemePicker(
    BuildContext context,
    WidgetRef ref,
    ThemeMode current,
  ) {
    SakaiModalSheet.show<void>(
      context,
      builder: (sheetCtx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SakaiListTile(
            leading: const Icon(Icons.smartphone_outlined),
            title: const Text('System'),
            selected: current == ThemeMode.system,
            trailing:
                current == ThemeMode.system ? const Icon(Icons.check) : null,
            onTap: () {
              ref
                  .read(themeModeControllerProvider.notifier)
                  .setThemeMode(ThemeMode.system);
              Navigator.pop(sheetCtx);
            },
          ),
          SakaiListTile(
            leading: const Icon(Icons.light_mode_outlined),
            title: const Text('Light'),
            selected: current == ThemeMode.light,
            trailing:
                current == ThemeMode.light ? const Icon(Icons.check) : null,
            onTap: () {
              ref
                  .read(themeModeControllerProvider.notifier)
                  .setThemeMode(ThemeMode.light);
              Navigator.pop(sheetCtx);
            },
          ),
          SakaiListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: const Text('Dark'),
            selected: current == ThemeMode.dark,
            trailing:
                current == ThemeMode.dark ? const Icon(Icons.check) : null,
            onTap: () {
              ref
                  .read(themeModeControllerProvider.notifier)
                  .setThemeMode(ThemeMode.dark);
              Navigator.pop(sheetCtx);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = SakaiDesignTokens.of(context);
    final themeMode = ref.watch(themeModeControllerProvider);
    return Scaffold(
      appBar: const SakaiAppBar(title: Text('Settings')),
      body: ListView(
        padding: EdgeInsets.all(t.spaceMd),
        children: [
          Padding(
            padding: EdgeInsets.only(left: t.spaceSm, bottom: t.spaceXs),
            child: Text(
              'Appearance',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          SakaiSurfaceCard(
            padding: EdgeInsets.zero,
            child: SakaiListTile(
              leading: const Icon(Icons.brightness_6_outlined),
              title: const Text('Theme'),
              subtitle: Text(_themeModeLabel(themeMode)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showThemePicker(context, ref, themeMode),
            ),
          ),
          SizedBox(height: t.spaceMd),
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
              _Tile(
                icon: Icons.shield_outlined,
                label: 'SOS & Safety',
                onTap: () => context.push(Routes.sosSafety),
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

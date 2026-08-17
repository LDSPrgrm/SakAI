import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../../../app/routes.dart';

/// Settings menu screen displaying all available settings options.
class SettingsMenuScreen extends ConsumerWidget {
  const SettingsMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeControllerProvider);
    return Scaffold(
      appBar: SakaiAppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader(context, 'Account'),
          _buildTile(
            context,
            Icons.account_balance_wallet_outlined,
            'Wallet',
            'Balance and transactions',
            onTap: () => context.push(Routes.wallet),
          ),
          _buildTile(
            context,
            Icons.inbox_outlined,
            'Notification inbox',
            'Recent alerts and ride updates',
            onTap: () => context.push(Routes.notifications),
          ),

          const SizedBox(height: 16),
          _buildSectionHeader(context, 'Preferences'),
          SakaiListTile(
            leading: Icon(
              Icons.brightness_6_outlined,
              color: Theme.of(context).iconTheme.color,
            ),
            title: const Text('Theme'),
            subtitle: Text(_themeModeLabel(themeMode)),
            trailing: Icon(
              Icons.chevron_right,
              size: 20,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            onTap: () => _showThemePicker(context, ref, themeMode),
          ),
          _buildTile(
            context,
            Icons.notifications_outlined,
            'Notifications',
            'Manage push notifications',
            onTap: () => context.push(Routes.settingsNotifications),
          ),
          _buildTile(
            context,
            Icons.emergency_outlined,
            'Emergency Contacts',
            'Manage your emergency contacts',
            onTap: () => context.push(Routes.settingsEmergencyContacts),
          ),
          _buildTile(
            context,
            Icons.shield_outlined,
            'SOS & Safety',
            'Ambient audio, live location, photo opt-ins',
            onTap: () => context.push(Routes.settingsSosSafety),
          ),
          _buildTile(
            context,
            Icons.language_outlined,
            'Language',
            'Choose your preferred language',
            onTap: () => context.push(Routes.settingsLanguage),
          ),
          _buildTile(
            context,
            Icons.place_outlined,
            'Saved Places',
            'Manage your saved locations',
            onTap: () => context.push(Routes.savedPlaces),
          ),

          const SizedBox(height: 16),
          _buildSectionHeader(context, 'Support'),
          _buildTile(
            context,
            Icons.help_outline_outlined,
            'Help Center',
            'FAQs and support articles',
            onTap: () => context.push(Routes.settingsHelp),
          ),

          const SizedBox(height: 16),
          _buildSectionHeader(context, 'Legal'),
          _buildTile(
            context,
            Icons.description_outlined,
            'Terms of Service',
            'Read our terms and conditions',
            onTap: () => context.push(Routes.settingsTerms),
          ),
          _buildTile(
            context,
            Icons.privacy_tip_outlined,
            'Privacy Policy',
            'Learn how we handle your data',
            onTap: () => context.push(Routes.settingsPrivacy),
          ),
        ],
      ),
    );
  }

  String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  void _showThemePicker(BuildContext context, WidgetRef ref, ThemeMode current) {
    SakaiModalSheet.show<void>(
      context,
      builder: (sheetCtx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SakaiListTile(
            leading: const Icon(Icons.smartphone_outlined),
            title: const Text('System'),
            selected: current == ThemeMode.system,
            trailing: current == ThemeMode.system
                ? const Icon(Icons.check)
                : null,
            onTap: () {
              ref.read(themeModeControllerProvider.notifier).setThemeMode(ThemeMode.system);
              Navigator.pop(sheetCtx);
            },
          ),
          SakaiListTile(
            leading: const Icon(Icons.light_mode_outlined),
            title: const Text('Light'),
            selected: current == ThemeMode.light,
            trailing: current == ThemeMode.light
                ? const Icon(Icons.check)
                : null,
            onTap: () {
              ref.read(themeModeControllerProvider.notifier).setThemeMode(ThemeMode.light);
              Navigator.pop(sheetCtx);
            },
          ),
          SakaiListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: const Text('Dark'),
            selected: current == ThemeMode.dark,
            trailing: current == ThemeMode.dark
                ? const Icon(Icons.check)
                : null,
            onTap: () {
              ref.read(themeModeControllerProvider.notifier).setThemeMode(ThemeMode.dark);
              Navigator.pop(sheetCtx);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle, {
    VoidCallback? onTap,
  }) {
    return SakaiSurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).iconTheme.color),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            size: 20,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

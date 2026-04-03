import 'package:flutter/material.dart';
import 'package:sakai_shared/sakai_shared.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/router.dart';
import '../view_models/driver_home_notifier.dart';

/// Driver home screen.
class DriverHomeScreen extends ConsumerWidget {
  const DriverHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(driverHomeNotifierProvider);
    final notifier = ref.read(driverHomeNotifierProvider.notifier);

    ref.listen<DriverHomeState>(driverHomeNotifierProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
        }
        notifier.clearError();
      }
    });

    final tokens = SakaiDesignTokens.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SakAI · Driver'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.go(Routes.login),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.primary.withValues(alpha: 0.1),
              scheme.surface,
              scheme.secondary.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.all(tokens.spaceMd),
          children: [
            Text(
              'Driver workspace',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: tokens.spaceSm),
            Text(
              'Shared theme from SakaiThemeConfig.driver(). '
              'Tweak seeds in mobile/shared/lib/theme/sakai_theme_config.dart.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: tokens.spaceLg),
            SakaiGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    state.online ? 'You are online' : 'Go online',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: tokens.spaceMd),
                  SakaiPrimaryButton(
                    label: state.loading
                        ? (state.online ? 'Going offline…' : 'Going online…')
                        : (state.online ? 'End shift' : 'Start shift'),
                    icon: state.online
                        ? Icons.stop_circle
                        : Icons.play_circle_outline,
                    onPressed: state.loading
                        ? null
                        : () => notifier.toggleStatus(),
                  ),
                  SizedBox(height: tokens.spaceSm),
                  SakaiSecondaryButton(
                    label: 'View earnings',
                    icon: Icons.payments_outlined,
                    onPressed: () {},
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

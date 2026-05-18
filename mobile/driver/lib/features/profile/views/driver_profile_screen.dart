import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../../../app/router.dart';
import '../view_models/driver_profile_notifier.dart';

class DriverProfileScreen extends ConsumerWidget {
  const DriverProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(driverProfileNotifierProvider);
    final notifier = ref.read(driverProfileNotifierProvider.notifier);
    final t = SakaiDesignTokens.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: RefreshIndicator(
        onRefresh: notifier.load,
        child: _body(context, state, notifier, t, theme),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    DriverProfileState state,
    DriverProfileNotifier notifier,
    SakaiDesignTokens t,
    ThemeData theme,
  ) {
    if (state.loading && state.profile == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.errorMessage != null && state.profile == null) {
      return SakaiEmptyState(
        icon: Icons.error_outline,
        title: 'Couldn\'t load profile',
        message: state.errorMessage,
        primaryLabel: 'Retry',
        onPrimary: notifier.load,
      );
    }
    final p = state.profile!;
    return ListView(
      padding: EdgeInsets.all(t.spaceMd),
      children: [
        SakaiGlassCard(
          child: Padding(
            padding: EdgeInsets.all(t.spaceLg),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    _initials(p.name),
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                SizedBox(width: t.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name, style: theme.textTheme.titleLarge),
                      Text(p.email, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: t.spaceMd),
        if (p.vehicle != null)
          SakaiSurfaceCard(
            onTap: () => context.push(Routes.vehicleInfo),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.directions_car),
              title: Text(
                '${p.vehicle!.make} ${p.vehicle!.model}',
                style: theme.textTheme.titleMedium,
              ),
              subtitle: Text(
                '${p.vehicle!.color} • ${p.vehicle!.plate}',
              ),
              trailing: const Icon(Icons.chevron_right),
            ),
          )
        else
          SakaiSurfaceCard(
            onTap: () => context.push(Routes.vehicleDetails),
            child: const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.add_circle_outline),
              title: Text('Add vehicle details'),
              trailing: Icon(Icons.chevron_right),
            ),
          ),
        SizedBox(height: t.spaceMd),
        SakaiSecondaryButton(
          icon: Icons.edit,
          label: 'Edit name',
          onPressed: state.saving
              ? null
              : () => _showEditNameSheet(context, notifier, p.name),
        ),
        if (state.backendUnavailable != null) ...[
          SizedBox(height: t.spaceSm),
          Text(
            'Editing profile is awaiting backend support.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.tertiary,
            ),
          ),
        ] else if (state.errorMessage != null) ...[
          SizedBox(height: t.spaceSm),
          Text(
            state.errorMessage!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  void _showEditNameSheet(
    BuildContext context,
    DriverProfileNotifier notifier,
    String current,
  ) {
    final controller = TextEditingController(text: current);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final t = SakaiDesignTokens.of(ctx);
        return Padding(
          padding: EdgeInsets.only(
            left: t.spaceLg,
            right: t.spaceLg,
            top: t.spaceLg,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + t.spaceLg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Edit name', style: Theme.of(ctx).textTheme.titleLarge),
              SizedBox(height: t.spaceMd),
              SakaiTextField(controller: controller, label: 'Full name'),
              SizedBox(height: t.spaceMd),
              SakaiPrimaryButton(
                label: 'Save',
                onPressed: () {
                  Navigator.of(ctx).pop();
                  notifier.saveName(controller.text.trim());
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

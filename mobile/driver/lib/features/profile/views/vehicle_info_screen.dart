import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../../../app/router.dart';
import '../view_models/driver_profile_notifier.dart';

/// Read-only summary of the driver's vehicle. Tap "Edit" to open the form
/// at [Routes.vehicleDetails].
class VehicleInfoScreen extends ConsumerWidget {
  const VehicleInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(driverProfileNotifierProvider);
    final t = SakaiDesignTokens.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Vehicle')),
      body: Padding(
        padding: EdgeInsets.all(t.spaceMd),
        child: state.profile?.vehicle == null
            ? SakaiEmptyState(
                icon: Icons.directions_car_outlined,
                title: 'No vehicle on file',
                primaryLabel: 'Add vehicle',
                onPrimary: () => context.push(Routes.vehicleDetails),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SakaiGlassCard(
                    child: Padding(
                      padding: EdgeInsets.all(t.spaceLg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${state.profile!.vehicle!.make} ${state.profile!.vehicle!.model}',
                            style: theme.textTheme.headlineSmall,
                          ),
                          SizedBox(height: t.spaceXs),
                          _Row(
                            label: 'Color',
                            value: state.profile!.vehicle!.color,
                          ),
                          _Row(
                            label: 'Plate',
                            value: state.profile!.vehicle!.plate,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: t.spaceMd),
                  SakaiPrimaryButton(
                    icon: Icons.edit,
                    label: 'Edit vehicle',
                    onPressed: () => context.push(Routes.vehicleDetails),
                  ),
                ],
              ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.titleMedium)),
        ],
      ),
    );
  }
}

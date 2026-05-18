import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../view_models/driver_profile_notifier.dart';

/// Form for entering or editing the driver's vehicle details.
class VehicleDetailsScreen extends ConsumerStatefulWidget {
  const VehicleDetailsScreen({super.key});

  @override
  ConsumerState<VehicleDetailsScreen> createState() =>
      _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends ConsumerState<VehicleDetailsScreen> {
  final _make = TextEditingController();
  final _model = TextEditingController();
  final _color = TextEditingController();
  final _plate = TextEditingController();
  bool _seeded = false;

  @override
  void dispose() {
    _make.dispose();
    _model.dispose();
    _color.dispose();
    _plate.dispose();
    super.dispose();
  }

  void _seedFromProfile() {
    if (_seeded) return;
    final vehicle = ref.read(driverProfileNotifierProvider).profile?.vehicle;
    if (vehicle == null) return;
    _make.text = vehicle.make;
    _model.text = vehicle.model;
    _color.text = vehicle.color;
    _plate.text = vehicle.plate;
    _seeded = true;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(driverProfileNotifierProvider);
    final notifier = ref.read(driverProfileNotifierProvider.notifier);
    final t = SakaiDesignTokens.of(context);

    _seedFromProfile();

    return Scaffold(
      appBar: AppBar(title: const Text('Vehicle details')),
      body: SafeArea(
        child: state.backendUnavailable != null
            ? const ComingSoonState(feature: 'Vehicle edits')
            : ListView(
          padding: EdgeInsets.all(t.spaceLg),
          children: [
            SakaiTextField(controller: _make, label: 'Make'),
            SakaiTextField(controller: _model, label: 'Model'),
            SakaiTextField(controller: _color, label: 'Color'),
            SakaiTextField(controller: _plate, label: 'License plate'),
            SizedBox(height: t.spaceMd),
            if (state.errorMessage != null)
              Padding(
                padding: EdgeInsets.only(bottom: t.spaceSm),
                child: Text(
                  state.errorMessage!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                ),
              ),
            SakaiPrimaryButton(
              label: state.saving ? 'Saving…' : 'Save vehicle',
              onPressed: state.saving ? null : () => _save(notifier),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save(DriverProfileNotifier notifier) async {
    final make = _make.text.trim();
    final model = _model.text.trim();
    final color = _color.text.trim();
    final plate = _plate.text.trim();
    if (make.isEmpty || model.isEmpty || color.isEmpty || plate.isEmpty) return;
    await notifier.saveVehicle(
      make: make,
      model: model,
      color: color,
      plate: plate,
    );
    if (!mounted) return;
    final err = ref.read(driverProfileNotifierProvider).errorMessage;
    if (err == null && context.canPop()) {
      context.pop();
    }
  }
}

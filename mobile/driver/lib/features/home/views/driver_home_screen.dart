import 'package:flutter/material.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../view_models/driver_home_view_model.dart';

/// Driver home screen.
///
/// Presentation layer only — all state and logic delegated to
/// [DriverHomeViewModel]. The widget reads state via [ListenableBuilder]
/// and calls VM methods in response to user interactions.
class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  final _plate = TextEditingController(text: 'ABC 1234');
  late final DriverHomeViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = DriverHomeViewModel();
    _vm.addListener(_onVmChanged);
  }

  @override
  void dispose() {
    _vm.removeListener(_onVmChanged);
    _vm.dispose();
    _plate.dispose();
    super.dispose();
  }

  void _onVmChanged() {
    if (_vm.errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_vm.errorMessage!)),
      );
      _vm.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = SakaiDesignTokens.of(context);

    return SakaiScreenScaffold(
      title: 'SakAI · Driver',
      body: ListenableBuilder(
        listenable: _vm,
        builder: (context, _) {
          return ListView(
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
              SakaiSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _vm.online ? 'You are online' : 'Go online',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: tokens.spaceMd),
                    if (!_vm.online)
                      SakaiTextField(
                        controller: _plate,
                        label: 'Vehicle plate',
                        prefixIcon: const Icon(Icons.directions_car_outlined),
                      ),
                    SakaiPrimaryButton(
                      label: _vm.loading
                          ? (_vm.online ? 'Going offline…' : 'Going online…')
                          : (_vm.online ? 'End shift' : 'Start shift'),
                      icon: _vm.online
                          ? Icons.stop_circle
                          : Icons.play_circle_outline,
                      onPressed: _vm.loading
                          ? null
                          : () {
                              if (_vm.online) {
                                _vm.goOffline();
                              } else {
                                _vm.goOnline(_plate.text);
                              }
                            },
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
          );
        },
      ),
    );
  }
}

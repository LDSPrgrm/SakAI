import 'package:flutter/material.dart';
import 'package:sakai_shared/sakai_shared.dart';

/// Driver home placeholder (UI demo).
///
/// Presentation layer only: no API client calls here.
class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  final _plate = TextEditingController(text: 'ABC 1234');

  @override
  void dispose() {
    _plate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = SakaiDesignTokens.of(context);

    return SakaiScreenScaffold(
      title: 'SakAI · Driver',
      body: ListView(
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
                  'Go online',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: tokens.spaceMd),
                SakaiTextField(
                  controller: _plate,
                  label: 'Vehicle plate',
                  prefixIcon: const Icon(Icons.directions_car_outlined),
                ),
                SakaiPrimaryButton(
                  label: 'Start shift',
                  icon: Icons.play_circle_outline,
                  onPressed: () {},
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
    );
  }
}


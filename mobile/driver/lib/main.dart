import 'package:flutter/material.dart';
import 'package:sakai_shared/sakai_shared.dart';

void main() {
  runApp(const DriverApp());
}

class DriverApp extends StatelessWidget {
  const DriverApp({super.key});

  static final SakaiThemeConfig _config = SakaiThemeConfig.driver();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SakAI Driver',
      theme: SakaiTheme.light(_config),
      darkTheme: SakaiTheme.dark(_config),
      themeMode: ThemeMode.system,
      home: const _DriverHome(),
    );
  }
}

class _DriverHome extends StatefulWidget {
  const _DriverHome();

  @override
  State<_DriverHome> createState() => _DriverHomeState();
}

class _DriverHomeState extends State<_DriverHome> {
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
            'Theme from SakaiThemeConfig.driver(). '
            'Tweak seeds in sakai_shared/lib/theme/sakai_theme_config.dart.',
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

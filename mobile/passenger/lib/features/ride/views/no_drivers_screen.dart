import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../../../app/routes.dart';

/// Shown when the matchmaking pass finds no available driver.
class NoDriversScreen extends StatelessWidget {
  const NoDriversScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SakaiEmptyState(
        icon: Icons.directions_car_filled_outlined,
        title: 'No drivers available',
        message:
            'We couldn\'t find a driver nearby. Try again in a moment or pick a different ride option.',
        primaryLabel: 'Try again',
        onPrimary: () => context.pop(),
        secondaryLabel: 'Change ride options',
        onSecondary: () => context.go(Routes.home),
      ),
    );
  }
}

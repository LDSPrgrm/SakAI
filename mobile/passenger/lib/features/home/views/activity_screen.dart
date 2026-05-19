import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../../../app/routes.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SakaiAppBar(title: const Text('Activity')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history, size: 64),
            const SizedBox(height: 16),
            const Text('View your past rides'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.push(Routes.rideHistory),
              icon: const Icon(Icons.list),
              label: const Text('Ride History'),
            ),
          ],
        ),
      ),
    );
  }
}

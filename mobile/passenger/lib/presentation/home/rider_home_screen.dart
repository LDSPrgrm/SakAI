import 'package:flutter/material.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../../domain/auth_session.dart';

/// Post-login rider home (placeholder for map / request flow).
class RiderHomeScreen extends StatefulWidget {
  const RiderHomeScreen({
    super.key,
    required this.session,
    required this.onSignOut,
  });

  final AuthSession session;
  final VoidCallback onSignOut;

  @override
  State<RiderHomeScreen> createState() => _RiderHomeScreenState();
}

class _RiderHomeScreenState extends State<RiderHomeScreen> {
  final _destination = TextEditingController(text: 'Downtown');

  @override
  void dispose() {
    _destination.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = SakaiDesignTokens.of(context);
    return SakaiScreenScaffold(
      title: 'SakAI · Rider',
      actions: [
        IconButton(
          tooltip: 'Sign out',
          icon: const Icon(Icons.logout),
          onPressed: widget.onSignOut,
        ),
      ],
      body: ListView(
        children: [
          Text(
            'You are signed in',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: tokens.spaceXs),
          Text(
            'Session expires: ${widget.session.accessTokenExpiresAt.toLocal()}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          SizedBox(height: tokens.spaceLg),
          SakaiSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Where to?',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: tokens.spaceMd),
                SakaiTextField(
                  controller: _destination,
                  label: 'Destination',
                  prefixIcon: const Icon(Icons.place_outlined),
                ),
                SakaiPrimaryButton(
                  label: 'Request ride',
                  icon: Icons.near_me,
                  onPressed: () {},
                ),
                SizedBox(height: tokens.spaceSm),
                SakaiSecondaryButton(
                  label: 'Schedule',
                  icon: Icons.schedule,
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

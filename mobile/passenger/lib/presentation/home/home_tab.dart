import 'package:flutter/material.dart';
import 'package:sakai_shared/sakai_shared.dart';
import '../../../domain/auth_session.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key, required this.session});
  final AuthSession session;

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final _destination = TextEditingController(text: 'Downtown');

  @override
  void dispose() {
    _destination.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = SakaiDesignTokens.of(context);
    return ListView(
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
              SizedBox(height: tokens.spaceMd),
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
    );
  }
}

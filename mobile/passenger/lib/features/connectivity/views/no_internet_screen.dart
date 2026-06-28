import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sakai_shared/sakai_shared.dart';

/// Reachable via [Routes.noInternet] for explicit connectivity-failure handoff.
///
/// NOTE: Automatic redirect on connectivity loss requires the `connectivity_plus`
/// package (not yet in pubspec). Add it + a `Stream<ConnectivityResult>` listener
/// in `passenger_app.dart` to make this screen reactive globally. For now the
/// route can be navigated to manually from any failure branch.
class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SakaiEmptyState(
          icon: Icons.wifi_off_rounded,
          title: 'You\'re offline',
          message:
              'Check your Wi-Fi or mobile data, then try again. We\'ll keep your last ride state safe.',
          primaryLabel: 'Try again',
          onPrimary: () => context.pop(),
        ),
      ),
    );
  }
}

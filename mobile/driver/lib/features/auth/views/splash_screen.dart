import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../view_models/splash_notifier.dart';

/// Entry point screen — invisible to user. Resolves session and routes accordingly.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final splashAsync = ref.watch(splashProvider);

    // React to state changes and route once resolved.
    ref.listen<AsyncValue<SplashState>>(splashProvider, (_, next) {
      next.whenData((state) {
        switch (state) {
          case SplashState.unauthenticated:
            context.go(Routes.login);
          case SplashState.home:
            context.go(Routes.home);
          case SplashState.loading:
            break;
        }
      });
    });

    final scheme = Theme.of(context).colorScheme;

    return splashAsync.when(
      data: (_) => _SplashBody(scheme: scheme),
      loading: () => _SplashBody(scheme: scheme),
      error: (err, stack) =>
          _ErrorBody(onRetry: () => ref.invalidate(splashProvider)),
    );
  }
}

class _SplashBody extends StatelessWidget {
  const _SplashBody({required this.scheme});
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scheme.surface,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Hero(
              tag: 'app_logo',
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.drive_eta,
                  color: scheme.onPrimaryContainer,
                  size: 36,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Hero(
              tag: 'app_name',
              child: Material(
                color: Colors.transparent,
                child: Text(
                  'SakAI Driver',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: scheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48),
            const SizedBox(height: 16),
            const Text('Could not connect to server.'),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

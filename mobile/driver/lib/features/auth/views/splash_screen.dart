import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../view_models/splash_notifier.dart';

/// Entry point screen — invisible to user. Resolves session and routes accordingly.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = ref.read(splashProvider);
      state.whenOrNull(
        data: (result) => _handleNavigation(result),
        error: (err, stack) => _handleNavigation(SplashState.transientError),
      );
    });
  }

  void _handleNavigation(SplashState state) {
    if (_navigated || !mounted) return;

    switch (state) {
      case SplashState.home:
        _navigated = true;
        context.go(Routes.home);
        break;
      case SplashState.activeRide:
        _navigated = true;
        context.go(Routes.rideActive);
        break;
      case SplashState.welcome:
        _navigated = true;
        context.go(Routes.welcome);
        break;
      case SplashState.unauthenticated:
        _navigated = true;
        context.go(Routes.login);
        break;
      case SplashState.transientError:
        // Stay here and show error body
        break;
      case SplashState.loading:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<SplashState>>(splashProvider, (previous, next) {
      if (next is AsyncData<SplashState>) {
        _handleNavigation(next.value);
      }
    });

    final splashAsync = ref.watch(splashProvider);
    final scheme = Theme.of(context).colorScheme;

    return splashAsync.when(
      data: (state) => state == SplashState.transientError
          ? _ErrorBody(onRetry: () => ref.invalidate(splashProvider))
          : _SplashBody(scheme: scheme),
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
                  Icons.drive_eta_rounded,
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

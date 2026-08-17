import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../../../app/routes.dart';
import '../view_models/splash_notifier.dart';

/// Entry point screen — invisible to user. Resolves session and routes accordingly.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _navigated = false;
  Timer? _failsafeTimer;

  @override
  void initState() {
    super.initState();
    // Handle case where provider is already resolved on mount (e.g. E2E mode)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = ref.read(splashProvider);
      state.whenOrNull(
        data: (result) => _handleNavigation(result),
        error: (err, stack) =>
            _handleNavigation(const SplashResult(SplashState.transientError)),
      );
    });
    // Fail-safe: if the splash provider stalls past 8s (no resolve, no error),
    // bail to the login screen instead of leaving the user on a frozen logo.
    _failsafeTimer = Timer(const Duration(seconds: 8), () {
      if (!mounted || _navigated) return;
      _navigated = true;
      SakaiSnackBar.info(
        context,
        'Taking longer than expected. Please sign in again.',
      );
      context.go(Routes.login);
    });
  }

  @override
  void dispose() {
    _failsafeTimer?.cancel();
    super.dispose();
  }

  void _handleNavigation(SplashResult result) {
    if (_navigated || !mounted) return;

    switch (result.state) {
      case SplashState.welcome:
        _navigated = true;
        context.go(Routes.welcome);
        break;
      case SplashState.unauthenticated:
        _navigated = true;
        context.go(Routes.login);
        break;
      case SplashState.home:
        _navigated = true;
        context.go(Routes.home);
        break;
      case SplashState.activeRide:
        final rideId = result.activeRideId;
        if (rideId != null) {
          _navigated = true;
          context.go(Routes.rideActive, extra: rideId);
        } else {
          _navigated = true;
          context.go(Routes.home);
        }
        break;
      case SplashState.transientError:
        break; // Stay on splash, _ErrorBody shown below.
      case SplashState.loading:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final splashAsync = ref.watch(splashProvider);

    // React to provider state changes and route once resolved.
    ref.listen<AsyncValue<SplashResult>>(splashProvider, (_, next) {
      next.whenData((result) {
        _handleNavigation(result);
      });
    });

    final scheme = Theme.of(context).colorScheme;

    return splashAsync.when(
      data: (result) => result.state == SplashState.transientError
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
    final t = SakaiDesignTokens.of(context);
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
                  borderRadius: BorderRadius.circular(t.radiusLg),
                ),
                child: Icon(
                  Icons.local_taxi_outlined,
                  color: scheme.onPrimaryContainer,
                  size: 36,
                ),
              ),
            ),
            SizedBox(height: t.spaceLg),
            Hero(
              tag: 'app_name',
              child: Material(
                color: Colors.transparent,
                child: Text(
                  'SakAI',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),
            SizedBox(height: t.spaceXl),
            SizedBox(
              width: t.iconMd,
              height: t.iconMd,
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
    final t = SakaiDesignTokens.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: t.spaceMd),
            Text(
              'Could not connect to server.',
              style: theme.textTheme.bodyLarge,
            ),
            SizedBox(height: t.spaceMd),
            SakaiPrimaryButton(
              label: 'Retry',
              onPressed: onRetry,
              expand: false,
            ),
          ],
        ),
      ),
    );
  }
}

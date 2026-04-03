import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../../../app/router.dart';
import '../view_models/login_notifier.dart';
import '../view_models/register_notifier.dart';
import 'widgets/login_form.dart';
import 'widgets/register_form.dart';

enum AuthMode { login, register }

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key, this.initialMode = AuthMode.login});

  final AuthMode initialMode;

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  late AuthMode _mode;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
  }

  void _toggleMode() {
    setState(() {
      _mode = _mode == AuthMode.login ? AuthMode.register : AuthMode.login;
    });
    // Clear errors when switching
    ref.read(loginNotifierProvider.notifier).clearError();
    ref.read(registerNotifierProvider.notifier).clearError();
  }

  @override
  Widget build(BuildContext context) {
    // Listen for success in both notifiers
    ref.listen<LoginState>(loginNotifierProvider, (_, next) {
      if (next.succeeded && context.mounted) {
        context.go(Routes.home);
      }
    });

    ref.listen<RegisterState>(registerNotifierProvider, (_, next) {
      if (next.succeeded && context.mounted) {
        context.go(Routes.home);
      }
    });

    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final tokens = SakaiDesignTokens.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Vibrant Background
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                stops: const [0.0, 0.4, 0.7, 1.0],
                colors: [
                  scheme.primary.withValues(alpha: 0.25),
                  scheme.surface,
                  scheme.secondary.withValues(alpha: 0.15),
                  scheme.primary.withValues(alpha: 0.1),
                ],
              ),
            ),
          ),
          // Subtle Decorative Blobs (Premium Vibe)
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.primary.withValues(alpha: 0.12),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50.0, sigmaY: 50.0),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: tokens.spaceLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: tokens.spaceXl),
                  _BrandHeader(
                    mode: _mode,
                    colorScheme: scheme,
                    textTheme: textTheme,
                  ),
                  SizedBox(height: tokens.spaceXl),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.0, 0.05),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                    child: _mode == AuthMode.login
                        ? LoginForm(
                            key: const ValueKey('login_form'),
                            onRegisterTap: _toggleMode,
                          )
                        : RegisterForm(
                            key: const ValueKey('register_form'),
                            onLoginTap: _toggleMode,
                          ),
                  ),
                  SizedBox(height: tokens.spaceLg),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({
    required this.mode,
    required this.colorScheme,
    required this.textTheme,
  });

  final AuthMode mode;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Hero(
              tag: 'app_logo',
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.local_taxi_rounded,
                  color: colorScheme.onPrimary,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Hero(
              tag: 'app_name',
              child: Material(
                color: Colors.transparent,
                child: Text(
                  'SakAI',
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.0,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Column(
            key: ValueKey(mode),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mode == AuthMode.login ? 'Welcome back' : 'Create account',
                style: textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 32,
                  letterSpacing: -0.5,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                mode == AuthMode.login
                    ? 'Get ready to experience the next generation of urban mobility.'
                    : 'Join the revolution. Safe, smart, and sustainable rides await.',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                  height: 1.5,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

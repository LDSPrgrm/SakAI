import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../../../app/router.dart';
import '../view_models/login_notifier.dart';

/// Rider sign-in screen — Riverpod ConsumerWidget.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSignIn() async {
    FocusScope.of(context).unfocus();
    await ref
        .read(loginNotifierProvider.notifier)
        .signIn(email: _emailCtrl.text, password: _passwordCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginNotifierProvider);

    // Navigate on success.
    ref.listen<LoginState>(loginNotifierProvider, (_, next) {
      if (next.succeeded && context.mounted) {
        context.go(Routes.home);
      }
    });

    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final tokens = SakaiDesignTokens.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.primary.withValues(alpha: 0.15),
              scheme.surface,
              scheme.secondary.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: tokens.spaceLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: tokens.spaceXl),
                _BrandHeader(colorScheme: scheme, textTheme: textTheme),
                SizedBox(height: tokens.spaceXl),
                if (loginState.errorMessage != null)
                  Padding(
                    padding: EdgeInsets.only(bottom: tokens.spaceMd),
                    child: Material(
                      color: scheme.errorContainer,
                      borderRadius: BorderRadius.circular(tokens.radiusMd),
                      child: Padding(
                        padding: EdgeInsets.all(tokens.spaceMd),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: scheme.onErrorContainer,
                            ),
                            SizedBox(width: tokens.spaceSm),
                            Expanded(
                              child: Text(
                                loginState.errorMessage!,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: scheme.onErrorContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutBack,
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 50 * (1.0 - value)),
                      child: Opacity(
                        opacity: value.clamp(0.0, 1.0),
                        child: SakaiGlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SakaiSecondaryButton(
                                label: 'Continue with Google',
                                onPressed: loginState.busy
                                    ? null
                                    : () {
                                        // TODO: Implement Google Sign-In
                                      },
                                icon: Icons.account_circle_outlined,
                              ),
                              SizedBox(height: tokens.spaceLg),
                              Row(
                                children: [
                                  const Expanded(child: Divider()),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: tokens.spaceSm,
                                    ),
                                    child: Text(
                                      'Or continue with email',
                                      style: textTheme.bodySmall?.copyWith(
                                        color: scheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                  const Expanded(child: Divider()),
                                ],
                              ),
                              SizedBox(height: tokens.spaceLg),
                              SakaiTextField(
                                key: const Key('login_email'),
                                controller: _emailCtrl,
                                label: 'Email',
                                hint: 'you@example.com',
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                prefixIcon: const Icon(Icons.mail_outline),
                                onChanged: (_) => ref
                                    .read(loginNotifierProvider.notifier)
                                    .clearError(),
                              ),
                              SakaiTextField(
                                key: const Key('login_password'),
                                controller: _passwordCtrl,
                                label: 'Password',
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.done,
                                prefixIcon: const Icon(Icons.lock_outline),
                                onChanged: (_) => ref
                                    .read(loginNotifierProvider.notifier)
                                    .clearError(),
                                suffixIcon: IconButton(
                                  tooltip: _obscurePassword
                                      ? 'Show password'
                                      : 'Hide password',
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                  onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                ),
                              ),
                              SizedBox(height: tokens.spaceSm),
                              SakaiPrimaryButton(
                                label: loginState.busy
                                    ? 'Signing in…'
                                    : 'Sign in',
                                icon: Icons.login,
                                onPressed: loginState.busy ? null : _onSignIn,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: tokens.spaceLg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'New rider?',
                      style: textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    TextButton(
                      onPressed: loginState.busy
                          ? null
                          : () => context.push(Routes.register),
                      child: const Text('Create account'),
                    ),
                  ],
                ),
                SizedBox(height: tokens.spaceLg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({required this.colorScheme, required this.textTheme});
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
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.local_taxi_outlined,
                  color: colorScheme.onPrimaryContainer,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Hero(
              tag: 'app_name',
              child: Material(
                color: Colors.transparent,
                child: Text(
                  'SakAI',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Welcome back',
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: -0.25,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to book rides and track your driver in real time.',
          style: textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../../../app/router.dart';
import '../view_models/login_notifier.dart';

/// Clean, glassmorphism-based login screen with social auth options.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSignIn() {
    ref
        .read(loginNotifierProvider.notifier)
        .signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final t = SakaiDesignTokens.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final state = ref.watch(loginNotifierProvider);

    ref.listen<LoginState>(loginNotifierProvider, (_, next) {
      if (next.succeeded) {
        context.go(Routes.home);
      }
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: scheme.error,
          ),
        );
        ref.read(loginNotifierProvider.notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: t.spaceXl,
            vertical: t.spaceXl * 2,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: t.spaceXl * 2),
              // App Icon / Logo area
              Center(
                child: Hero(
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
              ),
              SizedBox(height: t.spaceXl),
              Text(
                'Welcome back',
                textAlign: TextAlign.center,
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: t.spaceXs),
              Text(
                'Sign in to start receiving rides',
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: t.spaceXl * 2),

              // Glassmorphism Form Container
              SakaiGlassCard(
                child: Padding(
                  padding: EdgeInsets.all(t.spaceLg),
                  child: Column(
                    children: [
                      SakaiTextField(
                        key: const Key('login_email'),
                        controller: _emailController,
                        label: 'Email',
                        hint: 'name@example.com',
                        prefixIcon: const Icon(Icons.email_outlined),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        enabled: !state.busy,
                      ),
                      SizedBox(height: t.spaceMd),
                      SakaiTextField(
                        key: const Key('login_password'),
                        controller: _passwordController,
                        label: 'Password',
                        hint: '••••••••',
                        prefixIcon: const Icon(Icons.lock_outline),
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        enabled: !state.busy,
                        onChanged: (_) {},
                      ),
                      SizedBox(height: t.spaceXl),
                      SakaiPrimaryButton(
                        label: state.busy ? 'Signing in…' : 'Sign in',
                        icon: Icons.login,
                        onPressed: state.busy ? null : _onSignIn,
                      ),
                      SizedBox(height: t.spaceLg),
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: t.spaceSm,
                            ),
                            child: Text(
                              'Or continue with',
                              style: textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      SizedBox(height: t.spaceLg),
                      SakaiSecondaryButton(
                        label: 'Continue with Google',
                        onPressed: state.busy
                            ? null
                            : () => ref
                                  .read(loginNotifierProvider.notifier)
                                  .signInWithGoogle(),
                        icon: Icons.account_circle_outlined,
                      ),
                      SizedBox(height: t.spaceSm),
                      SakaiSecondaryButton(
                        label: 'Continue with Phone',
                        onPressed: state.busy
                            ? null
                            : () => ref
                                  .read(loginNotifierProvider.notifier)
                                  .signInWithPhone(),
                        icon: Icons.phone_outlined,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: t.spaceXl * 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                  TextButton(
                    onPressed: state.busy
                        ? null
                        : () => context.push(Routes.register),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: t.spaceSm),
                    ),
                    child: const Text('Register'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

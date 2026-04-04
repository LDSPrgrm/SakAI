import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../../view_models/login_notifier.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key, required this.onRegisterTap});

  final VoidCallback onRegisterTap;

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
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
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final tokens = SakaiDesignTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
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
                    Icon(Icons.error_outline, color: scheme.onErrorContainer),
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
        SakaiGlassCard(
          opacity: 0.15,
          blur: 20,
          borderOpacity: 0.3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SakaiTextField(
                key: const Key('login_email'),
                controller: _emailCtrl,
                label: 'Email',
                hint: 'you@example.com',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                prefixIcon: const Icon(Icons.mail_outline),
                onChanged: (_) =>
                    ref.read(loginNotifierProvider.notifier).clearError(),
              ),
              SakaiTextField(
                key: const Key('login_password'),
                controller: _passwordCtrl,
                label: 'Password',
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                prefixIcon: const Icon(Icons.lock_outline),
                onChanged: (_) =>
                    ref.read(loginNotifierProvider.notifier).clearError(),
                suffixIcon: IconButton(
                  tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              SizedBox(height: tokens.spaceSm),
              SakaiPrimaryButton(
                key: const Key('login_submit'),
                label: loginState.busy ? 'Signing in…' : 'Sign in',
                icon: Icons.arrow_forward_rounded,
                onPressed: loginState.busy ? null : _onSignIn,
              ),
              SizedBox(height: tokens.spaceLg),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: tokens.spaceSm),
                    child: Text(
                      'Or continue with',
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              SizedBox(height: tokens.spaceLg),
              SakaiSecondaryButton(
                label: 'Continue with Google',
                onPressed: loginState.busy
                    ? null
                    : () => ref
                          .read(loginNotifierProvider.notifier)
                          .signInWithGoogle(),
                icon: Icons.account_circle_outlined,
              ),
              SizedBox(height: tokens.spaceSm),
              SakaiSecondaryButton(
                label: 'Continue with Phone',
                onPressed: loginState.busy
                    ? null
                    : () => ref
                          .read(loginNotifierProvider.notifier)
                          .signInWithPhone(),
                icon: Icons.phone_outlined,
              ),
            ],
          ),
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
              onPressed: loginState.busy ? null : widget.onRegisterTap,
              child: const Text('Create account'),
            ),
          ],
        ),
      ],
    );
  }
}

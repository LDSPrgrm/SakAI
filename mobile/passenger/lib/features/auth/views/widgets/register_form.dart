import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../../view_models/register_notifier.dart';

class RegisterForm extends ConsumerStatefulWidget {
  const RegisterForm({super.key, required this.onLoginTap});

  final VoidCallback onLoginTap;

  @override
  ConsumerState<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends ConsumerState<RegisterForm> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    FocusScope.of(context).unfocus();
    await ref
        .read(registerNotifierProvider.notifier)
        .register(
          name: _nameCtrl.text,
          email: _emailCtrl.text,
          password: _passwordCtrl.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final registerState = ref.watch(registerNotifierProvider);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final tokens = SakaiDesignTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (registerState.errorMessage != null)
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
                        registerState.errorMessage!,
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
                key: const Key('register_name'),
                controller: _nameCtrl,
                label: 'Full Name',
                hint: 'Jane Doe',
                errorText: registerState.fieldErrors['name'],
                textInputAction: TextInputAction.next,
                prefixIcon: const Icon(Icons.person_outline),
                onChanged: (_) =>
                    ref.read(registerNotifierProvider.notifier).clearError(),
              ),
              SakaiTextField(
                key: const Key('register_email'),
                controller: _emailCtrl,
                label: 'Email',
                hint: 'you@example.com',
                errorText: registerState.fieldErrors['email'],
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                prefixIcon: const Icon(Icons.mail_outline),
                onChanged: (_) =>
                    ref.read(registerNotifierProvider.notifier).clearError(),
              ),
              SakaiTextField(
                key: const Key('register_password'),
                controller: _passwordCtrl,
                label: 'Password',
                errorText: registerState.fieldErrors['password'],
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                prefixIcon: const Icon(Icons.lock_outline),
                onChanged: (_) =>
                    ref.read(registerNotifierProvider.notifier).clearError(),
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
              SizedBox(height: tokens.spaceLg),
              SakaiPrimaryButton(
                label: registerState.busy
                    ? 'Creating Account…'
                    : 'Create Account',
                icon: Icons.person_add_rounded,
                onPressed: registerState.busy ? null : _onRegister,
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
                onPressed: registerState.busy ? null : () {},
                icon: Icons.account_circle_outlined,
              ),
            ],
          ),
        ),
        SizedBox(height: tokens.spaceLg),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Already have an account?',
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            TextButton(
              onPressed: registerState.busy ? null : widget.onLoginTap,
              child: const Text('Sign in'),
            ),
          ],
        ),
      ],
    );
  }
}

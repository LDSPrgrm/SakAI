import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool _agreeToTerms = false;
  Map<String, String> _errors = {};
  String? _termsError;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    final errors = <String, String>{};
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (name.isEmpty) errors['name'] = 'Full name is required';

    if (email.isEmpty) {
      errors['email'] = 'Email is required';
    } else if (!RegExp(r'^[\w.+\-]+@[\w\-]+\.[a-zA-Z]{2,}$').hasMatch(email)) {
      errors['email'] = 'Enter a valid email address';
    }

    if (password.isEmpty) {
      errors['password'] = 'Password is required';
    } else if (password.length < 8) {
      errors['password'] = 'Password must be at least 8 characters';
    }

    String? termsError;
    if (!_agreeToTerms) termsError = 'You must agree to the Terms & Privacy Policy';

    setState(() {
      _errors = errors;
      _termsError = termsError;
    });
    return errors.isEmpty && termsError == null;
  }

  Future<void> _onRegister() async {
    if (!_validate()) {
      HapticFeedback.heavyImpact();
      return;
    }
    FocusScope.of(context).unfocus();
    await ref
        .read(registerNotifierProvider.notifier)
        .register(
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Create account',
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: scheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: tokens.spaceSm),
            Text(
              'Get moving with SakAI.',
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: tokens.spaceXl),
            SakaiTextField(
              key: const Key('register_name'),
              controller: _nameCtrl,
              label: 'Full Name',
              hint: 'Jane Doe',
              errorText: _errors['name'] ?? registerState.fieldErrors['name'],
              textInputAction: TextInputAction.next,
              prefixIcon: const Icon(Icons.person_outline_rounded),
              onChanged: (_) {
                ref.read(registerNotifierProvider.notifier).clearError();
                if (_errors.containsKey('name')) setState(() => _errors = Map.from(_errors)..remove('name'));
              },
            ),
            SakaiTextField(
              key: const Key('register_email'),
              controller: _emailCtrl,
              label: 'Email address',
              hint: 'you@example.com',
              errorText: _errors['email'] ?? registerState.fieldErrors['email'],
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              prefixIcon: const Icon(Icons.mail_outline_rounded),
              onChanged: (_) {
                ref.read(registerNotifierProvider.notifier).clearError();
                if (_errors.containsKey('email')) setState(() => _errors = Map.from(_errors)..remove('email'));
              },
            ),
            SakaiTextField(
              key: const Key('register_password'),
              controller: _passwordCtrl,
              label: 'Password',
              errorText: _errors['password'] ?? registerState.fieldErrors['password'],
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              onChanged: (_) {
                ref.read(registerNotifierProvider.notifier).clearError();
                if (_errors.containsKey('password')) setState(() => _errors = Map.from(_errors)..remove('password'));
              },
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
            Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    key: const Key('register_terms'),
                    value: _agreeToTerms,
                    onChanged: (val) {
                      if (val != null) setState(() {
                        _agreeToTerms = val;
                        if (val) _termsError = null;
                      });
                    },
                    activeColor: scheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'I agree to the Terms & Privacy Policy',
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      if (_termsError != null)
                        Text(
                          _termsError!,
                          style: textTheme.bodySmall?.copyWith(
                            color: scheme.error,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: tokens.spaceLg),
            SakaiTactile(
              onTap: registerState.busy ? null : _onRegister,
              child: IgnorePointer(
                child: SakaiPrimaryButton(
                  key: const Key('register_submit'),
                  label: registerState.busy
                      ? 'Creating Account…'
                      : 'Sign Up',
                  icon: Icons.person_add_rounded,
                  onPressed: registerState.busy ? null : () {},
                ),
              ),
            ),
            SizedBox(height: tokens.spaceXl),
            Row(
              children: [
                Expanded(child: Divider(color: scheme.outlineVariant.withValues(alpha: 0.5))),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: tokens.spaceMd),
                  child: Text(
                    'Or continue with',
                    style: textTheme.labelLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: scheme.outlineVariant.withValues(alpha: 0.5))),
              ],
            ),
            SizedBox(height: tokens.spaceLg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.g_mobiledata_rounded, size: 28, color: scheme.onSurface),
                    label: Text('Google', style: TextStyle(color: scheme.onSurface)),
                    onPressed: registerState.busy
                        ? null
                        : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Google Sign-In coming soon'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: tokens.spaceMd),
                      side: BorderSide(color: scheme.outlineVariant),
                      backgroundColor: scheme.surface,
                    ),
                  ),
                ),
                SizedBox(width: tokens.spaceMd),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.apple_rounded, size: 22, color: scheme.onSurface),
                    label: Text('Apple', style: TextStyle(color: scheme.onSurface)),
                    onPressed: registerState.busy
                        ? null
                        : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Apple Sign-In coming soon'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: tokens.spaceMd),
                      side: BorderSide(color: scheme.outlineVariant),
                      backgroundColor: scheme.surface,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: tokens.spaceXl),
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
              style: TextButton.styleFrom(
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
              child: const Text('Sign in'),
            ),
          ],
        ),
      ],
    );
  }
}

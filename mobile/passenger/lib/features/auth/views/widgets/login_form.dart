import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _obscurePassword = true;
  bool _rememberMe = true;
  Map<String, String> _errors = {};

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  bool _validate() {
    final errors = <String, String>{};
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (email.isEmpty) {
      errors['email'] = 'Email is required';
    } else if (!RegExp(r'^[\w.+\-]+@[\w\-]+\.[a-zA-Z]{2,}$').hasMatch(email)) {
      errors['email'] = 'Enter a valid email address';
    }

    if (password.isEmpty) {
      errors['password'] = 'Password is required';
    }

    setState(() => _errors = errors);
    return errors.isEmpty;
  }

  Future<void> _onSignIn() async {
    if (!_validate()) {
      HapticFeedback.heavyImpact();
      return;
    }
    HapticFeedback.mediumImpact();
    FocusScope.of(context).unfocus();
    await ref
        .read(loginNotifierProvider.notifier)
        .signIn(email: _emailCtrl.text.trim(), password: _passwordCtrl.text);
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Welcome back!',
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: scheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: tokens.spaceSm),
            Text(
              'Your next ride is one tap away.',
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: tokens.spaceXl),
            SakaiTextField(
              key: const Key('login_email'),
              controller: _emailCtrl,
              focusNode: _emailFocus,
              autofocus: true,
              label: 'Email address',
              hint: 'you@example.com',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _passwordFocus.requestFocus(),
              prefixIcon: const Icon(Icons.mail_outline_rounded),
              errorText: _errors['email'],
              onChanged: (_) {
                ref.read(loginNotifierProvider.notifier).clearError();
                if (_errors.containsKey('email')) {
                  setState(() => _errors = Map.from(_errors)..remove('email'));
                }
              },
            ),
            SakaiTextField(
              key: const Key('login_password'),
              controller: _passwordCtrl,
              focusNode: _passwordFocus,
              label: 'Password',
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _onSignIn(),
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              errorText: _errors['password'],
              onChanged: (_) {
                ref.read(loginNotifierProvider.notifier).clearError();
                if (_errors.containsKey('password')) {
                  setState(
                    () => _errors = Map.from(_errors)..remove('password'),
                  );
                }
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: tokens.iconMd,
                      height: tokens.iconMd,
                      child: Checkbox(
                        value: _rememberMe,
                        onChanged: (val) {
                          if (val != null) {
                            HapticFeedback.lightImpact();
                            setState(() => _rememberMe = val);
                          }
                        },
                        activeColor: scheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    SizedBox(width: tokens.spaceSm),
                    Text(
                      'Remember me',
                      style: textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Forgot Password?',
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: tokens.spaceMd),
            SakaiTactile(
              key: const Key('login_submit'),
              onTap: loginState.busy ? null : _onSignIn,
              child: IgnorePointer(
                child: SakaiPrimaryButton(
                  label: loginState.busy ? 'Signing in…' : 'Sign in',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: loginState.busy ? null : () {},
                ),
              ),
            ),
            SizedBox(height: tokens.spaceXl),
            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: scheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
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
                Expanded(
                  child: Divider(
                    color: scheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
            SizedBox(height: tokens.spaceLg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(
                      Icons.g_mobiledata_rounded,
                      size: 28,
                      color: scheme.onSurface,
                    ),
                    label: Text(
                      'Google',
                      style: textTheme.labelLarge?.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                    onPressed: loginState.busy
                        ? null
                        : () => ref
                              .read(loginNotifierProvider.notifier)
                              .signInWithGoogle(),
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
                    icon: Icon(
                      Icons.apple_rounded,
                      size: 22,
                      color: scheme.onSurface,
                    ),
                    label: Text(
                      'Apple',
                      style: textTheme.labelLarge?.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                    onPressed: loginState.busy ? null : () {},
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
              'New rider?',
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            TextButton(
              onPressed: loginState.busy ? null : widget.onRegisterTap,
              style: TextButton.styleFrom(
                textStyle: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: const Text('Create account'),
            ),
          ],
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../../home/views/rider_home_screen.dart';
import '../../ride/repositories/ride_repository.dart';
import '../repositories/auth_repository.dart';
import '../view_models/login_view_model.dart';
import 'register_screen.dart';

/// Rider sign-in — layout inspired by modern mobility / Stitch-style mobile auth.
class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.authRepository,
    required this.rideRepository,
  });

  final AuthRepository authRepository;
  final RideRepository rideRepository;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final LoginViewModel _viewModel;
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _viewModel = LoginViewModel(widget.authRepository);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSignIn() async {
    FocusScope.of(context).unfocus();
    final session = await _viewModel.signIn(
      email: _emailCtrl.text,
      password: _passwordCtrl.text,
    );
    if (!mounted || session == null) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (context) => RiderHomeScreen(
          session: session,
          rideRepository: widget.rideRepository,
          onSignOut: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(
                builder: (context) => LoginScreen(
                  authRepository: widget.authRepository,
                  rideRepository: widget.rideRepository,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final tokens = SakaiDesignTokens.of(context);

    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: tokens.spaceLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: tokens.spaceXl),
                  _BrandHeader(colorScheme: scheme, textTheme: textTheme),
                  SizedBox(height: tokens.spaceXl),
                  if (_viewModel.errorMessage != null)
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
                                  _viewModel.errorMessage!,
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
                  SakaiSurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Sign in',
                          style: textTheme.titleLarge,
                        ),
                        SizedBox(height: tokens.spaceXs),
                        Text(
                          'Use the email and password for your rider account.',
                          style: textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
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
                          onChanged: (_) => _viewModel.clearError(),
                        ),
                        SakaiTextField(
                          key: const Key('login_password'),
                          controller: _passwordCtrl,
                          label: 'Password',
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          prefixIcon: const Icon(Icons.lock_outline),
                          onChanged: (_) => _viewModel.clearError(),
                          suffixIcon: IconButton(
                            tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(() => _obscurePassword = !_obscurePassword);
                            },
                          ),
                        ),
                        SizedBox(height: tokens.spaceSm),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _viewModel.busy
                                ? null
                                : () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Password reset is not wired yet.'),
                                      ),
                                    );
                                  },
                            child: const Text('Forgot password?'),
                          ),
                        ),
                        SakaiPrimaryButton(
                          label: _viewModel.busy ? 'Signing in…' : 'Sign in',
                          icon: Icons.login,
                          onPressed: _viewModel.busy ? null : _onSignIn,
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
                        onPressed: _viewModel.busy
                            ? null
                            : () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute<void>(
                                    builder: (_) => RegisterScreen(
                                      authRepository: widget.authRepository,
                                      rideRepository: widget.rideRepository,
                                    ),
                                  ),
                                );
                              },
                        child: const Text('Create account'),
                      ),
                    ],
                  ),
                  SizedBox(height: tokens.spaceLg),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({
    required this.colorScheme,
    required this.textTheme,
  });

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
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
            const SizedBox(width: 14),
            Text(
              'SakAI',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
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

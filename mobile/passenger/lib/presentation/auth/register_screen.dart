import 'package:flutter/material.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../../domain/auth_repository.dart';
import '../home/rider_home_screen.dart';
import 'login_screen.dart';
import 'register_view_model.dart';

/// Rider create account screen
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.authRepository});

  final AuthRepository authRepository;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late final RegisterViewModel _viewModel;
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _viewModel = RegisterViewModel(widget.authRepository);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    FocusScope.of(context).unfocus();
    final session = await _viewModel.register(
      name: _nameCtrl.text,
      email: _emailCtrl.text,
      password: _passwordCtrl.text,
    );
    if (!mounted || session == null) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (context) => RiderHomeScreen(
          session: session,
          onSignOut: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(
                builder: (context) => LoginScreen(
                  authRepository: widget.authRepository,
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
      appBar: AppBar(
        title: const Text('Create Account'),
        leading: BackButton(
          onPressed: _viewModel.busy
              ? null
              : () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => LoginScreen(
                        authRepository: widget.authRepository,
                      ),
                    ),
                  ),
        ),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: tokens.spaceLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: tokens.spaceLg),
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
                          'Join SakAI',
                          style: textTheme.titleLarge,
                        ),
                        SizedBox(height: tokens.spaceXs),
                        Text(
                          'Book rides and track drivers in real time.',
                          style: textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: tokens.spaceLg),
                        SakaiTextField(
                          key: const Key('register_name'),
                          controller: _nameCtrl,
                          label: 'Full Name',
                          hint: 'Jane Doe',
                          textInputAction: TextInputAction.next,
                          prefixIcon: const Icon(Icons.person_outline),
                          onChanged: (_) => _viewModel.clearError(),
                        ),
                        SakaiTextField(
                          key: const Key('register_email'),
                          controller: _emailCtrl,
                          label: 'Email',
                          hint: 'you@example.com',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          prefixIcon: const Icon(Icons.mail_outline),
                          onChanged: (_) => _viewModel.clearError(),
                        ),
                        SakaiTextField(
                          key: const Key('register_password'),
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
                        SizedBox(height: tokens.spaceLg),
                        SakaiPrimaryButton(
                          label: _viewModel.busy ? 'Creating Account…' : 'Create Account',
                          icon: Icons.person_add_outlined,
                          onPressed: _viewModel.busy ? null : _onRegister,
                        ),
                      ],
                    ),
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

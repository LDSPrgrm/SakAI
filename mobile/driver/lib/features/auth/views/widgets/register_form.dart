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
  final _confirmCtrl = TextEditingController();

  final _makeCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _plateCtrl = TextEditingController();
  final _colorCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  int _currentStep = 0;
  Map<String, String> _errors = {};
  String? _termsError;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _makeCtrl.dispose();
    _modelCtrl.dispose();
    _plateCtrl.dispose();
    _colorCtrl.dispose();
    _yearCtrl.dispose();
    super.dispose();
  }

  // Validates personal info before advancing to step 2
  bool _validateStep1() {
    final errors = <String, String>{};
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    final confirm = _confirmCtrl.text;

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

    if (confirm.isEmpty) {
      errors['confirmPassword'] = 'Please confirm your password';
    } else if (confirm != password) {
      errors['confirmPassword'] = 'Passwords do not match';
    }

    setState(() => _errors = errors);
    return errors.isEmpty;
  }

  // Validates vehicle info before final submit
  bool _validateStep2() {
    final errors = <String, String>{};

    if (_makeCtrl.text.trim().isEmpty) errors['vehicleMake'] = 'Vehicle make is required';
    if (_modelCtrl.text.trim().isEmpty) errors['vehicleModel'] = 'Vehicle model is required';
    if (_plateCtrl.text.trim().isEmpty) errors['vehiclePlate'] = 'Plate number is required';
    if (_colorCtrl.text.trim().isEmpty) errors['vehicleColor'] = 'Color is required';

    String? termsError;
    if (!_agreeToTerms) termsError = 'You must agree to the Terms & Privacy Policy';

    setState(() {
      _errors = errors;
      _termsError = termsError;
    });
    return errors.isEmpty && termsError == null;
  }

  Future<void> _onRegister() async {
    if (!_validateStep2()) {
      HapticFeedback.heavyImpact();
      return;
    }
    FocusScope.of(context).unfocus();
    await ref
        .read(registerNotifierProvider.notifier)
        .signUp(
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          confirmPassword: _confirmCtrl.text,
          vehicleMake: _makeCtrl.text.trim(),
          vehicleModel: _modelCtrl.text.trim(),
          vehiclePlate: _plateCtrl.text.trim(),
          vehicleColor: _colorCtrl.text.trim(),
          vehicleYear: _yearCtrl.text.trim(),
        );
  }

  String? _fieldError(String key, RegisterState state) {
    return state.fieldErrors[key];
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
              'Create Account',
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: scheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: tokens.spaceSm),
            Text(
              'Become a SakAI driver and earn on your schedule.',
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: tokens.spaceXl),
            if (_currentStep == 0) ...[
              Text(
                'Personal Info',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.primary,
                ),
              ),
              SizedBox(height: tokens.spaceMd),
              SakaiTextField(
                key: const Key('register_name'),
                controller: _nameCtrl,
                label: 'Full Name',
                hint: 'John Doe',
                errorText: _errors['name'] ?? _fieldError('name', registerState),
                textInputAction: TextInputAction.next,
                prefixIcon: const Icon(Icons.person_outline),
                enabled: !registerState.busy,
                onChanged: (_) {
                  ref.read(registerNotifierProvider.notifier).clearError();
                  if (_errors.containsKey('name')) setState(() => _errors = Map.from(_errors)..remove('name'));
                },
              ),
              SakaiTextField(
                key: const Key('register_email'),
                controller: _emailCtrl,
                label: 'Email',
                hint: 'name@example.com',
                errorText: _errors['email'] ?? _fieldError('email', registerState),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                prefixIcon: const Icon(Icons.mail_outline),
                enabled: !registerState.busy,
                onChanged: (_) {
                  ref.read(registerNotifierProvider.notifier).clearError();
                  if (_errors.containsKey('email')) setState(() => _errors = Map.from(_errors)..remove('email'));
                },
              ),
              SakaiTextField(
                key: const Key('register_password'),
                controller: _passwordCtrl,
                label: 'Password',
                errorText: _errors['password'] ?? _fieldError('password', registerState),
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.next,
                prefixIcon: const Icon(Icons.lock_outline),
                enabled: !registerState.busy,
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
              SakaiTextField(
                key: const Key('register_confirm'),
                controller: _confirmCtrl,
                label: 'Confirm Password',
                errorText: _errors['confirmPassword'] ?? _fieldError('confirmPassword', registerState),
                obscureText: _obscureConfirmPassword,
                textInputAction: TextInputAction.next,
                prefixIcon: const Icon(Icons.lock_outline),
                enabled: !registerState.busy,
                onChanged: (_) {
                  ref.read(registerNotifierProvider.notifier).clearError();
                  if (_errors.containsKey('confirmPassword')) setState(() => _errors = Map.from(_errors)..remove('confirmPassword'));
                },
                suffixIcon: IconButton(
                  tooltip: _obscureConfirmPassword ? 'Show password' : 'Hide password',
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () =>
                      setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
              ),
              SizedBox(height: tokens.spaceLg),
              SakaiPrimaryButton(
                label: 'Next: Vehicle Info',
                icon: Icons.arrow_forward_rounded,
                onPressed: () {
                  if (!_validateStep1()) {
                    HapticFeedback.heavyImpact();
                    return;
                  }
                  FocusScope.of(context).unfocus();
                  setState(() => _currentStep = 1);
                },
              ),
            ],
            if (_currentStep == 1) ...[
              SizedBox(height: tokens.spaceMd),
            Text(
              'Vehicle Info',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.primary,
              ),
            ),
              SizedBox(height: tokens.spaceMd),
              DropdownButtonFormField<RegVehicleType>(
                key: const Key('register_vehicle_type'),
                initialValue: registerState.selectedVehicleType,
                decoration: InputDecoration(
                  labelText: 'Vehicle Type',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: tokens.spaceMd,
                    vertical: tokens.spaceSm,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(tokens.radiusMd),
                    borderSide: BorderSide(
                      color: scheme.outline.withValues(alpha: 0.5),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(tokens.radiusMd),
                    borderSide: BorderSide(
                      color: scheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  prefixIcon: const Icon(Icons.directions_car_outlined),
                ),
                dropdownColor: scheme.surface,
                items: RegVehicleType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.displayName),
                  );
                }).toList(),
                onChanged: registerState.busy
                    ? null
                    : (value) {
                        if (value != null) {
                          ref
                              .read(registerNotifierProvider.notifier)
                              .setVehicleType(value);
                        }
                      },
              ),
              SizedBox(height: tokens.spaceMd),
              Row(
                children: [
                  Expanded(
                    child: SakaiTextField(
                      key: const Key('register_make'),
                      controller: _makeCtrl,
                      label: 'Make',
                      hint: 'Toyota',
                      errorText: _fieldError('vehicleMake', registerState),
                      textInputAction: TextInputAction.next,
                      enabled: !registerState.busy,
                      onChanged: (_) =>
                          ref.read(registerNotifierProvider.notifier).clearError(),
                    ),
                  ),
                  SizedBox(width: tokens.spaceMd),
                  Expanded(
                    child: SakaiTextField(
                      key: const Key('register_model'),
                      controller: _modelCtrl,
                      label: 'Model',
                      hint: 'Vios',
                      errorText: _fieldError('vehicleModel', registerState),
                      textInputAction: TextInputAction.next,
                      enabled: !registerState.busy,
                      onChanged: (_) =>
                          ref.read(registerNotifierProvider.notifier).clearError(),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: SakaiTextField(
                      key: const Key('register_plate'),
                      controller: _plateCtrl,
                      label: 'Plate Number',
                      hint: 'ABC 1234',
                      errorText: _fieldError('vehiclePlate', registerState),
                      textInputAction: TextInputAction.next,
                      enabled: !registerState.busy,
                      onChanged: (_) =>
                          ref.read(registerNotifierProvider.notifier).clearError(),
                    ),
                  ),
                  SizedBox(width: tokens.spaceMd),
                  Expanded(
                    child: SakaiTextField(
                      key: const Key('register_color'),
                      controller: _colorCtrl,
                      label: 'Color',
                      hint: 'Silver',
                      errorText: _fieldError('vehicleColor', registerState),
                      textInputAction: TextInputAction.next,
                      enabled: !registerState.busy,
                      onChanged: (_) =>
                          ref.read(registerNotifierProvider.notifier).clearError(),
                    ),
                  ),
                ],
              ),
              SizedBox(height: tokens.spaceMd),
              SakaiTextField(
                key: const Key('register_year'),
                controller: _yearCtrl,
                label: 'Year',
                hint: '2020',
                errorText: _fieldError('vehicleYear', registerState),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                enabled: !registerState.busy,
                prefixIcon: const Icon(Icons.calendar_today_outlined),
                onChanged: (_) =>
                    ref.read(registerNotifierProvider.notifier).clearError(),
              ),
              SizedBox(height: tokens.spaceLg),
            Row(
              children: [
                SizedBox(
                  width: tokens.iconMd,
                  height: tokens.iconMd,
                  child: Checkbox(
                    value: _agreeToTerms,
                    onChanged: (val) {
                      if (val != null) setState(() => _agreeToTerms = val);
                    },
                    activeColor: scheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                SizedBox(width: tokens.spaceSm),
                Expanded(
                  child: Text(
                    'I agree to the Terms & Privacy Policy',
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            if (_termsError != null)
              Padding(
                padding: EdgeInsets.only(
                  top: tokens.spaceSm,
                  left: tokens.iconMd + tokens.spaceSm,
                ),
                child: Text(
                  _termsError!,
                  style: textTheme.bodySmall?.copyWith(color: scheme.error),
                ),
              ),
            SizedBox(height: tokens.spaceLg),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      setState(() => _currentStep = 0);
                    },
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Back'),
                    style: TextButton.styleFrom(
                      foregroundColor: scheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(width: tokens.spaceSm),
                  Expanded(
                    child: SakaiPrimaryButton(
                      key: const Key('register_submit'),
                      label: registerState.busy
                          ? 'Creating Account…'
                          : 'Sign Up',
                      icon: Icons.person_add_rounded,
                      onPressed: registerState.busy ? null : _onRegister,
                    ),
                  ),
                ],
              ),
            ],
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
                textStyle: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: const Text('Sign in'),
            ),
          ],
        ),
      ],
    );
  }
}

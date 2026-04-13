import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../../../app/router.dart';
import '../view_models/register_notifier.dart';

/// Driver registration screen with personal and vehicle info fields.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  // Vehicle fields
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _plateController = TextEditingController();
  final _colorController = TextEditingController();
  final _yearController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _plateController.dispose();
    _colorController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _onRegister() {
    ref
        .read(registerNotifierProvider.notifier)
        .signUp(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          confirmPassword: _confirmController.text,
          vehicleMake: _makeController.text,
          vehicleModel: _modelController.text,
          vehiclePlate: _plateController.text,
          vehicleColor: _colorController.text,
          vehicleYear: _yearController.text,
        );
  }

  String? _fieldError(String key) {
    final state = ref.watch(registerNotifierProvider);
    return state.fieldErrors[key];
  }

  @override
  Widget build(BuildContext context) {
    final t = SakaiDesignTokens.of(context);
    final scheme = Theme.of(context).colorScheme;
    final state = ref.watch(registerNotifierProvider);

    ref.listen<RegisterState>(registerNotifierProvider, (previous, next) {
      if (next.succeeded && !(previous?.succeeded ?? false)) {
        context.go(Routes.home);
      }
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: scheme.error,
          ),
        );
        ref.read(registerNotifierProvider.notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: t.spaceXl,
            vertical: t.spaceLg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Join SakAI Drivers',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: t.spaceXs),
              Text(
                'Create an account to start earning',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
              ),
              SizedBox(height: t.spaceXl * 2),

              SakaiGlassCard(
                child: Padding(
                  padding: EdgeInsets.all(t.spaceLg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Personal Info',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: t.spaceLg),
                      SakaiTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        hint: 'John Doe',
                        prefixIcon: const Icon(Icons.person_outline),
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        enabled: !state.busy,
                        errorText: _fieldError('name'),
                      ),
                      SizedBox(height: t.spaceMd),
                      SakaiTextField(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'name@example.com',
                        prefixIcon: const Icon(Icons.email_outlined),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        enabled: !state.busy,
                        errorText: _fieldError('email'),
                      ),
                      SizedBox(height: t.spaceMd),
                      SakaiTextField(
                        controller: _passwordController,
                        label: 'Password',
                        hint: '••••••••',
                        prefixIcon: const Icon(Icons.lock_outline),
                        obscureText: true,
                        textInputAction: TextInputAction.next,
                        enabled: !state.busy,
                        errorText: _fieldError('password'),
                      ),
                      SizedBox(height: t.spaceMd),
                      SakaiTextField(
                        controller: _confirmController,
                        label: 'Confirm Password',
                        hint: '••••••••',
                        prefixIcon: const Icon(Icons.lock_outline),
                        obscureText: true,
                        textInputAction: TextInputAction.next,
                        enabled: !state.busy,
                        errorText: _fieldError('confirmPassword'),
                      ),
                      SizedBox(height: t.spaceXl * 2),

                      Text(
                        'Vehicle Info',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: t.spaceLg),

                      // Vehicle Type Dropdown
                      DropdownButtonFormField<RegVehicleType>(
                        value: state.selectedVehicleType,
                        decoration: InputDecoration(
                          labelText: 'Vehicle Type',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.directions_car),
                        ),
                        items: RegVehicleType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type.displayName),
                          );
                        }).toList(),
                        onChanged: state.busy
                            ? null
                            : (value) {
                                if (value != null) {
                                  ref
                                      .read(registerNotifierProvider.notifier)
                                      .setVehicleType(value);
                                }
                              },
                      ),
                      SizedBox(height: t.spaceMd),

                      Row(
                        children: [
                          Expanded(
                            child: SakaiTextField(
                              controller: _makeController,
                              label: 'Make',
                              hint: 'Toyota',
                              textInputAction: TextInputAction.next,
                              enabled: !state.busy,
                              errorText: _fieldError('vehicleMake'),
                            ),
                          ),
                          SizedBox(width: t.spaceMd),
                          Expanded(
                            child: SakaiTextField(
                              controller: _modelController,
                              label: 'Model',
                              hint: 'Vios',
                              textInputAction: TextInputAction.next,
                              enabled: !state.busy,
                              errorText: _fieldError('vehicleModel'),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: t.spaceMd),
                      Row(
                        children: [
                          Expanded(
                            child: SakaiTextField(
                              controller: _plateController,
                              label: 'Plate Number',
                              hint: 'ABC 1234',
                              textInputAction: TextInputAction.next,
                              enabled: !state.busy,
                              errorText: _fieldError('vehiclePlate'),
                            ),
                          ),
                          SizedBox(width: t.spaceMd),
                          Expanded(
                            child: SakaiTextField(
                              controller: _colorController,
                              label: 'Color',
                              hint: 'Silver',
                              textInputAction: TextInputAction.next,
                              enabled: !state.busy,
                              errorText: _fieldError('vehicleColor'),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: t.spaceMd),
                      SakaiTextField(
                        controller: _yearController,
                        label: 'Year',
                        hint: '2020',
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        enabled: !state.busy,
                        errorText: _fieldError('vehicleYear'),
                      ),

                      SizedBox(height: t.spaceXl),
                      SakaiPrimaryButton(
                        label: state.busy ? 'Registering…' : 'Register',
                        icon: Icons.person_add,
                        onPressed: state.busy ? null : _onRegister,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: t.spaceXl * 2),
            ],
          ),
        ),
      ),
    );
  }
}

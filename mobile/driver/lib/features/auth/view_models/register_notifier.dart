import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../models/auth_exception.dart';
import '../repositories/driver_auth_repository.dart';
import '../../../app/providers.dart';

/// Vehicle type options for driver registration.
/// Uses a unique name to avoid collision with VehicleType from sakai_shared.
enum RegVehicleType { motorcycle, car, tricycle }

extension RegVehicleTypeExt on RegVehicleType {
  String get displayName {
    switch (this) {
      case RegVehicleType.motorcycle:
        return 'Motorcycle';
      case RegVehicleType.car:
        return 'Car';
      case RegVehicleType.tricycle:
        return 'Tricycle';
    }
  }

  String get apiValue {
    switch (this) {
      case RegVehicleType.motorcycle:
        return 'motorcycle';
      case RegVehicleType.car:
        return 'car';
      case RegVehicleType.tricycle:
        return 'tricycle';
    }
  }
}

class RegisterState {
  const RegisterState({
    this.busy = false,
    this.errorMessage,
    this.succeeded = false,
    this.fieldErrors = const {},
    this.selectedVehicleType = RegVehicleType.car,
  });

  final bool busy;
  final String? errorMessage;
  final bool succeeded;
  final Map<String, String> fieldErrors;
  final RegVehicleType selectedVehicleType;

  RegisterState copyWith({
    bool? busy,
    String? errorMessage,
    bool? succeeded,
    Map<String, String>? fieldErrors,
    RegVehicleType? selectedVehicleType,
  }) {
    return RegisterState(
      busy: busy ?? this.busy,
      errorMessage: errorMessage,
      succeeded: succeeded ?? this.succeeded,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      selectedVehicleType: selectedVehicleType ?? this.selectedVehicleType,
    );
  }
}

class RegisterNotifier extends Notifier<RegisterState> {
  @override
  RegisterState build() => const RegisterState();

  DriverAuthRepository get _authRepo => ref.read(authRepositoryProvider);

  void setVehicleType(RegVehicleType type) {
    state = state.copyWith(selectedVehicleType: type);
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required String vehicleMake,
    required String vehicleModel,
    required String vehiclePlate,
    required String vehicleColor,
  }) async {
    final errors = _validate(
      name.trim(),
      email.trim(),
      password,
      confirmPassword,
      vehicleMake.trim(),
      vehicleModel.trim(),
      vehiclePlate.trim(),
      vehicleColor.trim(),
    );
    if (errors.isNotEmpty) {
      state = RegisterState(
        fieldErrors: errors,
        selectedVehicleType: state.selectedVehicleType,
      );
      return;
    }

    state = RegisterState(
      busy: true,
      selectedVehicleType: state.selectedVehicleType,
    );

    try {
      final session = await _authRepo.registerDriver(
        name: name.trim(),
        email: email.trim(),
        password: password,
        vehicleMake: vehicleMake.trim(),
        vehicleModel: vehicleModel.trim(),
        vehiclePlate: vehiclePlate.trim(),
        vehicleColor: vehicleColor.trim(),
        vehicleType: state.selectedVehicleType.apiValue,
      );
      await ref
          .read(tokenStorageProvider)
          .save(
            accessToken: session.accessToken,
            refreshToken: session.refreshToken,
            expiresAt: session.accessTokenExpiresAt,
          );
      ref.read(authStateProvider.notifier).markAuthenticated();
      state = const RegisterState(succeeded: true);
    } on AuthException catch (e) {
      state = RegisterState(
        errorMessage: e.userMessage,
        selectedVehicleType: state.selectedVehicleType,
      );
    }
  }

  void clearError() {
    if (state.errorMessage != null || state.fieldErrors.isNotEmpty) {
      state = RegisterState(selectedVehicleType: state.selectedVehicleType);
    }
  }

  Map<String, String> _validate(
    String name,
    String email,
    String password,
    String confirmPassword,
    String vehicleMake,
    String vehicleModel,
    String vehiclePlate,
    String vehicleColor,
  ) {
    final errors = <String, String>{};
    if (name.isEmpty) errors['name'] = 'Enter your name';
    if (name.length > 100) errors['name'] = 'Name must be under 100 characters';
    if (email.isEmpty) errors['email'] = 'Enter your email';
    if (email.isNotEmpty && !email.contains('@')) {
      errors['email'] = 'Enter a valid email';
    }
    if (password.isEmpty) errors['password'] = 'Enter a password';
    if (password.isNotEmpty && password.length < 8) {
      errors['password'] = 'Password must be at least 8 characters';
    }
    if (password != confirmPassword) {
      errors['confirmPassword'] = 'Passwords do not match';
    }
    if (vehicleMake.isEmpty) errors['vehicleMake'] = 'Enter vehicle make';
    if (vehicleModel.isEmpty) errors['vehicleModel'] = 'Enter vehicle model';
    if (vehiclePlate.isEmpty) errors['vehiclePlate'] = 'Enter vehicle plate';
    if (vehicleColor.isEmpty) errors['vehicleColor'] = 'Enter vehicle color';
    return errors;
  }
}

final registerNotifierProvider =
    NotifierProvider<RegisterNotifier, RegisterState>(RegisterNotifier.new);

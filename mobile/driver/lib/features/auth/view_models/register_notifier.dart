import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/auth_exception.dart';
import '../../../app/providers.dart';

class RegisterState {
  const RegisterState({
    this.busy = false,
    this.errorMessage,
    this.succeeded = false,
  });

  final bool busy;
  final String? errorMessage;
  final bool succeeded;

  RegisterState copyWith({bool? busy, String? errorMessage, bool? succeeded}) {
    return RegisterState(
      busy: busy ?? this.busy,
      errorMessage: errorMessage,
      succeeded: succeeded ?? this.succeeded,
    );
  }
}

class RegisterNotifier extends Notifier<RegisterState> {
  @override
  RegisterState build() => const RegisterState();

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required String vehicleMake,
    required String vehicleModel,
    required String vehiclePlate,
    required String vehicleColor,
    required String vehicleYear,
  }) async {
    final tName = name.trim();
    final tEmail = email.trim();
    final tMake = vehicleMake.trim();
    final tModel = vehicleModel.trim();
    final tPlate = vehiclePlate.trim();
    final tColor = vehicleColor.trim();

    if (tName.isEmpty ||
        tEmail.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        tMake.isEmpty ||
        tModel.isEmpty ||
        tPlate.isEmpty ||
        tColor.isEmpty ||
        vehicleYear.trim().isEmpty) {
      state = const RegisterState(errorMessage: 'Please fill in all fields');
      return;
    }
    if (password != confirmPassword) {
      state = const RegisterState(errorMessage: 'Passwords do not match');
      return;
    }
    final yearInt = int.tryParse(vehicleYear.trim());
    if (yearInt == null ||
        yearInt < 1990 ||
        yearInt > DateTime.now().year + 1) {
      state = const RegisterState(errorMessage: 'Valid vehicle year required');
      return;
    }

    state = const RegisterState(busy: true);
    try {
      await ref
          .read(authRepositoryProvider)
          .registerDriver(
            name: tName,
            email: tEmail,
            password: password,
            vehicleMake: tMake,
            vehicleModel: tModel,
            vehiclePlate: tPlate,
            vehicleColor: tColor,
            vehicleYear: yearInt,
          );
      state = const RegisterState(succeeded: true);
    } on AuthException catch (e) {
      state = RegisterState(errorMessage: e.userMessage);
    }
  }

  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }
  }
}

final registerNotifierProvider =
    NotifierProvider<RegisterNotifier, RegisterState>(RegisterNotifier.new);

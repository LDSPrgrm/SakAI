import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/auth_exception.dart';
import '../repositories/auth_repository.dart';
import '../../../app/providers.dart';

class RegisterState {
  const RegisterState({
    this.busy = false,
    this.errorMessage,
    this.succeeded = false,
    this.fieldErrors = const {},
  });

  final bool busy;
  final String? errorMessage;
  final bool succeeded;
  final Map<String, String> fieldErrors;

  RegisterState copyWith({
    bool? busy,
    String? errorMessage,
    bool? succeeded,
    Map<String, String>? fieldErrors,
  }) {
    return RegisterState(
      busy: busy ?? this.busy,
      errorMessage: errorMessage,
      succeeded: succeeded ?? this.succeeded,
      fieldErrors: fieldErrors ?? this.fieldErrors,
    );
  }
}

class RegisterNotifier extends Notifier<RegisterState> {
  @override
  RegisterState build() => const RegisterState();

  AuthRepository get _authRepo => ref.read(authRepositoryProvider);

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final errors = _validate(name.trim(), email.trim(), password);
    if (errors.isNotEmpty) {
      state = RegisterState(fieldErrors: errors);
      return;
    }

    state = const RegisterState(busy: true);

    try {
      await _authRepo.register(
        name: name.trim(),
        email: email.trim(),
        password: password,
      );
      state = const RegisterState(succeeded: true);
    } on AuthException catch (e) {
      state = RegisterState(errorMessage: e.userMessage);
    }
  }

  void clearError() {
    if (state.errorMessage != null || state.fieldErrors.isNotEmpty) {
      state = const RegisterState();
    }
  }

  Map<String, String> _validate(String name, String email, String password) {
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
    return errors;
  }
}

final registerNotifierProvider =
    NotifierProvider<RegisterNotifier, RegisterState>(RegisterNotifier.new);

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/auth_exception.dart';
import '../../../app/providers.dart';

class LoginState {
  const LoginState({
    this.busy = false,
    this.errorMessage,
    this.succeeded = false,
  });

  final bool busy;
  final String? errorMessage;
  final bool succeeded;

  LoginState copyWith({bool? busy, String? errorMessage, bool? succeeded}) {
    return LoginState(
      busy: busy ?? this.busy,
      errorMessage: errorMessage,
      succeeded: succeeded ?? this.succeeded,
    );
  }
}

class LoginNotifier extends Notifier<LoginState> {
  @override
  LoginState build() => const LoginState();

  Future<void> signIn({required String email, required String password}) async {
    final trimmed = email.trim();
    if (trimmed.isEmpty) {
      state = const LoginState(errorMessage: 'Enter your email');
      return;
    }
    if (password.isEmpty) {
      state = const LoginState(errorMessage: 'Enter your password');
      return;
    }
    state = const LoginState(busy: true);
    try {
      await ref
          .read(authRepositoryProvider)
          .login(email: trimmed, password: password);
      state = const LoginState(succeeded: true);
    } on AuthException catch (e) {
      state = LoginState(errorMessage: e.userMessage);
    }
  }

  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }
  }
}

final loginNotifierProvider = NotifierProvider<LoginNotifier, LoginState>(
  LoginNotifier.new,
);

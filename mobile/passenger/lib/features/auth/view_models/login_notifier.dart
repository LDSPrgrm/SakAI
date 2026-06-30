import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../models/auth_exception.dart';
import '../repositories/auth_repository.dart';
import '../../../app/providers.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

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

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class LoginNotifier extends Notifier<LoginState> {
  @override
  LoginState build() => const LoginState();

  AuthRepository get _authRepo => ref.read(authRepositoryProvider);

  Future<void> signIn({required String email, required String password}) async {
    final trimmed = email.trim();
    debugPrint('[P-Auth] signIn: email=$trimmed');
    final validation = _validate(trimmed, password);
    if (validation != null) {
      debugPrint('[P-Auth] signIn validation failed: $validation');
      state = LoginState(errorMessage: validation);
      return;
    }

    state = const LoginState(busy: true);

    try {
      debugPrint('[P-Auth] calling authRepo.login...');
      final session = await _authRepo.login(email: trimmed, password: password);
      debugPrint('[P-Auth] login succeeded, saving tokens...');
      await ref
          .read(tokenStorageProvider)
          .save(
            accessToken: session.accessToken,
            refreshToken: session.refreshToken,
            expiresAt: session.accessTokenExpiresAt,
          );
      debugPrint('[P-Auth] tokens saved, marking authenticated');
      ref.read(authStateProvider.notifier).markAuthenticated();

      // Connect WebSocket for real-time ride updates.
      debugPrint('[P-Auth] connecting WebSocket...');
      await ref.read(wsConnectionProvider).connectIfAuthenticated();
      debugPrint('[P-Auth] WebSocket connected, signIn complete');

      state = const LoginState(succeeded: true);
    } on AuthException catch (e) {
      debugPrint('[P-Auth] signIn AuthException: ${e.userMessage}');
      state = LoginState(errorMessage: e.userMessage);
    } catch (e, st) {
      debugPrint('[P-Auth] signIn unexpected error: $e\n$st');
      state = LoginState(errorMessage: 'An unexpected error occurred.');
    }
  }

  Future<void> signInWithGoogle() async {
    debugPrint('[P-Auth] signInWithGoogle called (not yet implemented)');
    state = const LoginState(busy: true);
    try {
      // TODO: implement OAuth Google flow with backend
      await Future.delayed(const Duration(milliseconds: 500));
      state = const LoginState(errorMessage: 'Google Sign-In coming soon');
    } catch (e) {
      debugPrint('[P-Auth] signInWithGoogle error: $e');
      state = LoginState(errorMessage: e.toString());
    }
  }

  Future<void> signInWithPhone() async {
    debugPrint('[P-Auth] signInWithPhone called (not yet implemented)');
    state = const LoginState(busy: true);
    try {
      // TODO: navigate to phone verification screen
      await Future.delayed(const Duration(milliseconds: 300));
      state = const LoginState(errorMessage: 'Phone Sign-In coming soon');
    } catch (e) {
      debugPrint('[P-Auth] signInWithPhone error: $e');
      state = LoginState(errorMessage: e.toString());
    }
  }

  void clearError() {
    if (state.errorMessage != null) {
      debugPrint('[P-Auth] clearError');
      state = state.copyWith(errorMessage: null);
    }
  }

  String? _validate(String email, String password) {
    if (email.isEmpty) return 'Enter your email';
    if (!email.contains('@')) return 'Enter a valid email';
    if (password.isEmpty) return 'Enter your password';
    if (password.length < 6) return 'Password must be at least 6 characters';
    return null;
  }
}

final loginNotifierProvider = NotifierProvider<LoginNotifier, LoginState>(
  LoginNotifier.new,
);

import 'package:flutter/foundation.dart';

import '../models/auth_exception.dart';
import '../models/auth_session.dart';
import '../repositories/auth_repository.dart';

/// MVVM: presentation logic for rider login. View listens via [Listenable].
class LoginViewModel extends ChangeNotifier {
  LoginViewModel(this._authRepository);

  final AuthRepository _authRepository;

  bool _busy = false;
  String? _errorMessage;

  bool get busy => _busy;
  String? get errorMessage => _errorMessage;

  /// Returns [AuthSession] on success; null if validation or API failed (see [errorMessage]).
  Future<AuthSession?> signIn({
    required String email,
    required String password,
  }) async {
    final trimmed = email.trim();
    final validation = _validate(trimmed, password);
    if (validation != null) {
      _errorMessage = validation;
      notifyListeners();
      return null;
    }

    _busy = true;
    _errorMessage = null;
    notifyListeners();

    debugPrint('LoginViewModel: Attempting to sign in user with email: $trimmed');

    try {
      final session = await _authRepository.login(email: trimmed, password: password);
      debugPrint('LoginViewModel: Sign in successful for email: $trimmed');
      return session;
    } on AuthException catch (e) {
      debugPrint('LoginViewModel: Sign in failed for email: $trimmed. Error: ${e.machineCode} - ${e.userMessage}');
      _errorMessage = e.userMessage;
      return null;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
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

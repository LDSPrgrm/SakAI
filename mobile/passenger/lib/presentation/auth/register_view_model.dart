import 'package:flutter/foundation.dart';

import '../../domain/auth_exception.dart';
import '../../domain/auth_repository.dart';
import '../../domain/auth_session.dart';

/// MVVM: presentation logic for rider registration. View listens via [Listenable].
class RegisterViewModel extends ChangeNotifier {
  RegisterViewModel(this._authRepository);

  final AuthRepository _authRepository;

  bool _busy = false;
  String? _errorMessage;

  bool get busy => _busy;
  String? get errorMessage => _errorMessage;

  /// Returns [AuthSession] on success; null if validation or API failed.
  Future<AuthSession?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final trimmedName = name.trim();
    final trimmedEmail = email.trim();
    final validation = _validate(trimmedName, trimmedEmail, password);
    if (validation != null) {
      _errorMessage = validation;
      notifyListeners();
      return null;
    }

    _busy = true;
    _errorMessage = null;
    notifyListeners();

    debugPrint('RegisterViewModel: Attempting to register user with email: $trimmedEmail');

    try {
      final session = await _authRepository.register(
        name: trimmedName,
        email: trimmedEmail,
        password: password,
      );
      debugPrint('RegisterViewModel: Registration successful for email: $trimmedEmail');
      return session;
    } on AuthException catch (e) {
      debugPrint('RegisterViewModel: Registration failed for email: $trimmedEmail. Error: ${e.machineCode} - ${e.userMessage}');
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

  String? _validate(String name, String email, String password) {
    if (name.isEmpty) return 'Enter your name';
    if (name.length < 2) return 'Name must be at least 2 characters';
    if (email.isEmpty) return 'Enter your email';
    if (!email.contains('@')) return 'Enter a valid email';
    if (password.isEmpty) return 'Enter your password';
    if (password.length < 8) return 'Password must be at least 8 characters';
    return null;
  }
}

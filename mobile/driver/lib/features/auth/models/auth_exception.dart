class AuthException implements Exception {
  const AuthException({required this.userMessage});
  final String userMessage;
}

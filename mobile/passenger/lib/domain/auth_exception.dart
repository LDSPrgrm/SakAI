/// Thrown when authentication fails. [machineCode] matches API `ErrorCode` when known.
class AuthException implements Exception {
  AuthException({this.machineCode, required this.userMessage});

  final String? machineCode;
  final String userMessage;

  @override
  String toString() => userMessage;
}

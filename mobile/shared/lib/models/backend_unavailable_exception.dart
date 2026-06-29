/// Thrown by a repository or service when the feature is intentionally not
/// wired to the backend yet (endpoint pending, flag disabled, etc.).
///
/// Distinct from a Dart code-bug signal: callers should catch this typed
/// exception and surface a "Coming soon" empty state instead of a generic
/// error.
class BackendUnavailableException implements Exception {
  const BackendUnavailableException({
    required this.feature,
    this.message,
  });

  /// Short feature key, e.g. `'wallet'`, `'notifications'`, `'otp'`.
  final String feature;

  /// Optional human-readable detail. Falls back to a default message.
  final String? message;

  @override
  String toString() {
    final base = 'Feature "$feature" is awaiting backend support.';
    return message == null ? base : '$base $message';
  }
}

/// Port for one-time-password verification (Clean Architecture: domain boundary).
///
/// Each app supplies a concrete [OtpRepository] via `otpRepositoryProvider`
/// override in its root ProviderScope (see passenger/driver `main.dart`).
abstract class OtpRepository {
  /// Sends a one-time code to [destination] (phone number or email).
  /// Returns an opaque challenge ID the caller echoes back when verifying.
  Future<String> sendCode({required String destination});

  /// Verifies [code] against an earlier [challengeId].
  /// Throws on invalid / expired code.
  Future<void> verify({required String challengeId, required String code});
}

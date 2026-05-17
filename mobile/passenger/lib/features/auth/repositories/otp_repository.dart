/// Port for one-time-password verification (Clean Architecture: domain boundary).
///
/// TODO(backend): No OTP endpoints exist yet in the SakAI OpenAPI spec.
/// Expected contract once added:
///   * `POST /auth/otp/send`   { destination: phone|email } -> { challengeId, expiresAt }
///   * `POST /auth/otp/verify` { challengeId, code }        -> AuthTokenResponse | 400
abstract class OtpRepository {
  /// Sends a one-time code to [destination] (phone number or email).
  /// Returns an opaque challenge ID the caller must echo back when verifying.
  Future<String> sendCode({required String destination});

  /// Verifies [code] against an earlier [challengeId].
  /// Throws on invalid / expired code.
  Future<void> verify({required String challengeId, required String code});
}

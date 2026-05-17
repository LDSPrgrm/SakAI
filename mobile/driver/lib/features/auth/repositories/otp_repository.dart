/// Port for OTP verification on the driver app.
///
/// TODO(backend): No OTP endpoints exist yet (parallel to passenger app).
abstract class OtpRepository {
  Future<String> sendCode({required String destination});
  Future<void> verify({required String challengeId, required String code});
}

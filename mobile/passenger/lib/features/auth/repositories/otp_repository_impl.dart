import 'package:sakai_shared/sakai_shared.dart';

class OtpRepositoryImpl implements OtpRepository {
  OtpRepositoryImpl(this._client);

  // ignore: unused_field — wired for the future endpoint contract.
  final SakaiApiClient _client;

  @override
  Future<String> sendCode({required String destination}) {
    // TODO(backend): wire to POST /auth/otp/send once endpoint exists.
    throw UnimplementedError(
      'OTP send endpoint not implemented on backend yet.',
    );
  }

  @override
  Future<void> verify({required String challengeId, required String code}) {
    // TODO(backend): wire to POST /auth/otp/verify once endpoint exists.
    throw UnimplementedError(
      'OTP verify endpoint not implemented on backend yet.',
    );
  }
}

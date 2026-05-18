import 'package:sakai_shared/sakai_shared.dart';

class OtpRepositoryImpl implements OtpRepository {
  OtpRepositoryImpl(this._client);

  // ignore: unused_field — wired for the future endpoint contract.
  final SakaiApiClient _client;

  @override
  Future<String> sendCode({required String destination}) {
    // TODO(backend): wire to POST /auth/otp/send once endpoint exists.
    throw const BackendUnavailableException(feature: 'otp');
  }

  @override
  Future<void> verify({required String challengeId, required String code}) {
    // TODO(backend): wire to POST /auth/otp/verify once endpoint exists.
    throw const BackendUnavailableException(feature: 'otp');
  }
}

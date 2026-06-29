import 'package:sakai_shared/sakai_shared.dart';

class OtpRepositoryImpl implements OtpRepository {
  OtpRepositoryImpl(this._client);
  // ignore: unused_field
  final SakaiApiClient _client;

  @override
  Future<String> sendCode({required String destination}) {
    throw const BackendUnavailableException(feature: 'otp');
  }

  @override
  Future<void> verify({required String challengeId, required String code}) {
    throw const BackendUnavailableException(feature: 'otp');
  }
}

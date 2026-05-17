import 'package:sakai_shared/sakai_shared.dart';

class OtpRepositoryImpl implements OtpRepository {
  OtpRepositoryImpl(this._client);
  // ignore: unused_field
  final SakaiApiClient _client;

  @override
  Future<String> sendCode({required String destination}) {
    throw UnimplementedError('OTP send endpoint not implemented on backend.');
  }

  @override
  Future<void> verify({required String challengeId, required String code}) {
    throw UnimplementedError('OTP verify endpoint not implemented on backend.');
  }
}

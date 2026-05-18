import 'package:sakai_api_client/sakai_api_client.dart' as api;
import 'package:sakai_shared/repositories/sos_repository.dart';

class SOSRepositoryImpl implements SOSRepository {
  SOSRepositoryImpl(this._ridesApi);
  final api.RidesApi _ridesApi;

  @override
  Future<api.Incident> triggerSOS(String rideId, {String? reason}) async {
    final response = await _ridesApi.rideTriggerSOS(
      rideId: rideId,
      triggerSOSRequest: api.TriggerSOSRequest((b) => b..reason = reason),
    );
    final data = response.data;
    if (data == null) {
      throw Exception('Failed to trigger SOS: empty response');
    }
    return data;
  }

  @override
  Future<api.Incident?> getActiveIncident(String rideId) async => null;
}

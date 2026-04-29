import 'package:sakai_api_client/sakai_api_client.dart' as api;
import 'package:sakai_shared/repositories/sos_repository.dart';

class SOSRepositoryImpl implements SOSRepository {
  final api.RidesApi _ridesApi;

  SOSRepositoryImpl(this._ridesApi);

  @override
  Future<api.Incident> triggerSOS(String rideId, {String? reason}) async {
    final response = await _ridesApi.rideTriggerSOS(
      rideId: rideId,
      triggerSOSRequest: api.TriggerSOSRequest((b) => b..reason = reason),
    );

    if (response.data == null) {
      throw Exception('Failed to trigger SOS: empty response');
    }

    return response.data!;
  }

  @override
  Future<api.Incident?> getActiveIncident(String rideId) async {
    // Current API doesn't have a direct "get active incident for ride" endpoint
    // In a real app, this might be a separate call or part of ride details.
    return null;
  }
}

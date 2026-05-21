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
    //
    // OUTSTANDING (MOB-P6.1): wire this to the WS dispatcher's SOS lifecycle
    // state instead of REST. ActiveRideController already folds
    // ride.sos_triggered / incident.assigned / incident.resolved into
    // SosUiState (see active_ride_notifier.dart) — surface that state here so
    // the support screen / location pusher know when an incident is open.
    return null;
  }
}

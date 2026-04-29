import 'package:sakai_api_client/sakai_api_client.dart' as api;

abstract class SOSRepository {
  /// Triggers an emergency SOS alert for the current ride.
  /// Returns the incident details if successful.
  Future<api.Incident> triggerSOS(String rideId, {String? reason});

  /// Fetches the current active SOS incident details if any.
  Future<api.Incident?> getActiveIncident(String rideId);
}

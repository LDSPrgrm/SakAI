import 'package:sakai_api_client/sakai_api_client.dart';
import 'package:sakai_shared/repositories/sos_repository.dart';

class SOSRepositoryImpl implements SOSRepository {
  final RidesApi _ridesApi;

  SOSRepositoryImpl(this._ridesApi);

  @override
  Future<RideResponse> triggerSOS(String rideId, {String? reason}) async {
    try {
      // Assuming RidesApi has an adminUpdateRideStatus or similar that could be used for SOS
      // Or if there's a specific SOS endpoint in the backend not yet in the client.
      // For now, let's use a hypothetical or common pattern.
      // Based on available endpoints, we might need a specific SOS endpoint.
      // Let's assume for this implementation we use a generic ride update if available.
      // Actually, looking at RidesApi, there's no explicit SOS.
      // I'll implement it as a TODO or use existing status update if applicable.
      throw UnimplementedError('SOS endpoint not yet confirmed in RidesApi');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<RideResponse?> getActiveIncident(String rideId) async {
    try {
      final response = await _ridesApi.rideGet(rideId: rideId);
      return response.data;
    } catch (e) {
      return null;
    }
  }
}

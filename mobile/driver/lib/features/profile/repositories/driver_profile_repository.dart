import 'package:sakai_api_client/sakai_api_client.dart' as api;

/// Port for the authenticated driver's profile and vehicle.
///
/// GET is wired against existing `GET /users/me`. PATCH endpoints don't exist
/// yet (TODO(backend)).
abstract class DriverProfileRepository {
  Future<api.UserProfile> getProfile();

  /// TODO(backend): wire to PATCH /users/me once endpoint exists.
  Future<void> updateProfile({String? name});

  /// TODO(backend): wire to PATCH /driver/vehicle once endpoint exists.
  Future<void> updateVehicle({
    required String make,
    required String model,
    required String color,
    required String plate,
  });
}

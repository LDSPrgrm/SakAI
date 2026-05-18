import 'package:sakai_api_client/sakai_api_client.dart' as api;
import 'package:sakai_shared/sakai_shared.dart' show BackendUnavailableException;

import 'driver_profile_repository.dart';

class DriverProfileRepositoryImpl implements DriverProfileRepository {
  DriverProfileRepositoryImpl(this._client);
  final api.SakaiApiClient _client;

  @override
  Future<api.UserProfile> getProfile() async {
    final response = await _client.getUsersApi().usersGetMe();
    final data = response.data;
    if (data == null) {
      throw Exception('Empty response from /users/me');
    }
    return data;
  }

  @override
  Future<void> updateProfile({String? name}) {
    throw const BackendUnavailableException(feature: 'profile');
  }

  @override
  Future<void> updateVehicle({
    required String make,
    required String model,
    required String color,
    required String plate,
  }) {
    throw const BackendUnavailableException(feature: 'vehicle');
  }
}

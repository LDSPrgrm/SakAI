import 'package:sakai_api_client/sakai_api_client.dart';

import 'availability_repository.dart';

class AvailabilityRepositoryImpl implements AvailabilityRepository {
  AvailabilityRepositoryImpl(this._client);
  // ignore: unused_field
  final SakaiApiClient _client;

  @override
  Future<AvailabilityPrefs> get() {
    throw UnimplementedError('Availability prefs endpoint not implemented.');
  }

  @override
  Future<void> save(AvailabilityPrefs prefs) {
    throw UnimplementedError('Availability prefs endpoint not implemented.');
  }
}

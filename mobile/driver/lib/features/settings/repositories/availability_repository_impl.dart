import 'package:sakai_shared/sakai_shared.dart';

import 'availability_repository.dart';

class AvailabilityRepositoryImpl implements AvailabilityRepository {
  AvailabilityRepositoryImpl(this._client);
  // ignore: unused_field
  final SakaiApiClient _client;

  @override
  Future<AvailabilityPrefs> get() {
    throw const BackendUnavailableException(feature: 'availability');
  }

  @override
  Future<void> save(AvailabilityPrefs prefs) {
    throw const BackendUnavailableException(feature: 'availability');
  }
}

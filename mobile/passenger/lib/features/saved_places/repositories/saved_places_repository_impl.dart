import 'package:sakai_api_client/sakai_api_client.dart' as api;
import '../models/saved_place.dart';
import 'saved_places_repository.dart';

class SavedPlacesRepositoryImpl implements SavedPlacesRepository {
  final api.UsersApi _usersApi;

  SavedPlacesRepositoryImpl(this._usersApi);

  @override
  Future<List<SavedPlace>> getSavedPlaces() async {
    final response = await _usersApi.savedPlacesList();
    if (response.data == null) return [];

    return response.data!.map((apiPlace) => _mapApiToDomain(apiPlace)).toList();
  }

  @override
  Future<SavedPlace> addSavedPlace({
    required String name,
    required String address,
    required double latitude,
    required double longitude,
    SavedPlaceType type = SavedPlaceType.other,
  }) async {
    final request = api.SavedPlaceCreateRequest(
      (b) => b
        ..name = name
        ..address = address
        ..latitude = latitude
        ..longitude = longitude
        ..type = _mapDomainToApiType(type),
    );

    final response = await _usersApi.savedPlacesCreate(
      savedPlaceCreateRequest: request,
    );

    if (response.data == null) {
      throw Exception('Failed to add saved place');
    }

    return _mapApiToDomain(response.data!);
  }

  @override
  Future<void> deleteSavedPlace(String placeId) async {
    await _usersApi.savedPlacesDelete(placeId: placeId);
  }

  SavedPlace _mapApiToDomain(api.SavedPlace apiPlace) {
    return SavedPlace(
      id: apiPlace.id,
      name: apiPlace.name,
      address: apiPlace.address,
      latitude: apiPlace.latitude,
      longitude: apiPlace.longitude,
      type: _mapApiTypeToDomain(apiPlace.type),
      createdAt: apiPlace.createdAt,
    );
  }

  SavedPlaceType _mapApiTypeToDomain(api.SavedPlaceTypeEnum? apiType) {
    if (apiType == api.SavedPlaceTypeEnum.home) return SavedPlaceType.home;
    if (apiType == api.SavedPlaceTypeEnum.work) return SavedPlaceType.work;
    return SavedPlaceType.other;
  }

  api.SavedPlaceCreateRequestTypeEnum _mapDomainToApiType(SavedPlaceType type) {
    switch (type) {
      case SavedPlaceType.home:
        return api.SavedPlaceCreateRequestTypeEnum.home;
      case SavedPlaceType.work:
        return api.SavedPlaceCreateRequestTypeEnum.work;
      case SavedPlaceType.other:
        return api.SavedPlaceCreateRequestTypeEnum.other;
    }
  }
}

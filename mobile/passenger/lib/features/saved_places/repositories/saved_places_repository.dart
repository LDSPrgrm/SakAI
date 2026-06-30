import '../models/saved_place.dart';

abstract class SavedPlacesRepository {
  Future<List<SavedPlace>> getSavedPlaces();
  Future<SavedPlace> addSavedPlace({
    required String name,
    required String address,
    required double latitude,
    required double longitude,
    SavedPlaceType type = SavedPlaceType.other,
  });
  Future<void> deleteSavedPlace(String placeId);
}

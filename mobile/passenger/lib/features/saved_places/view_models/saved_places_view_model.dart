import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/saved_place.dart';
import '../repositories/saved_places_repository.dart';
import '../repositories/saved_places_repository_impl.dart';
import '../../../app/providers.dart';

class SavedPlacesState {
  const SavedPlacesState({
    this.status = SavedPlacesStatus.initial,
    this.savedPlaces = const [],
    this.errorMessage,
  });

  final SavedPlacesStatus status;
  final List<SavedPlace> savedPlaces;
  final String? errorMessage;

  SavedPlacesState copyWith({
    SavedPlacesStatus? status,
    List<SavedPlace>? savedPlaces,
    String? errorMessage,
  }) {
    return SavedPlacesState(
      status: status ?? this.status,
      savedPlaces: savedPlaces ?? this.savedPlaces,
      errorMessage: errorMessage,
    );
  }
}

enum SavedPlacesStatus { initial, loading, loaded, error }

final savedPlacesRepositoryProvider = Provider<SavedPlacesRepository>((ref) {
  return SavedPlacesRepositoryImpl(ref.watch(apiClientProvider).getUsersApi());
});

class SavedPlacesNotifier extends Notifier<SavedPlacesState> {
  @override
  SavedPlacesState build() => const SavedPlacesState();

  SavedPlacesRepository get _repository => ref.read(savedPlacesRepositoryProvider);

  Future<void> loadSavedPlaces() async {
    state = state.copyWith(status: SavedPlacesStatus.loading);

    try {
      final places = await _repository.getSavedPlaces();
      state = state.copyWith(
        status: SavedPlacesStatus.loaded,
        savedPlaces: places,
      );
    } catch (e) {
      debugPrint('[SavedPlacesNotifier] Error loading saved places: $e');
      state = state.copyWith(
        status: SavedPlacesStatus.error,
        errorMessage: 'Failed to load saved places',
      );
    }
  }

  Future<bool> addSavedPlace({
    required String name,
    required String address,
    required double latitude,
    required double longitude,
    SavedPlaceType type = SavedPlaceType.other,
  }) async {
    try {
      state = state.copyWith(status: SavedPlacesStatus.loading);
      final newPlace = await _repository.addSavedPlace(
        name: name,
        address: address,
        latitude: latitude,
        longitude: longitude,
        type: type,
      );
      
      final updatedList = List<SavedPlace>.from(state.savedPlaces)..add(newPlace);
      state = state.copyWith(
        status: SavedPlacesStatus.loaded,
        savedPlaces: updatedList,
      );
      return true;
    } catch (e) {
      debugPrint('[SavedPlacesNotifier] Error adding saved place: $e');
      state = state.copyWith(
        status: SavedPlacesStatus.error,
        errorMessage: 'Failed to add saved place',
      );
      return false;
    }
  }

  Future<bool> deleteSavedPlace(String placeId) async {
    try {
      state = state.copyWith(status: SavedPlacesStatus.loading);
      await _repository.deleteSavedPlace(placeId);
      
      final updatedList = state.savedPlaces.where((place) => place.id != placeId).toList();
      state = state.copyWith(
        status: SavedPlacesStatus.loaded,
        savedPlaces: updatedList,
      );
      return true;
    } catch (e) {
      debugPrint('[SavedPlacesNotifier] Error deleting saved place: $e');
      state = state.copyWith(
        status: SavedPlacesStatus.error,
        errorMessage: 'Failed to delete saved place',
      );
      return false;
    }
  }
}

final savedPlacesNotifierProvider = NotifierProvider<SavedPlacesNotifier, SavedPlacesState>(
  SavedPlacesNotifier.new,
);

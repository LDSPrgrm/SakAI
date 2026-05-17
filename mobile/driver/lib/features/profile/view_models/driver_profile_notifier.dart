import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sakai_api_client/sakai_api_client.dart' as api;

import '../repositories/driver_profile_repository.dart';
import '../../../app/providers.dart';

class DriverProfileState {
  const DriverProfileState({
    this.loading = false,
    this.profile,
    this.errorMessage,
    this.saving = false,
  });

  final bool loading;
  final api.UserProfile? profile;
  final String? errorMessage;
  final bool saving;

  DriverProfileState copyWith({
    bool? loading,
    api.UserProfile? profile,
    String? errorMessage,
    bool? saving,
  }) {
    return DriverProfileState(
      loading: loading ?? this.loading,
      profile: profile ?? this.profile,
      errorMessage: errorMessage,
      saving: saving ?? this.saving,
    );
  }
}

class DriverProfileNotifier extends Notifier<DriverProfileState> {
  @override
  DriverProfileState build() {
    Future.microtask(load);
    return const DriverProfileState(loading: true);
  }

  DriverProfileRepository get _repo => ref.read(driverProfileRepositoryProvider);

  Future<void> load() async {
    state = state.copyWith(loading: true, errorMessage: null);
    try {
      final profile = await _repo.getProfile();
      state = DriverProfileState(profile: profile);
    } catch (e) {
      state = DriverProfileState(errorMessage: e.toString());
    }
  }

  Future<void> saveName(String name) async {
    state = state.copyWith(saving: true, errorMessage: null);
    try {
      await _repo.updateProfile(name: name);
      await load();
    } on UnimplementedError catch (e) {
      state = state.copyWith(saving: false, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(saving: false, errorMessage: e.toString());
    }
  }

  Future<void> saveVehicle({
    required String make,
    required String model,
    required String color,
    required String plate,
  }) async {
    state = state.copyWith(saving: true, errorMessage: null);
    try {
      await _repo.updateVehicle(
        make: make,
        model: model,
        color: color,
        plate: plate,
      );
      await load();
    } on UnimplementedError catch (e) {
      state = state.copyWith(saving: false, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(saving: false, errorMessage: e.toString());
    }
  }
}

final driverProfileNotifierProvider =
    NotifierProvider<DriverProfileNotifier, DriverProfileState>(
      DriverProfileNotifier.new,
    );

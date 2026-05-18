import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../repositories/availability_repository.dart';
import '../../../app/providers.dart';

class AvailabilityState {
  const AvailabilityState({
    this.loading = false,
    this.saving = false,
    this.prefs = const AvailabilityPrefs(),
    this.errorMessage,
    this.backendUnavailable,
  });

  final bool loading;
  final bool saving;
  final AvailabilityPrefs prefs;
  final String? errorMessage;
  final BackendUnavailableException? backendUnavailable;

  AvailabilityState copyWith({
    bool? loading,
    bool? saving,
    AvailabilityPrefs? prefs,
    String? errorMessage,
    BackendUnavailableException? backendUnavailable,
  }) {
    return AvailabilityState(
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      prefs: prefs ?? this.prefs,
      errorMessage: errorMessage,
      backendUnavailable: backendUnavailable,
    );
  }
}

class AvailabilityNotifier extends Notifier<AvailabilityState> {
  @override
  AvailabilityState build() {
    Future.microtask(load);
    return const AvailabilityState(loading: true);
  }

  AvailabilityRepository get _repo => ref.read(availabilityRepositoryProvider);

  Future<void> load() async {
    state = state.copyWith(loading: true, errorMessage: null);
    try {
      final prefs = await _repo.get();
      state = AvailabilityState(prefs: prefs);
    } on BackendUnavailableException catch (e) {
      // Show the form with defaults so the UI is still usable for design review.
      state = AvailabilityState(backendUnavailable: e);
    } catch (e) {
      state = AvailabilityState(errorMessage: e.toString());
    }
  }

  void update(AvailabilityPrefs prefs) {
    state = state.copyWith(prefs: prefs);
  }

  Future<void> save() async {
    state = state.copyWith(saving: true, errorMessage: null);
    try {
      await _repo.save(state.prefs);
      state = state.copyWith(saving: false);
    } on BackendUnavailableException catch (e) {
      state = state.copyWith(saving: false, backendUnavailable: e);
    } catch (e) {
      state = state.copyWith(saving: false, errorMessage: e.toString());
    }
  }
}

final availabilityNotifierProvider =
    NotifierProvider<AvailabilityNotifier, AvailabilityState>(
      AvailabilityNotifier.new,
    );

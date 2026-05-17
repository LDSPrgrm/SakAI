import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/availability_repository.dart';
import '../../../app/providers.dart';

class AvailabilityState {
  const AvailabilityState({
    this.loading = false,
    this.saving = false,
    this.prefs = const AvailabilityPrefs(),
    this.errorMessage,
  });

  final bool loading;
  final bool saving;
  final AvailabilityPrefs prefs;
  final String? errorMessage;

  AvailabilityState copyWith({
    bool? loading,
    bool? saving,
    AvailabilityPrefs? prefs,
    String? errorMessage,
  }) {
    return AvailabilityState(
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      prefs: prefs ?? this.prefs,
      errorMessage: errorMessage,
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
    } on UnimplementedError catch (e) {
      // Show the form with defaults so the UI is still usable for design review.
      state = AvailabilityState(errorMessage: e.message);
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
    } on UnimplementedError catch (e) {
      state = state.copyWith(saving: false, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(saving: false, errorMessage: e.toString());
    }
  }
}

final availabilityNotifierProvider =
    NotifierProvider<AvailabilityNotifier, AvailabilityState>(
      AvailabilityNotifier.new,
    );

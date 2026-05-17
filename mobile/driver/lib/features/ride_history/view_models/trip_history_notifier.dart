import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sakai_api_client/sakai_api_client.dart' as api;

import '../repositories/ride_history_repository.dart';
import '../../../app/providers.dart';

class TripHistoryState {
  const TripHistoryState({
    this.loading = false,
    this.items = const [],
    this.errorMessage,
  });

  final bool loading;
  final List<api.RideResponse> items;
  final String? errorMessage;

  TripHistoryState copyWith({
    bool? loading,
    List<api.RideResponse>? items,
    String? errorMessage,
  }) {
    return TripHistoryState(
      loading: loading ?? this.loading,
      items: items ?? this.items,
      errorMessage: errorMessage,
    );
  }
}

class TripHistoryNotifier extends Notifier<TripHistoryState> {
  @override
  TripHistoryState build() {
    Future.microtask(load);
    return const TripHistoryState(loading: true);
  }

  RideHistoryRepository get _repo => ref.read(rideHistoryRepositoryProvider);

  Future<void> load() async {
    state = state.copyWith(loading: true, errorMessage: null);
    try {
      final items = await _repo.getRideHistory(page: 1, limit: 50);
      state = TripHistoryState(items: items);
    } catch (e) {
      state = TripHistoryState(errorMessage: e.toString());
    }
  }
}

final tripHistoryNotifierProvider =
    NotifierProvider<TripHistoryNotifier, TripHistoryState>(
      TripHistoryNotifier.new,
    );

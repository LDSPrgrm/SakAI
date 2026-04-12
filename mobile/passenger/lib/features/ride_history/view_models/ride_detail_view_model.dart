import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show Provider;

import '../../../app/providers.dart' show rideHistoryRepositoryProvider;
import '../models/ride_detail.dart';
import '../repositories/ride_history_repository.dart';
import '../repositories/ride_history_repository_impl.dart'
    show RideHistoryException;

enum RideDetailStatus { initial, loading, success, error }

class RideDetailState {
  const RideDetailState({
    this.status = RideDetailStatus.initial,
    this.detail,
    this.error,
  });

  final RideDetailStatus status;
  final RideDetail? detail;
  final String? error;

  RideDetailState copyWith({
    RideDetailStatus? status,
    RideDetail? detail,
    String? error,
    bool clearError = false,
  }) {
    return RideDetailState(
      status: status ?? this.status,
      detail: detail ?? this.detail,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Provider family that creates a RideDetailNotifier per rideId.
final rideDetailNotifierProvider = Provider.family<RideDetailNotifier, String>((
  ref,
  rideId,
) {
  final repo = ref.watch(rideHistoryRepositoryProvider);
  return RideDetailNotifier(repo, rideId);
});

class RideDetailNotifier extends ChangeNotifier {
  RideDetailNotifier(this._repo, this._rideId);

  final RideHistoryRepository _repo;
  final String _rideId;

  RideDetailState _state = const RideDetailState();
  RideDetailState get state => _state;

  /// Load full detail for a single ride.
  Future<void> loadDetail() async {
    _state = state.copyWith(status: RideDetailStatus.loading, clearError: true);
    notifyListeners();
    try {
      final detail = await _repo.getRideDetail(_rideId);
      _state = state.copyWith(status: RideDetailStatus.success, detail: detail);
    } catch (e) {
      final message = e is RideHistoryException
          ? e.userMessage
          : 'Failed to load ride details.';
      _state = state.copyWith(status: RideDetailStatus.error, error: message);
    }
    notifyListeners();
  }
}

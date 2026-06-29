import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/session_earnings.dart';
import '../repositories/earnings_repository.dart';
import '../../../app/providers.dart';

class EarningsState {
  final bool isLoading;
  final SessionEarnings earnings;
  final String? error;

  const EarningsState({
    this.isLoading = false,
    this.earnings = const SessionEarnings(),
    this.error,
  });

  EarningsState copyWith({
    bool? isLoading,
    SessionEarnings? earnings,
    String? error,
  }) {
    return EarningsState(
      isLoading: isLoading ?? this.isLoading,
      earnings: earnings ?? this.earnings,
      error: error,
    );
  }
}

class EarningsNotifier extends Notifier<EarningsState> {
  @override
  EarningsState build() {
    // Initial load in microtask to avoid building while notifying
    Future.microtask(() => loadEarnings());
    return const EarningsState();
  }

  EarningsRepository get _repository => ref.read(earningsRepositoryProvider);

  Future<void> loadEarnings() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final earnings = await _repository.getEarnings();
      state = state.copyWith(isLoading: false, earnings: earnings);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Adds a completed ride to the earnings total (local update).
  void addRide({
    required String rideId,
    required double fare,
    double tip = 0.0,
    required DateTime completedAt,
  }) {
    final breakdown = RideBreakdown(
      rideId: rideId,
      fare: fare,
      tip: tip,
      completedAt: completedAt,
    );

    final currentEarnings = state.earnings;
    final newTotal = currentEarnings.totalEarnings + breakdown.total;

    final updatedEarnings = currentEarnings.copyWith(
      completedRidesCount: currentEarnings.completedRidesCount + 1,
      totalEarnings: newTotal,
      rideBreakdowns: [breakdown, ...currentEarnings.rideBreakdowns],
    );

    state = state.copyWith(earnings: updatedEarnings);
  }

  /// Resets earnings (on app restart or manual reset).
  void reset() {
    state = const EarningsState();
  }
}

final earningsNotifierProvider =
    NotifierProvider<EarningsNotifier, EarningsState>(EarningsNotifier.new);

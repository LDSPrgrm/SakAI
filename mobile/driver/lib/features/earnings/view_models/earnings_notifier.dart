import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/session_earnings.dart';

class EarningsNotifier extends Notifier<SessionEarnings> {
  @override
  SessionEarnings build() => const SessionEarnings();

  SessionEarnings get earnings => state;
  int get completedRidesCount => state.completedRidesCount;
  double get totalEarnings => state.totalEarnings;

  /// Adds a completed ride to the earnings total.
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

    final newTotal = state.totalEarnings + breakdown.total;
    state = state.copyWith(
      completedRidesCount: state.completedRidesCount + 1,
      totalEarnings: newTotal,
      rideBreakdowns: [...state.rideBreakdowns, breakdown],
    );
  }

  /// Resets earnings (on app restart or manual reset).
  void reset() {
    state = const SessionEarnings();
  }
}

final earningsNotifierProvider =
    NotifierProvider<EarningsNotifier, SessionEarnings>(EarningsNotifier.new);

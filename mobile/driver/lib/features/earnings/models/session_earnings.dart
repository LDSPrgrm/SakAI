/// Session-level earnings accumulator.
class SessionEarnings {
  const SessionEarnings({
    this.completedRidesCount = 0,
    this.totalEarnings = 0.0,
    this.rideBreakdowns = const [],
  });

  final int completedRidesCount;
  final double totalEarnings;
  final List<RideBreakdown> rideBreakdowns;

  SessionEarnings copyWith({
    int? completedRidesCount,
    double? totalEarnings,
    List<RideBreakdown>? rideBreakdowns,
  }) {
    return SessionEarnings(
      completedRidesCount: completedRidesCount ?? this.completedRidesCount,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      rideBreakdowns: rideBreakdowns ?? this.rideBreakdowns,
    );
  }
}

/// Per-ride earnings detail.
class RideBreakdown {
  const RideBreakdown({
    required this.rideId,
    required this.fare,
    this.tip = 0.0,
    required this.completedAt,
  });

  final String rideId;
  final double fare;
  final double tip;
  final DateTime completedAt;

  double get total => fare + tip;
}

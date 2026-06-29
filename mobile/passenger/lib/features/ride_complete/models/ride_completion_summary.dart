import 'package:sakai_shared/sakai_shared.dart';

/// Domain model representing the post-ride completion summary.
class RideCompletionSummary {
  const RideCompletionSummary({
    required this.rideId,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.baseFare,
    this.tipAmount,
    required this.finalTotal,
    required this.paymentMethod,
    required this.driverName,
    this.driverVehicle,
    required this.tripDurationMinutes,
    required this.completedAt,
  });

  final String rideId;
  final String pickupAddress;
  final String destinationAddress;
  final double baseFare;
  final double? tipAmount;
  final double finalTotal;
  final PaymentMethod paymentMethod;
  final String driverName;
  final String? driverVehicle;
  final int tripDurationMinutes;
  final DateTime completedAt;

  /// Maps a generated RideResponse to a domain RideCompletionSummary.
  factory RideCompletionSummary.fromRideResponse(RideResponse ride) {
    final now = DateTime.now();
    final duration = now.difference(ride.createdAt).inMinutes;

    return RideCompletionSummary(
      rideId: ride.id,
      pickupAddress: ride.originAddress ?? 'Unknown pickup',
      destinationAddress: ride.destinationAddress ?? 'Unknown destination',
      baseFare: _extractFare(ride),
      tipAmount: null,
      finalTotal: _extractFare(ride),
      paymentMethod: PaymentMethod.cash, // Default; enriched from payment data
      driverName: 'Driver', // TODO: enrich from user API
      driverVehicle: null, // TODO: enrich from vehicle data
      tripDurationMinutes: duration >= 0 ? duration : 0,
      completedAt: ride.updatedAt,
    );
  }

  static double _extractFare(RideResponse ride) {
    // RFC v2 P7: ride.fare is the backend's finalised total set on
    // completion. The legacy 0.0 placeholder predated the backend wiring
    // and broke the receipt screen. ride.completed WS payload now carries
    // a richer breakdown (fare_breakdown, payment_method, tip_amount);
    // wiring the dispatcher to enrich this model lands with MOB-P7.3.
    return ride.fare ?? 0.0;
  }

  RideCompletionSummary copyWith({
    String? rideId,
    String? pickupAddress,
    String? destinationAddress,
    double? baseFare,
    double? tipAmount,
    double? finalTotal,
    PaymentMethod? paymentMethod,
    String? driverName,
    String? driverVehicle,
    int? tripDurationMinutes,
    DateTime? completedAt,
  }) {
    return RideCompletionSummary(
      rideId: rideId ?? this.rideId,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      baseFare: baseFare ?? this.baseFare,
      tipAmount: tipAmount ?? this.tipAmount,
      finalTotal: finalTotal ?? this.finalTotal,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      driverName: driverName ?? this.driverName,
      driverVehicle: driverVehicle ?? this.driverVehicle,
      tripDurationMinutes: tripDurationMinutes ?? this.tripDurationMinutes,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

/// Mirror of the generated PaymentMethod enum for domain use.
enum PaymentMethod { cash, card }

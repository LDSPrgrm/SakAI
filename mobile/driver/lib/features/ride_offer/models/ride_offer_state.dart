import 'dart:math';

import 'package:sakai_api_client/sakai_api_client.dart';

/// State for an incoming ride offer displayed to the driver.
class RideOfferState {
  const RideOfferState({
    required this.rideId,
    required this.passenger,
    required this.origin,
    required this.destination,
    this.originAddress,
    this.destinationAddress,
    this.notes,
    required this.expiresAt,
    this.distanceToPickupMeters,
    this.countdownSeconds = 30,
  });

  factory RideOfferState.fromEvent(
    WsEventRideRequested event, {
    double? currentLat,
    double? currentLng,
  }) {
    double? distance;
    if (currentLat != null && currentLng != null) {
      distance = _haversineDistance(
        currentLat,
        currentLng,
        event.origin.lat,
        event.origin.lng,
      );
    }
    return RideOfferState(
      rideId: event.rideId,
      passenger: event.passenger,
      origin: event.origin,
      destination: event.destination,
      originAddress: event.originAddress,
      destinationAddress: event.destinationAddress,
      notes: event.notes,
      expiresAt: event.expiresAt,
      distanceToPickupMeters: distance,
    );
  }

  final String rideId;
  final UserProfile passenger;
  final LatLng origin;
  final LatLng destination;
  final String? originAddress;
  final String? destinationAddress;
  final String? notes;
  final DateTime expiresAt;
  final double? distanceToPickupMeters;
  final int countdownSeconds;

  RideOfferState copyWith({
    int? countdownSeconds,
    double? distanceToPickupMeters,
  }) {
    return RideOfferState(
      rideId: rideId,
      passenger: passenger,
      origin: origin,
      destination: destination,
      originAddress: originAddress,
      destinationAddress: destinationAddress,
      notes: notes,
      expiresAt: expiresAt,
      distanceToPickupMeters:
          distanceToPickupMeters ?? this.distanceToPickupMeters,
      countdownSeconds: countdownSeconds ?? this.countdownSeconds,
    );
  }

  static double _haversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371000; // meters
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * asin(sqrt(a));
    return earthRadius * c;
  }

  static double _toRadians(double degrees) =>
      degrees * 3.1415926535897932 / 180;
}

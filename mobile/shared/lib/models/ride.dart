import 'package:sakai_api_client/sakai_api_client.dart';

/// Domain Ride model — stable wrapper around the generated [RideResponse].
class DomainRide {
  final String id;
  final String passengerId;
  final String? driverId;
  final double pickupLat;
  final double pickupLng;
  final double destLat;
  final double destLng;
  final RideStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DriverSummary? driverSummary;

  DomainRide({
    required this.id,
    required this.passengerId,
    this.driverId,
    required this.pickupLat,
    required this.pickupLng,
    required this.destLat,
    required this.destLng,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.driverSummary,
  });

  factory DomainRide.fromApi(RideResponse r) => DomainRide(
        id: r.id,
        passengerId: r.passenger.id,
        driverId: r.driver?.id,
        pickupLat: r.origin.lat,
        pickupLng: r.origin.lng,
        destLat: r.destination.lat,
        destLng: r.destination.lng,
        status: r.status,
        notes: r.notes,
        createdAt: r.createdAt,
        updatedAt: r.updatedAt,
        driverSummary: r.driver,
      );
}

import 'package:sakai_api_client/sakai_api_client.dart';

/// Domain model for the driver session.
///
/// Tracks the driver's online status, GPS availability, and current location.
/// Used by the home screen and shift management logic.
class DriverSession {
  const DriverSession({
    this.isOnline = false,
    this.status = DriverSessionStatus.offline,
    this.vehiclePlate = '',
    this.vehicle,
    this.gpsAvailable = false,
    this.currentLocation,
  });

  /// Whether the driver is currently available for rides.
  final bool isOnline;

  /// The driver's status enum (online/offline).
  final DriverSessionStatus status;

  /// The vehicle's license plate number.
  final String vehiclePlate;

  /// Full vehicle information (make, model, color, plate).
  final VehicleInfo? vehicle;

  /// Whether a valid GPS signal is currently available.
  final bool gpsAvailable;

  /// The driver's last known GPS coordinates.
  final LatLng? currentLocation;

  /// Returns a copy with the specified fields updated.
  DriverSession copyWith({
    bool? isOnline,
    DriverSessionStatus? status,
    String? vehiclePlate,
    VehicleInfo? vehicle,
    bool? gpsAvailable,
    LatLng? currentLocation,
  }) {
    return DriverSession(
      isOnline: isOnline ?? this.isOnline,
      status: status ?? this.status,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      vehicle: vehicle ?? this.vehicle,
      gpsAvailable: gpsAvailable ?? this.gpsAvailable,
      currentLocation: currentLocation ?? this.currentLocation,
    );
  }
}

/// Driver session status — mirrors the API DriverStatusRequestStatusEnum.
enum DriverSessionStatus { online, offline }

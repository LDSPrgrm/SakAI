import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:sakai_shared/sakai_shared.dart';

/// UI step within the passenger active ride flow.
enum ActiveRideStep {
  /// Driver accepted ride — en route to pickup.
  enRoute,

  /// Driver arrived at pickup location.
  arrived,

  /// Ride in progress — heading to destination.
  inProgress;

  static ActiveRideStep fromRideStatus(RideStatus status) {
    switch (status) {
      case RideStatus.accepted:
        return ActiveRideStep.enRoute;
      case RideStatus.arrived:
        return ActiveRideStep.arrived;
      case RideStatus.inProgress:
        return ActiveRideStep.inProgress;
      default:
        return ActiveRideStep.enRoute;
    }
  }
}

/// Immutable state model for the active ride screen.
class ActiveRideState {
  const ActiveRideState({
    this.ride,
    this.driverName,
    this.driverVehicle,
    required this.currentStep,
    this.driverLocation,
    this.isLoading = false,
    this.errorMessage,
    this.sos = SosUiState.idle,
  });

  /// The underlying ride response.
  final RideResponse? ride;

  /// Driver display name (from API response or WS events).
  final String? driverName;

  /// Vehicle description e.g. "Toyota Vios · ABC 123 · White".
  final String? driverVehicle;

  /// Current UI step derived from ride status.
  final ActiveRideStep currentStep;

  /// Driver's current GPS location (updated via WS).
  final gmaps.LatLng? driverLocation;

  /// Whether the initial ride load is in progress.
  final bool isLoading;

  /// Error message if loading failed.
  final String? errorMessage;

  /// SOS lifecycle state — drives the emergency banner. See [SosUiState].
  final SosUiState sos;

  ActiveRideState copyWith({
    RideResponse? ride,
    String? driverName,
    String? driverVehicle,
    ActiveRideStep? currentStep,
    gmaps.LatLng? driverLocation,
    bool? isLoading,
    String? errorMessage,
    SosUiState? sos,
  }) {
    return ActiveRideState(
      ride: ride ?? this.ride,
      driverName: driverName ?? this.driverName,
      driverVehicle: driverVehicle ?? this.driverVehicle,
      currentStep: currentStep ?? this.currentStep,
      driverLocation: driverLocation ?? this.driverLocation,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      sos: sos ?? this.sos,
    );
  }

  /// Create from a RideResponse, enriching driver info if available.
  factory ActiveRideState.fromRideResponse(RideResponse response) {
    final driver = response.driver;
    String? driverName;
    String? driverVehicle;

    if (driver != null) {
      driverName = driver.name;
      final vehicle = driver.vehicle;
      if (vehicle != null) {
        driverVehicle =
            '${vehicle.make} ${vehicle.model} · ${vehicle.plate} · ${vehicle.color}';
      }
    }

    gmaps.LatLng? driverLocation;
    if (driver?.currentLocation != null) {
      driverLocation = gmaps.LatLng(
        driver!.currentLocation!.lat,
        driver.currentLocation!.lng,
      );
    }

    return ActiveRideState(
      ride: response,
      driverName: driverName,
      driverVehicle: driverVehicle,
      currentStep: ActiveRideStep.fromRideStatus(response.status),
      driverLocation: driverLocation,
      isLoading: false,
    );
  }
}

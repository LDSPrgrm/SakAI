import 'ride_location.dart';

/// Domain status enum matching the API `RideStatus` values.
/// Pure Dart — no Flutter or networking imports.
enum RideState {
  requested,
  accepted,
  arrived,
  inProgress,
  completed,
  cancelled;

  static RideState fromString(String value) {
    final normalized = value.toLowerCase();
    switch (normalized) {
      case 'requested':
        return RideState.requested;
      case 'accepted':
        return RideState.accepted;
      case 'arrived':
        return RideState.arrived;
      case 'in_progress':
      case 'inprogress':
        return RideState.inProgress;
      case 'completed':
        return RideState.completed;
      case 'cancelled':
        return RideState.cancelled;
      default:
        throw ArgumentError('Unknown RideState: $value');
    }
  }
}

/// Domain entity for a ride.
/// Consolidated from redundant models. Shared via `sakai_shared`.
class RideEntity {
  const RideEntity({
    required this.id,
    required this.passengerId,
    required this.status,
    required this.origin,
    required this.destination,
    required this.createdAt,
    required this.updatedAt,
    this.driverId,
    this.driverName,
    this.driverVehicle,
    this.cancelledBy,
    this.notes,
  });

  final String id;
  final String passengerId;
  final RideState status;
  final RideLocation origin;
  final RideLocation destination;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Null until a driver has accepted.
  final String? driverId;
  final String? driverName;

  /// e.g. "Toyota Vios · ABC 123 · White"
  final String? driverVehicle;

  /// Set only when [status] is [RideState.cancelled].
  final String? cancelledBy;

  final String? notes;

  RideEntity copyWith({
    String? id,
    String? passengerId,
    RideState? status,
    RideLocation? origin,
    RideLocation? destination,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? driverId,
    String? driverName,
    String? driverVehicle,
    String? cancelledBy,
    String? notes,
  }) {
    return RideEntity(
      id: id ?? this.id,
      passengerId: passengerId ?? this.passengerId,
      status: status ?? this.status,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      driverVehicle: driverVehicle ?? this.driverVehicle,
      cancelledBy: cancelledBy ?? this.cancelledBy,
      notes: notes ?? this.notes,
    );
  }
}

/// Domain payment method enum.
/// Renamed to avoid collision with generated API client.
enum RidePaymentMethod { cash, card }

extension RidePaymentMethodExtension on RidePaymentMethod {
  String get displayName {
    switch (this) {
      case RidePaymentMethod.cash:
        return 'Cash';
      case RidePaymentMethod.card:
        return 'Card';
    }
  }

  static RidePaymentMethod fromApi(String value) {
    switch (value.toLowerCase()) {
      case 'cash':
        return RidePaymentMethod.cash;
      case 'card':
        return RidePaymentMethod.card;
      default:
        return RidePaymentMethod.cash;
    }
  }
}

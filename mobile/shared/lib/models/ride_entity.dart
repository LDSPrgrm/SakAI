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
    switch (value) {
      case 'requested':
        return RideState.requested;
      case 'accepted':
        return RideState.accepted;
      case 'arrived':
        return RideState.arrived;
      case 'in_progress':
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

/// Domain entity for a ride. Mapped from `RideResponse` in `data/`.
/// Shared between passenger and driver apps via `sakai_shared`.
class RideEntity {
  const RideEntity({
    required this.id,
    required this.status,
    required this.origin,
    required this.destination,
    required this.createdAt,
    required this.updatedAt,
    this.driverName,
    this.driverVehicle,
    this.cancelledBy,
  });

  final String id;
  final RideState status;
  final RideLocation origin;
  final RideLocation destination;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Null until a driver has accepted.
  final String? driverName;

  /// e.g. "Toyota Vios · ABC 123 · White"
  final String? driverVehicle;

  /// Set only when [status] is [RideStatus.cancelled].
  final String? cancelledBy;

  RideEntity copyWith({
    String? id,
    RideState? status,
    RideLocation? origin,
    RideLocation? destination,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? driverName,
    String? driverVehicle,
    String? cancelledBy,
  }) {
    return RideEntity(
      id: id ?? this.id,
      status: status ?? this.status,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      driverName: driverName ?? this.driverName,
      driverVehicle: driverVehicle ?? this.driverVehicle,
      cancelledBy: cancelledBy ?? this.cancelledBy,
    );
  }
}

enum PaymentMethod { cash, card }

extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.card:
        return 'Card';
    }
  }

  static PaymentMethod fromApi(String value) {
    switch (value.toLowerCase()) {
      case 'cash':
        return PaymentMethod.cash;
      case 'card':
        return PaymentMethod.card;
      default:
        return PaymentMethod.cash;
    }
  }
}

import 'package:sakai_shared/sakai_shared.dart';

/// Returns a numeric ordering value for a [RideStatus] so we can compare
/// whether the ride has progressed past a given stage.
int _statusOrder(RideStatus s) {
  if (s == RideStatus.requested) return 0;
  if (s == RideStatus.accepted) return 1;
  if (s == RideStatus.arrived) return 2;
  if (s == RideStatus.inProgress) return 3;
  if (s == RideStatus.completed || s == RideStatus.cancelled) return 4;
  throw StateError('Unknown RideStatus: $s');
}

/// Extended domain model for the ride detail view.
/// Includes all [RideHistoryItem] fields plus coordinates, timestamps, and extras.
class RideDetail {
  RideDetail({
    required this.id,
    required this.status,
    required this.originAddress,
    required this.destinationAddress,
    this.fare,
    required this.estimatedFare,
    this.driverName,
    this.driverVehicle,
    required this.paymentMethod,
    required this.createdAt,
    required this.updatedAt,
    required this.origin,
    required this.destination,
    this.requestedAt,
    this.acceptedAt,
    this.arrivedAt,
    this.startedAt,
    this.completedAt,
    this.cancellationReason,
    this.notes,
  });

  factory RideDetail.fromRideResponse(RideResponse r) {
    final driver = r.driver;
    String? driverVehicle;
    if (driver != null) {
      final v = driver.vehicle;
      if (v != null) {
        driverVehicle = '${v.make} ${v.model} - ${v.plate}';
      }
    }

    return RideDetail(
      id: r.id,
      status: r.status,
      originAddress: r.originAddress ?? 'Pickup location',
      destinationAddress: r.destinationAddress ?? 'Drop-off location',
      fare: r.fare,
      estimatedFare: r.estimatedFare ?? 0,
      driverName: driver?.name,
      driverVehicle: driverVehicle,
      paymentMethod: r.paymentMethod?.name ?? 'cash',
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
      origin: LatLng(
        (b) => b
          ..lat = r.origin.lat
          ..lng = r.origin.lng,
      ),
      destination: LatLng(
        (b) => b
          ..lat = r.destination.lat
          ..lng = r.destination.lng,
      ),
      requestedAt: r.createdAt,
      acceptedAt: _statusOrder(r.status) >= _statusOrder(RideStatus.accepted)
          ? r.updatedAt
          : null,
      arrivedAt: _statusOrder(r.status) >= _statusOrder(RideStatus.arrived)
          ? r.updatedAt
          : null,
      startedAt: _statusOrder(r.status) >= _statusOrder(RideStatus.inProgress)
          ? r.updatedAt
          : null,
      completedAt: r.status == RideStatus.completed ? r.updatedAt : null,
      cancellationReason: r.status == RideStatus.cancelled
          ? 'Ride was cancelled'
          : null,
      notes: r.notes,
    );
  }

  final String id;
  final RideStatus status;
  final String originAddress;
  final String destinationAddress;
  final double? fare;
  final double estimatedFare;
  final String? driverName;
  final String? driverVehicle;
  final String paymentMethod;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Map coordinates
  final LatLng origin;
  final LatLng destination;

  // Timestamps
  final DateTime? requestedAt;
  final DateTime? acceptedAt;
  final DateTime? arrivedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;

  // Extras
  final String? cancellationReason;
  final String? notes;

  bool get isCompleted => status == RideStatus.completed;
  bool get isCancelled => status == RideStatus.cancelled;

  String get displayFare {
    final amount = fare ?? estimatedFare;
    return '\$${amount.toStringAsFixed(2)}';
  }

  String get statusLabel {
    if (status == RideStatus.requested) return 'Requested';
    if (status == RideStatus.accepted) return 'Accepted';
    if (status == RideStatus.arrived) return 'Arrived';
    if (status == RideStatus.inProgress) return 'In Progress';
    if (status == RideStatus.completed) return 'Completed';
    if (status == RideStatus.cancelled) return 'Cancelled';
    throw StateError('Unknown RideStatus: $status');
  }

  String? _formatTimestamp(DateTime? ts) {
    if (ts == null) return null;
    return '${ts.year}-${ts.month.toString().padLeft(2, '0')}-${ts.day.toString().padLeft(2, '0')} '
        '${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}';
  }

  Map<String, String?> get timelineLabels {
    return {
      'Requested': _formatTimestamp(requestedAt),
      'Accepted': _formatTimestamp(acceptedAt),
      'Arrived': _formatTimestamp(arrivedAt),
      'Started': _formatTimestamp(startedAt),
      'Completed': _formatTimestamp(completedAt),
    };
  }
}

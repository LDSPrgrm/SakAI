import 'package:sakai_shared/sakai_shared.dart';

/// Domain model for a ride history list item.
/// Wraps the generated [UserRideItem] with convenience helpers.
class RideHistoryItem {
  RideHistoryItem({
    required this.id,
    required this.status,
    required this.originAddress,
    required this.destinationAddress,
    this.fare,
    required this.estimatedFare,
    this.driverName,
    required this.paymentMethod,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RideHistoryItem.fromUserRideItem(UserRideItem item) {
    return RideHistoryItem(
      id: item.id,
      status: item.status,
      originAddress: item.originAddress,
      destinationAddress: item.destinationAddress,
      fare: item.fare,
      estimatedFare: item.estimatedFare ?? 0.0,
      driverName: item.driver?.name,
      paymentMethod: item.paymentMethod.name,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
    );
  }

  final String id;
  final RideStatus status;
  final String originAddress;
  final String destinationAddress;
  final double? fare;
  final double estimatedFare;
  final String? driverName;
  final String paymentMethod;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isCompleted => status == RideStatus.completed;
  bool get isCancelled => status == RideStatus.cancelled;

  String get displayFare {
    final amount = fare ?? estimatedFare;
    return '\$${amount.toStringAsFixed(2)}';
  }

  String get statusLabel {
    final name = status.name;
    if (name == 'created') return 'Created';
    if (name == 'requested') return 'Requested';
    if (name == 'accepted') return 'Accepted';
    if (name == 'arrived') return 'Arrived';
    if (name == 'inProgress' || name == 'in_progress') return 'In Progress';
    if (name == 'paymentPending' || name == 'payment_pending') return 'Payment Pending';
    if (name == 'completed') return 'Completed';
    if (name == 'cancelled') return 'Cancelled';
    return name;
  }
}

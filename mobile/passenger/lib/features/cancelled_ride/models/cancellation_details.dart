import 'package:sakai_shared/sakai_shared.dart';

/// Predefined cancellation reason codes.
enum CancellationReason {
  driverTooFar('driver_too_far', 'Driver is too far away'),
  changedPlans('changed_plans', 'I changed my plans'),
  wrongPickup('wrong_pickup', 'Wrong pickup location'),
  driverNotMoving('driver_not_moving', 'Driver is not moving'),
  safetyConcern('safety_concern', 'Safety concern'),
  other('other', 'Other reason');

  const CancellationReason(this.code, this.label);

  final String code;
  final String label;

  static CancellationReason fromCode(String? value) {
    for (final reason in CancellationReason.values) {
      if (reason.code == value) return reason;
    }
    return CancellationReason.other;
  }

  static const List<CancellationReason> predefinedReasons = [
    driverTooFar,
    changedPlans,
    wrongPickup,
    driverNotMoving,
    safetyConcern,
    other,
  ];
}

/// Who initiated the cancellation.
enum CancelledBy {
  passenger,
  driver,
  system;

  static CancelledBy fromString(String? value) {
    switch (value) {
      case 'passenger':
        return CancelledBy.passenger;
      case 'driver':
        return CancelledBy.driver;
      case 'system':
        return CancelledBy.system;
      default:
        return CancelledBy.system;
    }
  }

  static CancelledBy? fromApiEnum(RideResponseCancelledByEnum? value) {
    if (value == null) return null;
    switch (value.name) {
      case 'passenger':
        return CancelledBy.passenger;
      case 'driver':
        return CancelledBy.driver;
      default:
        return CancelledBy.system;
    }
  }

  String get displayName {
    switch (this) {
      case CancelledBy.passenger:
        return 'You';
      case CancelledBy.driver:
        return 'Driver';
      case CancelledBy.system:
        return 'System';
    }
  }
}

/// Cancellation details for a cancelled ride.
class CancellationDetails {
  CancellationDetails({
    required this.rideId,
    required this.cancelledBy,
    required this.reason,
    required this.cancelledAt,
    this.driverName,
    this.driverVehicle,
    this.refundAmount,
    this.cancellationFee,
    this.originAddress,
    this.destinationAddress,
    this.reasonCode,
    this.reasonText,
  });

  factory CancellationDetails.fromRideResponse(RideResponse r) {
    final driver = r.driver;
    String? driverVehicle;
    if (driver != null) {
      final v = driver.vehicle;
      if (v != null) {
        driverVehicle = '${v.make} ${v.model} - ${v.plate}';
      }
    }

    final cancelledBy = CancelledBy.fromApiEnum(r.cancelledBy);
    final wasPaid = r.fare != null && r.fare! > 0;
    final refundAmount = wasPaid ? r.fare : null;
    // Cancellation fee comes from the ride's fare field if a fee was applied
    final double? cancellationFee = r.fare != null && r.fare! > 0
        ? r.fare
        : null;

    // Parse reason code from response
    final reasonCode = CancellationReason.fromCode(r.cancellationReason);
    final reasonText = r.cancellationReasonText;

    String reason;
    if (reasonCode != CancellationReason.other &&
        reasonCode != CancellationReason.fromCode(null)) {
      reason = reasonCode.label;
    } else if (reasonText != null && reasonText.isNotEmpty) {
      reason = reasonText;
    } else if (cancelledBy == CancelledBy.passenger) {
      reason = 'You cancelled this ride';
    } else if (cancelledBy == CancelledBy.driver) {
      reason = 'Your driver cancelled this ride';
    } else {
      reason = 'This ride was cancelled due to unforeseen circumstances';
    }

    return CancellationDetails(
      rideId: r.id,
      cancelledBy: cancelledBy ?? CancelledBy.system,
      reason: reason,
      cancelledAt: r.updatedAt,
      driverName: driver?.name,
      driverVehicle: driverVehicle,
      refundAmount: refundAmount,
      cancellationFee: cancellationFee,
      originAddress: r.originAddress,
      destinationAddress: r.destinationAddress,
      reasonCode: reasonCode,
      reasonText: reasonText,
    );
  }

  final String rideId;
  final CancelledBy cancelledBy;
  final String reason;
  final DateTime cancelledAt;
  final String? driverName;
  final String? driverVehicle;
  final double? refundAmount;
  final double? cancellationFee;
  final String? originAddress;
  final String? destinationAddress;
  final CancellationReason? reasonCode;
  final String? reasonText;

  bool get hasDriver => driverName != null;
  bool get hasRefund => refundAmount != null;
  bool get hasFee => cancellationFee != null && cancellationFee! > 0;
  bool get hasReasonCode => reasonCode != null;

  double get netRefund {
    if (!hasRefund) return 0;
    if (hasFee) return refundAmount! - cancellationFee!;
    return refundAmount!;
  }

  String get formattedCancelledAt {
    return '${_twoDigit(cancelledAt.month)}/${_twoDigit(cancelledAt.day)}/${cancelledAt.year} '
        '${_twoDigit(cancelledAt.hour)}:${_twoDigit(cancelledAt.minute)}';
  }

  String get formattedRefund {
    if (!hasRefund) return '';
    return '\$${netRefund.toStringAsFixed(2)}';
  }

  String get formattedFee {
    if (!hasFee) return '';
    return '\$${cancellationFee!.toStringAsFixed(2)}';
  }

  String _twoDigit(int n) => n.toString().padLeft(2, '0');
}

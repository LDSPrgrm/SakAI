/// Driver-side cancellation taxonomy.
///
/// Mirrors the Go side at `internal/domain/ride.go` — keep wire values in
/// sync or the backend will silently drop the code. RFC v2 §8.6.
library;

enum DriverCancelReason {
  passengerNoShow('passenger_no_show', 'Passenger never arrived'),
  unsafePickupArea('unsafe_pickup_area', 'Pickup spot unsafe to enter'),
  vehicleIssue('vehicle_issue', 'Vehicle problem'),
  passengerRequest('passenger_request', 'Passenger asked me to cancel'),
  otherDriverReason('other_driver_reason', 'Other reason'),
  other('other', 'Other');

  final String wire;
  final String label;
  const DriverCancelReason(this.wire, this.label);

  static DriverCancelReason? fromWire(String s) {
    for (final r in values) {
      if (r.wire == s) return r;
    }
    return null;
  }

  /// Codes shown in the driver cancel picker, in display order. `other`
  /// always lives at the bottom.
  static const List<DriverCancelReason> ordered = [
    passengerNoShow,
    unsafePickupArea,
    vehicleIssue,
    passengerRequest,
    otherDriverReason,
    other,
  ];
}

/// Passenger-side cancellation taxonomy (parity with the existing
/// `CancellationReason` in mobile/passenger). Re-exported here so both
/// apps can refer to the same shared module.
enum PassengerCancelReason {
  driverTooFar('driver_too_far', 'Driver is too far'),
  changedPlans('changed_plans', 'Changed my plans'),
  wrongPickup('wrong_pickup', 'Wrong pickup location'),
  driverNotMoving('driver_not_moving', 'Driver not moving'),
  safetyConcern('safety_concern', 'Safety concern'),
  other('other', 'Other');

  final String wire;
  final String label;
  const PassengerCancelReason(this.wire, this.label);

  static PassengerCancelReason? fromWire(String s) {
    for (final r in values) {
      if (r.wire == s) return r;
    }
    return null;
  }

  static const List<PassengerCancelReason> ordered = [
    driverTooFar,
    changedPlans,
    wrongPickup,
    driverNotMoving,
    safetyConcern,
    other,
  ];
}

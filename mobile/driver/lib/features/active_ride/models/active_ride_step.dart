/// UI step within the active ride flow.
enum ActiveRideStep {
  /// Driver accepted ride — en route to pickup.
  enRoute,
  /// Driver arrived at pickup location.
  arrived,
  /// Ride in progress — heading to destination.
  inProgress,
}

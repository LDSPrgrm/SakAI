/// Typed WebSocket event types for SakAI.
library;

/// Base event wrapper parsing the { event, payload } envelope.
class WsEvent {
  final String type;
  final Map<String, dynamic> payload;

  WsEvent({required this.type, required this.payload});

  factory WsEvent.fromMessage(Map<String, dynamic> message) {
    return WsEvent(
      type: message['event'] as String,
      payload: (message['payload'] as Map?)?.cast<String, dynamic>() ?? {},
    );
  }
}

/// Event names as constants.
class WsEventNames {
  static const rideRequested = 'ride.requested';
  static const rideAccepted = 'ride.accepted';
  static const rideDeclined = 'ride.declined';
  static const rideOfferExpired = 'ride.offer_expired';
  static const rideArrived = 'ride.arrived';
  static const rideStatusChanged = 'ride.status_changed';
  static const rideCancelled = 'ride.cancelled';
  static const rideSosTriggered = 'ride.sos_triggered';
  static const driverLocationUpdated = 'driver.location_updated';
}

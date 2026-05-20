/// Typed WebSocket event types for SakAI.
library;

import 'package:meta/meta.dart';

/// Base event wrapper parsing the { event, payload, timestamp?, event_id? }
/// envelope. Extra fields (timestamp, event_id) introduced in spec v1.3.0
/// are forward-compatible: older clients ignore them, newer clients
/// surface them via [timestamp] and [eventId].
class WsEvent {
  final String type;
  final Map<String, dynamic> payload;

  /// Server-stamped RFC3339 timestamp. Null when the wire format predates
  /// spec v1.3.0 or the server omitted the field.
  final DateTime? timestamp;

  /// Server-stamped UUIDv7. Null on legacy/missing wire data. Use for
  /// client-side dedup across reconnects.
  final String? eventId;

  WsEvent({
    required this.type,
    required this.payload,
    this.timestamp,
    this.eventId,
  });

  factory WsEvent.fromMessage(Map<String, dynamic> message) {
    final eventVal = message['event'];
    final payloadVal = message['payload'];
    final type = eventVal is String ? eventVal : (eventVal?.toString() ?? '');

    Map<String, dynamic> payload = {};
    if (payloadVal is Map) {
      payloadVal.forEach((key, value) {
        payload[key.toString()] = value;
      });
    }

    DateTime? ts;
    final tsVal = message['timestamp'];
    if (tsVal is String) {
      ts = DateTime.tryParse(tsVal);
    }

    String? eid;
    final eidVal = message['event_id'];
    if (eidVal is String && eidVal.isNotEmpty) eid = eidVal;

    return WsEvent(
      type: type,
      payload: payload,
      timestamp: ts,
      eventId: eid,
    );
  }
}

/// A frame that could NOT be parsed back into a [WsEvent]. Surfaced on
/// [WsClient.malformed] so apps can wire telemetry without re-reading
/// the raw stream.
@immutable
class WsMalformedEvent {
  final String rawPayload;
  final String reason;
  final Object? error;

  const WsMalformedEvent({
    required this.rawPayload,
    required this.reason,
    this.error,
  });

  @override
  String toString() =>
      'WsMalformedEvent(reason: $reason, raw: $rawPayload, error: $error)';
}

/// Strongly typed enum over the canonical event names. Mirrors the
/// `WsEventType` enum in openapi/swagger.yaml.
///
/// Use [WsEventType.fromWire] to parse an incoming string and
/// [WsEventType.wire] to serialize outbound. `unknown` matches any
/// string the client wasn't compiled to recognize — handlers should
/// either ignore it or route through [WsClient.malformed].
enum WsEventType {
  rideRequested('ride.requested'),
  rideAccepted('ride.accepted'),
  rideDeclined('ride.declined'),
  rideOfferExpired('ride.offer_expired'),
  rideArrived('ride.arrived'),
  rideStatusChanged('ride.status_changed'),
  rideCancelled('ride.cancelled'),
  rideSosTriggered('ride.sos_triggered'),
  rideNoDrivers('ride.no_drivers'),
  driverLocationUpdated('driver.location_updated'),
  unknown('');

  final String wire;
  const WsEventType(this.wire);

  static WsEventType fromWire(String wire) {
    for (final t in values) {
      if (t.wire == wire) return t;
    }
    return WsEventType.unknown;
  }
}

/// Event names as string constants. Kept for backward compatibility with
/// existing call sites; new code should prefer [WsEventType].
class WsEventNames {
  static const rideRequested = 'ride.requested';
  static const rideAccepted = 'ride.accepted';
  static const rideDeclined = 'ride.declined';
  static const rideOfferExpired = 'ride.offer_expired';
  static const rideArrived = 'ride.arrived';
  static const rideStatusChanged = 'ride.status_changed';
  static const rideCancelled = 'ride.cancelled';
  static const rideSosTriggered = 'ride.sos_triggered';
  static const rideNoDrivers = 'ride.no_drivers';
  static const driverLocationUpdated = 'driver.location_updated';
}

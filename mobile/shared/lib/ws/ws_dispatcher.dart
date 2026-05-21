/// Centralized WebSocket event router.
///
/// Consumers register typed handlers via [WsDispatcher.on] instead of
/// switching on raw event strings and hand-extracting payload keys. The
/// dispatcher owns deserialization (via `standardSerializers` from the
/// generated `sakai_api_client`) and surfaces failures on a `malformed`
/// stream.
library;

import 'dart:async';
import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:logging/logging.dart';
import 'package:sakai_api_client/sakai_api_client.dart';

import 'ws_client.dart';
import 'ws_events.dart';

final _log = Logger('WsDispatcher');

/// Fast-path payload for `driver.location_updated`. Skips the full
/// `built_value` serializer pipeline; reads only the four hot fields
/// the rider-map UI needs. Justified by the spec tag
/// `x-high-frequency: true` on the underlying schema.
class DriverLocationFast {
  final String rideId;
  final double lat;
  final double lng;
  final double? heading;

  const DriverLocationFast({
    required this.rideId,
    required this.lat,
    required this.lng,
    this.heading,
  });

  factory DriverLocationFast.fromJson(Map<String, dynamic> json) {
    final loc = json['location'];
    if (loc is! Map) {
      throw FormatException('location missing or not a map');
    }
    final lat = loc['lat'];
    final lng = loc['lng'];
    if (lat is! num || lng is! num) {
      throw FormatException('location.lat/lng missing or wrong type');
    }
    final rideId = json['ride_id'];
    if (rideId is! String) {
      throw FormatException('ride_id missing or not a string');
    }
    final heading = json['heading'];
    return DriverLocationFast(
      rideId: rideId,
      lat: lat.toDouble(),
      lng: lng.toDouble(),
      heading: heading is num ? heading.toDouble() : null,
    );
  }
}

class _Entry {
  final void Function(Object payload) handler;
  _Entry(this.handler);
}

class WsDispatcher {
  final WsClient _client;
  final Map<WsEventType, List<_Entry>> _handlers = {};
  StreamSubscription<WsEvent>? _eventSub;
  StreamSubscription<WsMalformedEvent>? _malformedSub;
  final StreamController<WsMalformedEvent> _malformed =
      StreamController<WsMalformedEvent>.broadcast();

  WsDispatcher(this._client) {
    _eventSub = _client.events.listen(_dispatch);
    _malformedSub = _client.malformed.listen(_malformed.add);
  }

  /// Stream of frames that could not be parsed OR could not be
  /// deserialized into the expected typed payload. Forwards the
  /// underlying client's `malformed` stream and adds entries for
  /// deserialization failures discovered here.
  Stream<WsMalformedEvent> get malformed => _malformed.stream;

  /// Register a handler for [type]. Returns a disposer that removes
  /// this handler when called — wire it into Riverpod `ref.onDispose`.
  void Function() on<T>(WsEventType type, void Function(T payload) handler) {
    final entry = _Entry((p) => handler(p as T));
    _handlers.putIfAbsent(type, () => <_Entry>[]).add(entry);
    return () {
      final list = _handlers[type];
      if (list != null) {
        list.remove(entry);
        if (list.isEmpty) _handlers.remove(type);
      }
    };
  }

  Future<void> dispose() async {
    await _eventSub?.cancel();
    await _malformedSub?.cancel();
    await _malformed.close();
    _handlers.clear();
  }

  void _dispatch(WsEvent event) {
    final type = WsEventType.fromWire(event.type);
    if (type == WsEventType.unknown) {
      // Forward-compatible: unknown event names from newer servers are
      // dropped, NOT treated as malformed.
      return;
    }
    final handlers = _handlers[type];
    if (handlers == null || handlers.isEmpty) return;

    final Object? payload;
    try {
      payload = _deserialize(type, event.payload);
    } catch (e, st) {
      _log.warning(
        'deserialize failed for ${type.wire}: $e',
        e,
        st,
      );
      _malformed.add(WsMalformedEvent(
        rawPayload: jsonEncode(event.payload),
        reason: 'deserialize: ${e.runtimeType}',
        error: e,
      ));
      return;
    }
    if (payload == null) {
      _malformed.add(WsMalformedEvent(
        rawPayload: jsonEncode(event.payload),
        reason: 'deserialize: payload null for ${type.wire}',
      ));
      return;
    }

    for (final h in List<_Entry>.from(handlers)) {
      try {
        h.handler(payload);
      } catch (e, st) {
        _log.warning(
          'handler for ${type.wire} threw: $e',
          e,
          st,
        );
      }
    }
  }

  /// Deserializes the raw payload map into the typed model the handler
  /// expects. Returns null if no model is wired for this event type
  /// (which becomes a `malformed` entry — registered handlers shouldn't
  /// hit this branch in normal operation).
  Object? _deserialize(WsEventType type, Map<String, dynamic> payload) {
    switch (type) {
      case WsEventType.driverLocationUpdated:
        // Fast path — bypasses built_value to skip the BuiltMap allocation
        // and reflection-style typecheck on every location frame.
        return DriverLocationFast.fromJson(payload);

      case WsEventType.rideRequested:
        return _bv(WsEventRideRequested.serializer, payload);
      case WsEventType.rideAccepted:
        return _bv(WsEventRideAccepted.serializer, payload);
      case WsEventType.rideDeclined:
        return _bv(WsEventRideDeclined.serializer, payload);
      case WsEventType.rideOfferExpired:
        return _bv(WsEventRideOfferExpired.serializer, payload);
      case WsEventType.rideStatusChanged:
        return _bv(WsEventRideStatusChanged.serializer, payload);
      case WsEventType.rideCancelled:
        return _bv(WsEventRideCancelled.serializer, payload);
      case WsEventType.rideNoDrivers:
        return _bv(WsEventNoDriversAvailable.serializer, payload);

      case WsEventType.rideSosTriggered:
      case WsEventType.rideArrived:
        // No generated model in api_client yet (spec recently added /
        // legacy alias). Surface payload as a BuiltMap for handlers
        // that want raw access.
        return BuiltMap<String, Object?>.from(payload);

      case WsEventType.rideCompleted:
        // OpenAPI bump introduced WsEventRideCompleted but the
        // built_value regen is queued; pass through as a raw map so
        // passenger receipt + driver earnings handlers can already wire
        // up without waiting on the codegen sweep.
        return BuiltMap<String, Object?>.from(payload);

      case WsEventType.incidentAssigned:
      case WsEventType.incidentResolved:
        // SOS lifecycle (P6). Models pending built_value regen — expose
        // raw payload so the SOS banner can read assignee + resolution
        // fields immediately.
        return BuiltMap<String, Object?>.from(payload);

      case WsEventType.connWelcome:
        // Protocol metadata event — handlers (if any) take the raw payload.
        return BuiltMap<String, Object?>.from(payload);

      case WsEventType.rideStateSync:
        // Reconnect-time snapshot. No generated model yet (OpenAPI bump
        // will land WsEventRideStateSync); expose raw map so notifiers can
        // pull has_active_ride / ride_id / status without waiting on regen.
        return BuiltMap<String, Object?>.from(payload);

      case WsEventType.unknown:
        return null;
    }
  }

  /// Tiny wrapper that hides the standardSerializers dance.
  T? _bv<T>(Serializer<T> serializer, Map<String, dynamic> payload) {
    return standardSerializers.deserializeWith(serializer, payload);
  }
}

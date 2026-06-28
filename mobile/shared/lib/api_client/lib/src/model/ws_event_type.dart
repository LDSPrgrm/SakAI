// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ws_event_type.g.dart';

class WsEventType extends EnumClass {

  /// Canonical WebSocket event identifier. Used as the discriminator for `WsEnvelope.payload`. Add new values here in lockstep with the matching `WsEvent*` payload schema below. 
  @BuiltValueEnumConst(wireName: r'ride.requested')
  static const WsEventType ridePeriodRequested = _$ridePeriodRequested;
  /// Canonical WebSocket event identifier. Used as the discriminator for `WsEnvelope.payload`. Add new values here in lockstep with the matching `WsEvent*` payload schema below. 
  @BuiltValueEnumConst(wireName: r'ride.accepted')
  static const WsEventType ridePeriodAccepted = _$ridePeriodAccepted;
  /// Canonical WebSocket event identifier. Used as the discriminator for `WsEnvelope.payload`. Add new values here in lockstep with the matching `WsEvent*` payload schema below. 
  @BuiltValueEnumConst(wireName: r'ride.declined')
  static const WsEventType ridePeriodDeclined = _$ridePeriodDeclined;
  /// Canonical WebSocket event identifier. Used as the discriminator for `WsEnvelope.payload`. Add new values here in lockstep with the matching `WsEvent*` payload schema below. 
  @BuiltValueEnumConst(wireName: r'ride.offer_expired')
  static const WsEventType ridePeriodOfferExpired = _$ridePeriodOfferExpired;
  /// Canonical WebSocket event identifier. Used as the discriminator for `WsEnvelope.payload`. Add new values here in lockstep with the matching `WsEvent*` payload schema below. 
  @BuiltValueEnumConst(wireName: r'ride.status_changed')
  static const WsEventType ridePeriodStatusChanged = _$ridePeriodStatusChanged;
  /// Canonical WebSocket event identifier. Used as the discriminator for `WsEnvelope.payload`. Add new values here in lockstep with the matching `WsEvent*` payload schema below. 
  @BuiltValueEnumConst(wireName: r'ride.completed')
  static const WsEventType ridePeriodCompleted = _$ridePeriodCompleted;
  /// Canonical WebSocket event identifier. Used as the discriminator for `WsEnvelope.payload`. Add new values here in lockstep with the matching `WsEvent*` payload schema below. 
  @BuiltValueEnumConst(wireName: r'ride.cancelled')
  static const WsEventType ridePeriodCancelled = _$ridePeriodCancelled;
  /// Canonical WebSocket event identifier. Used as the discriminator for `WsEnvelope.payload`. Add new values here in lockstep with the matching `WsEvent*` payload schema below. 
  @BuiltValueEnumConst(wireName: r'ride.sos_triggered')
  static const WsEventType ridePeriodSosTriggered = _$ridePeriodSosTriggered;
  /// Canonical WebSocket event identifier. Used as the discriminator for `WsEnvelope.payload`. Add new values here in lockstep with the matching `WsEvent*` payload schema below. 
  @BuiltValueEnumConst(wireName: r'ride.no_drivers')
  static const WsEventType ridePeriodNoDrivers = _$ridePeriodNoDrivers;
  /// Canonical WebSocket event identifier. Used as the discriminator for `WsEnvelope.payload`. Add new values here in lockstep with the matching `WsEvent*` payload schema below. 
  @BuiltValueEnumConst(wireName: r'ride.state_sync')
  static const WsEventType ridePeriodStateSync = _$ridePeriodStateSync;
  /// Canonical WebSocket event identifier. Used as the discriminator for `WsEnvelope.payload`. Add new values here in lockstep with the matching `WsEvent*` payload schema below. 
  @BuiltValueEnumConst(wireName: r'incident.assigned')
  static const WsEventType incidentPeriodAssigned = _$incidentPeriodAssigned;
  /// Canonical WebSocket event identifier. Used as the discriminator for `WsEnvelope.payload`. Add new values here in lockstep with the matching `WsEvent*` payload schema below. 
  @BuiltValueEnumConst(wireName: r'incident.resolved')
  static const WsEventType incidentPeriodResolved = _$incidentPeriodResolved;
  /// Canonical WebSocket event identifier. Used as the discriminator for `WsEnvelope.payload`. Add new values here in lockstep with the matching `WsEvent*` payload schema below. 
  @BuiltValueEnumConst(wireName: r'driver.location_updated')
  static const WsEventType driverPeriodLocationUpdated = _$driverPeriodLocationUpdated;
  /// Canonical WebSocket event identifier. Used as the discriminator for `WsEnvelope.payload`. Add new values here in lockstep with the matching `WsEvent*` payload schema below. 
  @BuiltValueEnumConst(wireName: r'conn.welcome')
  static const WsEventType connPeriodWelcome = _$connPeriodWelcome;

  static Serializer<WsEventType> get serializer => _$wsEventTypeSerializer;

  const WsEventType._(String name): super(name);

  static BuiltSet<WsEventType> get values => _$values;
  static WsEventType valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class WsEventTypeMixin = Object with _$WsEventTypeMixin;


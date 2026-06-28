// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ws_event_type.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const WsEventType _$ridePeriodRequested = const WsEventType._(
  'ridePeriodRequested',
);
const WsEventType _$ridePeriodAccepted = const WsEventType._(
  'ridePeriodAccepted',
);
const WsEventType _$ridePeriodDeclined = const WsEventType._(
  'ridePeriodDeclined',
);
const WsEventType _$ridePeriodOfferExpired = const WsEventType._(
  'ridePeriodOfferExpired',
);
const WsEventType _$ridePeriodStatusChanged = const WsEventType._(
  'ridePeriodStatusChanged',
);
const WsEventType _$ridePeriodCompleted = const WsEventType._(
  'ridePeriodCompleted',
);
const WsEventType _$ridePeriodCancelled = const WsEventType._(
  'ridePeriodCancelled',
);
const WsEventType _$ridePeriodSosTriggered = const WsEventType._(
  'ridePeriodSosTriggered',
);
const WsEventType _$ridePeriodNoDrivers = const WsEventType._(
  'ridePeriodNoDrivers',
);
const WsEventType _$ridePeriodStateSync = const WsEventType._(
  'ridePeriodStateSync',
);
const WsEventType _$incidentPeriodAssigned = const WsEventType._(
  'incidentPeriodAssigned',
);
const WsEventType _$incidentPeriodResolved = const WsEventType._(
  'incidentPeriodResolved',
);
const WsEventType _$driverPeriodLocationUpdated = const WsEventType._(
  'driverPeriodLocationUpdated',
);
const WsEventType _$connPeriodWelcome = const WsEventType._(
  'connPeriodWelcome',
);

WsEventType _$valueOf(String name) {
  switch (name) {
    case 'ridePeriodRequested':
      return _$ridePeriodRequested;
    case 'ridePeriodAccepted':
      return _$ridePeriodAccepted;
    case 'ridePeriodDeclined':
      return _$ridePeriodDeclined;
    case 'ridePeriodOfferExpired':
      return _$ridePeriodOfferExpired;
    case 'ridePeriodStatusChanged':
      return _$ridePeriodStatusChanged;
    case 'ridePeriodCompleted':
      return _$ridePeriodCompleted;
    case 'ridePeriodCancelled':
      return _$ridePeriodCancelled;
    case 'ridePeriodSosTriggered':
      return _$ridePeriodSosTriggered;
    case 'ridePeriodNoDrivers':
      return _$ridePeriodNoDrivers;
    case 'ridePeriodStateSync':
      return _$ridePeriodStateSync;
    case 'incidentPeriodAssigned':
      return _$incidentPeriodAssigned;
    case 'incidentPeriodResolved':
      return _$incidentPeriodResolved;
    case 'driverPeriodLocationUpdated':
      return _$driverPeriodLocationUpdated;
    case 'connPeriodWelcome':
      return _$connPeriodWelcome;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<WsEventType> _$values =
    BuiltSet<WsEventType>(const <WsEventType>[
      _$ridePeriodRequested,
      _$ridePeriodAccepted,
      _$ridePeriodDeclined,
      _$ridePeriodOfferExpired,
      _$ridePeriodStatusChanged,
      _$ridePeriodCompleted,
      _$ridePeriodCancelled,
      _$ridePeriodSosTriggered,
      _$ridePeriodNoDrivers,
      _$ridePeriodStateSync,
      _$incidentPeriodAssigned,
      _$incidentPeriodResolved,
      _$driverPeriodLocationUpdated,
      _$connPeriodWelcome,
    ]);

class _$WsEventTypeMeta {
  const _$WsEventTypeMeta();
  WsEventType get ridePeriodRequested => _$ridePeriodRequested;
  WsEventType get ridePeriodAccepted => _$ridePeriodAccepted;
  WsEventType get ridePeriodDeclined => _$ridePeriodDeclined;
  WsEventType get ridePeriodOfferExpired => _$ridePeriodOfferExpired;
  WsEventType get ridePeriodStatusChanged => _$ridePeriodStatusChanged;
  WsEventType get ridePeriodCompleted => _$ridePeriodCompleted;
  WsEventType get ridePeriodCancelled => _$ridePeriodCancelled;
  WsEventType get ridePeriodSosTriggered => _$ridePeriodSosTriggered;
  WsEventType get ridePeriodNoDrivers => _$ridePeriodNoDrivers;
  WsEventType get ridePeriodStateSync => _$ridePeriodStateSync;
  WsEventType get incidentPeriodAssigned => _$incidentPeriodAssigned;
  WsEventType get incidentPeriodResolved => _$incidentPeriodResolved;
  WsEventType get driverPeriodLocationUpdated => _$driverPeriodLocationUpdated;
  WsEventType get connPeriodWelcome => _$connPeriodWelcome;
  WsEventType valueOf(String name) => _$valueOf(name);
  BuiltSet<WsEventType> get values => _$values;
}

mixin _$WsEventTypeMixin {
  // ignore: non_constant_identifier_names
  _$WsEventTypeMeta get WsEventType => const _$WsEventTypeMeta();
}

Serializer<WsEventType> _$wsEventTypeSerializer = _$WsEventTypeSerializer();

class _$WsEventTypeSerializer implements PrimitiveSerializer<WsEventType> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ridePeriodRequested': 'ride.requested',
    'ridePeriodAccepted': 'ride.accepted',
    'ridePeriodDeclined': 'ride.declined',
    'ridePeriodOfferExpired': 'ride.offer_expired',
    'ridePeriodStatusChanged': 'ride.status_changed',
    'ridePeriodCompleted': 'ride.completed',
    'ridePeriodCancelled': 'ride.cancelled',
    'ridePeriodSosTriggered': 'ride.sos_triggered',
    'ridePeriodNoDrivers': 'ride.no_drivers',
    'ridePeriodStateSync': 'ride.state_sync',
    'incidentPeriodAssigned': 'incident.assigned',
    'incidentPeriodResolved': 'incident.resolved',
    'driverPeriodLocationUpdated': 'driver.location_updated',
    'connPeriodWelcome': 'conn.welcome',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ride.requested': 'ridePeriodRequested',
    'ride.accepted': 'ridePeriodAccepted',
    'ride.declined': 'ridePeriodDeclined',
    'ride.offer_expired': 'ridePeriodOfferExpired',
    'ride.status_changed': 'ridePeriodStatusChanged',
    'ride.completed': 'ridePeriodCompleted',
    'ride.cancelled': 'ridePeriodCancelled',
    'ride.sos_triggered': 'ridePeriodSosTriggered',
    'ride.no_drivers': 'ridePeriodNoDrivers',
    'ride.state_sync': 'ridePeriodStateSync',
    'incident.assigned': 'incidentPeriodAssigned',
    'incident.resolved': 'incidentPeriodResolved',
    'driver.location_updated': 'driverPeriodLocationUpdated',
    'conn.welcome': 'connPeriodWelcome',
  };

  @override
  final Iterable<Type> types = const <Type>[WsEventType];
  @override
  final String wireName = 'WsEventType';

  @override
  Object serialize(
    Serializers serializers,
    WsEventType object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  WsEventType deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => WsEventType.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ws_event_ride_sos_triggered.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const WsEventRideSOSTriggeredTriggeredByEnum
_$wsEventRideSOSTriggeredTriggeredByEnum_rider =
    const WsEventRideSOSTriggeredTriggeredByEnum._('rider');
const WsEventRideSOSTriggeredTriggeredByEnum
_$wsEventRideSOSTriggeredTriggeredByEnum_driver =
    const WsEventRideSOSTriggeredTriggeredByEnum._('driver');

WsEventRideSOSTriggeredTriggeredByEnum
_$wsEventRideSOSTriggeredTriggeredByEnumValueOf(String name) {
  switch (name) {
    case 'rider':
      return _$wsEventRideSOSTriggeredTriggeredByEnum_rider;
    case 'driver':
      return _$wsEventRideSOSTriggeredTriggeredByEnum_driver;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<WsEventRideSOSTriggeredTriggeredByEnum>
_$wsEventRideSOSTriggeredTriggeredByEnumValues =
    BuiltSet<WsEventRideSOSTriggeredTriggeredByEnum>(
      const <WsEventRideSOSTriggeredTriggeredByEnum>[
        _$wsEventRideSOSTriggeredTriggeredByEnum_rider,
        _$wsEventRideSOSTriggeredTriggeredByEnum_driver,
      ],
    );

Serializer<WsEventRideSOSTriggeredTriggeredByEnum>
_$wsEventRideSOSTriggeredTriggeredByEnumSerializer =
    _$WsEventRideSOSTriggeredTriggeredByEnumSerializer();

class _$WsEventRideSOSTriggeredTriggeredByEnumSerializer
    implements PrimitiveSerializer<WsEventRideSOSTriggeredTriggeredByEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'rider': 'rider',
    'driver': 'driver',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'rider': 'rider',
    'driver': 'driver',
  };

  @override
  final Iterable<Type> types = const <Type>[
    WsEventRideSOSTriggeredTriggeredByEnum,
  ];
  @override
  final String wireName = 'WsEventRideSOSTriggeredTriggeredByEnum';

  @override
  Object serialize(
    Serializers serializers,
    WsEventRideSOSTriggeredTriggeredByEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  WsEventRideSOSTriggeredTriggeredByEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => WsEventRideSOSTriggeredTriggeredByEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$WsEventRideSOSTriggered extends WsEventRideSOSTriggered {
  @override
  final String rideId;
  @override
  final String incidentId;
  @override
  final WsEventRideSOSTriggeredTriggeredByEnum triggeredBy;
  @override
  final String? reason;

  factory _$WsEventRideSOSTriggered([
    void Function(WsEventRideSOSTriggeredBuilder)? updates,
  ]) => (WsEventRideSOSTriggeredBuilder()..update(updates))._build();

  _$WsEventRideSOSTriggered._({
    required this.rideId,
    required this.incidentId,
    required this.triggeredBy,
    this.reason,
  }) : super._();
  @override
  WsEventRideSOSTriggered rebuild(
    void Function(WsEventRideSOSTriggeredBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  WsEventRideSOSTriggeredBuilder toBuilder() =>
      WsEventRideSOSTriggeredBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WsEventRideSOSTriggered &&
        rideId == other.rideId &&
        incidentId == other.incidentId &&
        triggeredBy == other.triggeredBy &&
        reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, rideId.hashCode);
    _$hash = $jc(_$hash, incidentId.hashCode);
    _$hash = $jc(_$hash, triggeredBy.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'WsEventRideSOSTriggered')
          ..add('rideId', rideId)
          ..add('incidentId', incidentId)
          ..add('triggeredBy', triggeredBy)
          ..add('reason', reason))
        .toString();
  }
}

class WsEventRideSOSTriggeredBuilder
    implements
        Builder<WsEventRideSOSTriggered, WsEventRideSOSTriggeredBuilder> {
  _$WsEventRideSOSTriggered? _$v;

  String? _rideId;
  String? get rideId => _$this._rideId;
  set rideId(String? rideId) => _$this._rideId = rideId;

  String? _incidentId;
  String? get incidentId => _$this._incidentId;
  set incidentId(String? incidentId) => _$this._incidentId = incidentId;

  WsEventRideSOSTriggeredTriggeredByEnum? _triggeredBy;
  WsEventRideSOSTriggeredTriggeredByEnum? get triggeredBy =>
      _$this._triggeredBy;
  set triggeredBy(WsEventRideSOSTriggeredTriggeredByEnum? triggeredBy) =>
      _$this._triggeredBy = triggeredBy;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  WsEventRideSOSTriggeredBuilder() {
    WsEventRideSOSTriggered._defaults(this);
  }

  WsEventRideSOSTriggeredBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _rideId = $v.rideId;
      _incidentId = $v.incidentId;
      _triggeredBy = $v.triggeredBy;
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WsEventRideSOSTriggered other) {
    _$v = other as _$WsEventRideSOSTriggered;
  }

  @override
  void update(void Function(WsEventRideSOSTriggeredBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WsEventRideSOSTriggered build() => _build();

  _$WsEventRideSOSTriggered _build() {
    final _$result =
        _$v ??
        _$WsEventRideSOSTriggered._(
          rideId: BuiltValueNullFieldError.checkNotNull(
            rideId,
            r'WsEventRideSOSTriggered',
            'rideId',
          ),
          incidentId: BuiltValueNullFieldError.checkNotNull(
            incidentId,
            r'WsEventRideSOSTriggered',
            'incidentId',
          ),
          triggeredBy: BuiltValueNullFieldError.checkNotNull(
            triggeredBy,
            r'WsEventRideSOSTriggered',
            'triggeredBy',
          ),
          reason: reason,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

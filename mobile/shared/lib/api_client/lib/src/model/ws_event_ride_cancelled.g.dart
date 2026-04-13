// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ws_event_ride_cancelled.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const WsEventRideCancelledCancelledByEnum
_$wsEventRideCancelledCancelledByEnum_passenger =
    const WsEventRideCancelledCancelledByEnum._('passenger');
const WsEventRideCancelledCancelledByEnum
_$wsEventRideCancelledCancelledByEnum_driver =
    const WsEventRideCancelledCancelledByEnum._('driver');

WsEventRideCancelledCancelledByEnum
_$wsEventRideCancelledCancelledByEnumValueOf(String name) {
  switch (name) {
    case 'passenger':
      return _$wsEventRideCancelledCancelledByEnum_passenger;
    case 'driver':
      return _$wsEventRideCancelledCancelledByEnum_driver;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<WsEventRideCancelledCancelledByEnum>
_$wsEventRideCancelledCancelledByEnumValues =
    BuiltSet<WsEventRideCancelledCancelledByEnum>(
      const <WsEventRideCancelledCancelledByEnum>[
        _$wsEventRideCancelledCancelledByEnum_passenger,
        _$wsEventRideCancelledCancelledByEnum_driver,
      ],
    );

Serializer<WsEventRideCancelledCancelledByEnum>
_$wsEventRideCancelledCancelledByEnumSerializer =
    _$WsEventRideCancelledCancelledByEnumSerializer();

class _$WsEventRideCancelledCancelledByEnumSerializer
    implements PrimitiveSerializer<WsEventRideCancelledCancelledByEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'passenger': 'passenger',
    'driver': 'driver',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'passenger': 'passenger',
    'driver': 'driver',
  };

  @override
  final Iterable<Type> types = const <Type>[
    WsEventRideCancelledCancelledByEnum,
  ];
  @override
  final String wireName = 'WsEventRideCancelledCancelledByEnum';

  @override
  Object serialize(
    Serializers serializers,
    WsEventRideCancelledCancelledByEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  WsEventRideCancelledCancelledByEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => WsEventRideCancelledCancelledByEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$WsEventRideCancelled extends WsEventRideCancelled {
  @override
  final String rideId;
  @override
  final WsEventRideCancelledCancelledByEnum cancelledBy;
  @override
  final String? reason;

  factory _$WsEventRideCancelled([
    void Function(WsEventRideCancelledBuilder)? updates,
  ]) => (WsEventRideCancelledBuilder()..update(updates))._build();

  _$WsEventRideCancelled._({
    required this.rideId,
    required this.cancelledBy,
    this.reason,
  }) : super._();
  @override
  WsEventRideCancelled rebuild(
    void Function(WsEventRideCancelledBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  WsEventRideCancelledBuilder toBuilder() =>
      WsEventRideCancelledBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WsEventRideCancelled &&
        rideId == other.rideId &&
        cancelledBy == other.cancelledBy &&
        reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, rideId.hashCode);
    _$hash = $jc(_$hash, cancelledBy.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'WsEventRideCancelled')
          ..add('rideId', rideId)
          ..add('cancelledBy', cancelledBy)
          ..add('reason', reason))
        .toString();
  }
}

class WsEventRideCancelledBuilder
    implements Builder<WsEventRideCancelled, WsEventRideCancelledBuilder> {
  _$WsEventRideCancelled? _$v;

  String? _rideId;
  String? get rideId => _$this._rideId;
  set rideId(String? rideId) => _$this._rideId = rideId;

  WsEventRideCancelledCancelledByEnum? _cancelledBy;
  WsEventRideCancelledCancelledByEnum? get cancelledBy => _$this._cancelledBy;
  set cancelledBy(WsEventRideCancelledCancelledByEnum? cancelledBy) =>
      _$this._cancelledBy = cancelledBy;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  WsEventRideCancelledBuilder() {
    WsEventRideCancelled._defaults(this);
  }

  WsEventRideCancelledBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _rideId = $v.rideId;
      _cancelledBy = $v.cancelledBy;
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WsEventRideCancelled other) {
    _$v = other as _$WsEventRideCancelled;
  }

  @override
  void update(void Function(WsEventRideCancelledBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WsEventRideCancelled build() => _build();

  _$WsEventRideCancelled _build() {
    final _$result =
        _$v ??
        _$WsEventRideCancelled._(
          rideId: BuiltValueNullFieldError.checkNotNull(
            rideId,
            r'WsEventRideCancelled',
            'rideId',
          ),
          cancelledBy: BuiltValueNullFieldError.checkNotNull(
            cancelledBy,
            r'WsEventRideCancelled',
            'cancelledBy',
          ),
          reason: reason,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

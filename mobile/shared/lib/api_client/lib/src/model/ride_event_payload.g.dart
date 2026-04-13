// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_event_payload.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const RideEventPayloadStatusEnum _$rideEventPayloadStatusEnum_requested =
    const RideEventPayloadStatusEnum._('requested');
const RideEventPayloadStatusEnum _$rideEventPayloadStatusEnum_accepted =
    const RideEventPayloadStatusEnum._('accepted');
const RideEventPayloadStatusEnum _$rideEventPayloadStatusEnum_arrived =
    const RideEventPayloadStatusEnum._('arrived');
const RideEventPayloadStatusEnum _$rideEventPayloadStatusEnum_inProgress =
    const RideEventPayloadStatusEnum._('inProgress');
const RideEventPayloadStatusEnum _$rideEventPayloadStatusEnum_completed =
    const RideEventPayloadStatusEnum._('completed');
const RideEventPayloadStatusEnum _$rideEventPayloadStatusEnum_cancelled =
    const RideEventPayloadStatusEnum._('cancelled');

RideEventPayloadStatusEnum _$rideEventPayloadStatusEnumValueOf(String name) {
  switch (name) {
    case 'requested':
      return _$rideEventPayloadStatusEnum_requested;
    case 'accepted':
      return _$rideEventPayloadStatusEnum_accepted;
    case 'arrived':
      return _$rideEventPayloadStatusEnum_arrived;
    case 'inProgress':
      return _$rideEventPayloadStatusEnum_inProgress;
    case 'completed':
      return _$rideEventPayloadStatusEnum_completed;
    case 'cancelled':
      return _$rideEventPayloadStatusEnum_cancelled;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<RideEventPayloadStatusEnum> _$rideEventPayloadStatusEnumValues =
    BuiltSet<RideEventPayloadStatusEnum>(const <RideEventPayloadStatusEnum>[
  _$rideEventPayloadStatusEnum_requested,
  _$rideEventPayloadStatusEnum_accepted,
  _$rideEventPayloadStatusEnum_arrived,
  _$rideEventPayloadStatusEnum_inProgress,
  _$rideEventPayloadStatusEnum_completed,
  _$rideEventPayloadStatusEnum_cancelled,
]);

Serializer<RideEventPayloadStatusEnum> _$rideEventPayloadStatusEnumSerializer =
    _$RideEventPayloadStatusEnumSerializer();

class _$RideEventPayloadStatusEnumSerializer
    implements PrimitiveSerializer<RideEventPayloadStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'requested': 'requested',
    'accepted': 'accepted',
    'arrived': 'arrived',
    'inProgress': 'in_progress',
    'completed': 'completed',
    'cancelled': 'cancelled',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'requested': 'requested',
    'accepted': 'accepted',
    'arrived': 'arrived',
    'in_progress': 'inProgress',
    'completed': 'completed',
    'cancelled': 'cancelled',
  };

  @override
  final Iterable<Type> types = const <Type>[RideEventPayloadStatusEnum];
  @override
  final String wireName = 'RideEventPayloadStatusEnum';

  @override
  Object serialize(Serializers serializers, RideEventPayloadStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  RideEventPayloadStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      RideEventPayloadStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$RideEventPayload extends RideEventPayload {
  @override
  final String? rideId;
  @override
  final RideEventPayloadStatusEnum? status;
  @override
  final String? driverId;
  @override
  final String? passengerId;

  factory _$RideEventPayload(
          [void Function(RideEventPayloadBuilder)? updates]) =>
      (RideEventPayloadBuilder()..update(updates))._build();

  _$RideEventPayload._(
      {this.rideId, this.status, this.driverId, this.passengerId})
      : super._();
  @override
  RideEventPayload rebuild(void Function(RideEventPayloadBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RideEventPayloadBuilder toBuilder() =>
      RideEventPayloadBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RideEventPayload &&
        rideId == other.rideId &&
        status == other.status &&
        driverId == other.driverId &&
        passengerId == other.passengerId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, rideId.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, driverId.hashCode);
    _$hash = $jc(_$hash, passengerId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RideEventPayload')
          ..add('rideId', rideId)
          ..add('status', status)
          ..add('driverId', driverId)
          ..add('passengerId', passengerId))
        .toString();
  }
}

class RideEventPayloadBuilder
    implements Builder<RideEventPayload, RideEventPayloadBuilder> {
  _$RideEventPayload? _$v;

  String? _rideId;
  String? get rideId => _$this._rideId;
  set rideId(String? rideId) => _$this._rideId = rideId;

  RideEventPayloadStatusEnum? _status;
  RideEventPayloadStatusEnum? get status => _$this._status;
  set status(RideEventPayloadStatusEnum? status) => _$this._status = status;

  String? _driverId;
  String? get driverId => _$this._driverId;
  set driverId(String? driverId) => _$this._driverId = driverId;

  String? _passengerId;
  String? get passengerId => _$this._passengerId;
  set passengerId(String? passengerId) => _$this._passengerId = passengerId;

  RideEventPayloadBuilder() {
    RideEventPayload._defaults(this);
  }

  RideEventPayloadBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _rideId = $v.rideId;
      _status = $v.status;
      _driverId = $v.driverId;
      _passengerId = $v.passengerId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RideEventPayload other) {
    _$v = other as _$RideEventPayload;
  }

  @override
  void update(void Function(RideEventPayloadBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RideEventPayload build() => _build();

  _$RideEventPayload _build() {
    final _$result = _$v ??
        _$RideEventPayload._(
          rideId: rideId,
          status: status,
          driverId: driverId,
          passengerId: passengerId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_event_payload.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RideEventPayload extends RideEventPayload {
  @override
  final String? rideId;
  @override
  final RideStatus? status;
  @override
  final String? driverId;
  @override
  final String? passengerId;

  factory _$RideEventPayload([
    void Function(RideEventPayloadBuilder)? updates,
  ]) => (RideEventPayloadBuilder()..update(updates))._build();

  _$RideEventPayload._({
    this.rideId,
    this.status,
    this.driverId,
    this.passengerId,
  }) : super._();
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

  RideStatus? _status;
  RideStatus? get status => _$this._status;
  set status(RideStatus? status) => _$this._status = status;

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
    final _$result =
        _$v ??
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

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ws_event_ride_state_sync.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$WsEventRideStateSync extends WsEventRideStateSync {
  @override
  final bool hasActiveRide;
  @override
  final String? rideId;
  @override
  final RideStatus? status;
  @override
  final String? driverId;
  @override
  final String? passengerId;
  @override
  final DateTime? updatedAt;

  factory _$WsEventRideStateSync([
    void Function(WsEventRideStateSyncBuilder)? updates,
  ]) => (WsEventRideStateSyncBuilder()..update(updates))._build();

  _$WsEventRideStateSync._({
    required this.hasActiveRide,
    this.rideId,
    this.status,
    this.driverId,
    this.passengerId,
    this.updatedAt,
  }) : super._();
  @override
  WsEventRideStateSync rebuild(
    void Function(WsEventRideStateSyncBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  WsEventRideStateSyncBuilder toBuilder() =>
      WsEventRideStateSyncBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WsEventRideStateSync &&
        hasActiveRide == other.hasActiveRide &&
        rideId == other.rideId &&
        status == other.status &&
        driverId == other.driverId &&
        passengerId == other.passengerId &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, hasActiveRide.hashCode);
    _$hash = $jc(_$hash, rideId.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, driverId.hashCode);
    _$hash = $jc(_$hash, passengerId.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'WsEventRideStateSync')
          ..add('hasActiveRide', hasActiveRide)
          ..add('rideId', rideId)
          ..add('status', status)
          ..add('driverId', driverId)
          ..add('passengerId', passengerId)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class WsEventRideStateSyncBuilder
    implements Builder<WsEventRideStateSync, WsEventRideStateSyncBuilder> {
  _$WsEventRideStateSync? _$v;

  bool? _hasActiveRide;
  bool? get hasActiveRide => _$this._hasActiveRide;
  set hasActiveRide(bool? hasActiveRide) =>
      _$this._hasActiveRide = hasActiveRide;

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

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  WsEventRideStateSyncBuilder() {
    WsEventRideStateSync._defaults(this);
  }

  WsEventRideStateSyncBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _hasActiveRide = $v.hasActiveRide;
      _rideId = $v.rideId;
      _status = $v.status;
      _driverId = $v.driverId;
      _passengerId = $v.passengerId;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WsEventRideStateSync other) {
    _$v = other as _$WsEventRideStateSync;
  }

  @override
  void update(void Function(WsEventRideStateSyncBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WsEventRideStateSync build() => _build();

  _$WsEventRideStateSync _build() {
    final _$result =
        _$v ??
        _$WsEventRideStateSync._(
          hasActiveRide: BuiltValueNullFieldError.checkNotNull(
            hasActiveRide,
            r'WsEventRideStateSync',
            'hasActiveRide',
          ),
          rideId: rideId,
          status: status,
          driverId: driverId,
          passengerId: passengerId,
          updatedAt: updatedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

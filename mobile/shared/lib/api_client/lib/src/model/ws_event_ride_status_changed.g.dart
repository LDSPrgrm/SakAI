// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ws_event_ride_status_changed.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$WsEventRideStatusChanged extends WsEventRideStatusChanged {
  @override
  final String rideId;
  @override
  final RideStatus status;
  @override
  final DateTime updatedAt;

  factory _$WsEventRideStatusChanged(
          [void Function(WsEventRideStatusChangedBuilder)? updates]) =>
      (WsEventRideStatusChangedBuilder()..update(updates))._build();

  _$WsEventRideStatusChanged._(
      {required this.rideId, required this.status, required this.updatedAt})
      : super._();
  @override
  WsEventRideStatusChanged rebuild(
          void Function(WsEventRideStatusChangedBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WsEventRideStatusChangedBuilder toBuilder() =>
      WsEventRideStatusChangedBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WsEventRideStatusChanged &&
        rideId == other.rideId &&
        status == other.status &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, rideId.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'WsEventRideStatusChanged')
          ..add('rideId', rideId)
          ..add('status', status)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class WsEventRideStatusChangedBuilder
    implements
        Builder<WsEventRideStatusChanged, WsEventRideStatusChangedBuilder> {
  _$WsEventRideStatusChanged? _$v;

  String? _rideId;
  String? get rideId => _$this._rideId;
  set rideId(String? rideId) => _$this._rideId = rideId;

  RideStatus? _status;
  RideStatus? get status => _$this._status;
  set status(RideStatus? status) => _$this._status = status;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  WsEventRideStatusChangedBuilder() {
    WsEventRideStatusChanged._defaults(this);
  }

  WsEventRideStatusChangedBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _rideId = $v.rideId;
      _status = $v.status;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WsEventRideStatusChanged other) {
    _$v = other as _$WsEventRideStatusChanged;
  }

  @override
  void update(void Function(WsEventRideStatusChangedBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WsEventRideStatusChanged build() => _build();

  _$WsEventRideStatusChanged _build() {
    final _$result = _$v ??
        _$WsEventRideStatusChanged._(
          rideId: BuiltValueNullFieldError.checkNotNull(
              rideId, r'WsEventRideStatusChanged', 'rideId'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'WsEventRideStatusChanged', 'status'),
          updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt, r'WsEventRideStatusChanged', 'updatedAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

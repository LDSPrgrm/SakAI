// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ws_event_ride_accepted.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$WsEventRideAccepted extends WsEventRideAccepted {
  @override
  final String rideId;
  @override
  final DriverSummary driver;

  factory _$WsEventRideAccepted(
          [void Function(WsEventRideAcceptedBuilder)? updates]) =>
      (WsEventRideAcceptedBuilder()..update(updates))._build();

  _$WsEventRideAccepted._({required this.rideId, required this.driver})
      : super._();
  @override
  WsEventRideAccepted rebuild(
          void Function(WsEventRideAcceptedBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WsEventRideAcceptedBuilder toBuilder() =>
      WsEventRideAcceptedBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WsEventRideAccepted &&
        rideId == other.rideId &&
        driver == other.driver;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, rideId.hashCode);
    _$hash = $jc(_$hash, driver.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'WsEventRideAccepted')
          ..add('rideId', rideId)
          ..add('driver', driver))
        .toString();
  }
}

class WsEventRideAcceptedBuilder
    implements Builder<WsEventRideAccepted, WsEventRideAcceptedBuilder> {
  _$WsEventRideAccepted? _$v;

  String? _rideId;
  String? get rideId => _$this._rideId;
  set rideId(String? rideId) => _$this._rideId = rideId;

  DriverSummaryBuilder? _driver;
  DriverSummaryBuilder get driver => _$this._driver ??= DriverSummaryBuilder();
  set driver(DriverSummaryBuilder? driver) => _$this._driver = driver;

  WsEventRideAcceptedBuilder() {
    WsEventRideAccepted._defaults(this);
  }

  WsEventRideAcceptedBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _rideId = $v.rideId;
      _driver = $v.driver.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WsEventRideAccepted other) {
    _$v = other as _$WsEventRideAccepted;
  }

  @override
  void update(void Function(WsEventRideAcceptedBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WsEventRideAccepted build() => _build();

  _$WsEventRideAccepted _build() {
    _$WsEventRideAccepted _$result;
    try {
      _$result = _$v ??
          _$WsEventRideAccepted._(
            rideId: BuiltValueNullFieldError.checkNotNull(
                rideId, r'WsEventRideAccepted', 'rideId'),
            driver: driver.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'driver';
        driver.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'WsEventRideAccepted', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

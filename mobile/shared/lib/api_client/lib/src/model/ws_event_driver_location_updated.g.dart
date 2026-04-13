// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ws_event_driver_location_updated.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$WsEventDriverLocationUpdated extends WsEventDriverLocationUpdated {
  @override
  final String rideId;
  @override
  final LatLng location;
  @override
  final double? heading;

  factory _$WsEventDriverLocationUpdated(
          [void Function(WsEventDriverLocationUpdatedBuilder)? updates]) =>
      (WsEventDriverLocationUpdatedBuilder()..update(updates))._build();

  _$WsEventDriverLocationUpdated._(
      {required this.rideId, required this.location, this.heading})
      : super._();
  @override
  WsEventDriverLocationUpdated rebuild(
          void Function(WsEventDriverLocationUpdatedBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WsEventDriverLocationUpdatedBuilder toBuilder() =>
      WsEventDriverLocationUpdatedBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WsEventDriverLocationUpdated &&
        rideId == other.rideId &&
        location == other.location &&
        heading == other.heading;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, rideId.hashCode);
    _$hash = $jc(_$hash, location.hashCode);
    _$hash = $jc(_$hash, heading.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'WsEventDriverLocationUpdated')
          ..add('rideId', rideId)
          ..add('location', location)
          ..add('heading', heading))
        .toString();
  }
}

class WsEventDriverLocationUpdatedBuilder
    implements
        Builder<WsEventDriverLocationUpdated,
            WsEventDriverLocationUpdatedBuilder> {
  _$WsEventDriverLocationUpdated? _$v;

  String? _rideId;
  String? get rideId => _$this._rideId;
  set rideId(String? rideId) => _$this._rideId = rideId;

  LatLngBuilder? _location;
  LatLngBuilder get location => _$this._location ??= LatLngBuilder();
  set location(LatLngBuilder? location) => _$this._location = location;

  double? _heading;
  double? get heading => _$this._heading;
  set heading(double? heading) => _$this._heading = heading;

  WsEventDriverLocationUpdatedBuilder() {
    WsEventDriverLocationUpdated._defaults(this);
  }

  WsEventDriverLocationUpdatedBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _rideId = $v.rideId;
      _location = $v.location.toBuilder();
      _heading = $v.heading;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WsEventDriverLocationUpdated other) {
    _$v = other as _$WsEventDriverLocationUpdated;
  }

  @override
  void update(void Function(WsEventDriverLocationUpdatedBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WsEventDriverLocationUpdated build() => _build();

  _$WsEventDriverLocationUpdated _build() {
    _$WsEventDriverLocationUpdated _$result;
    try {
      _$result = _$v ??
          _$WsEventDriverLocationUpdated._(
            rideId: BuiltValueNullFieldError.checkNotNull(
                rideId, r'WsEventDriverLocationUpdated', 'rideId'),
            location: location.build(),
            heading: heading,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'location';
        location.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'WsEventDriverLocationUpdated', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

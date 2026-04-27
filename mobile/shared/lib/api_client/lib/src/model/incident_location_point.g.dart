// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'incident_location_point.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$IncidentLocationPoint extends IncidentLocationPoint {
  @override
  final double lat;
  @override
  final double lng;
  @override
  final DateTime recordedAt;

  factory _$IncidentLocationPoint([
    void Function(IncidentLocationPointBuilder)? updates,
  ]) => (IncidentLocationPointBuilder()..update(updates))._build();

  _$IncidentLocationPoint._({
    required this.lat,
    required this.lng,
    required this.recordedAt,
  }) : super._();
  @override
  IncidentLocationPoint rebuild(
    void Function(IncidentLocationPointBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  IncidentLocationPointBuilder toBuilder() =>
      IncidentLocationPointBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is IncidentLocationPoint &&
        lat == other.lat &&
        lng == other.lng &&
        recordedAt == other.recordedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, lat.hashCode);
    _$hash = $jc(_$hash, lng.hashCode);
    _$hash = $jc(_$hash, recordedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'IncidentLocationPoint')
          ..add('lat', lat)
          ..add('lng', lng)
          ..add('recordedAt', recordedAt))
        .toString();
  }
}

class IncidentLocationPointBuilder
    implements Builder<IncidentLocationPoint, IncidentLocationPointBuilder> {
  _$IncidentLocationPoint? _$v;

  double? _lat;
  double? get lat => _$this._lat;
  set lat(double? lat) => _$this._lat = lat;

  double? _lng;
  double? get lng => _$this._lng;
  set lng(double? lng) => _$this._lng = lng;

  DateTime? _recordedAt;
  DateTime? get recordedAt => _$this._recordedAt;
  set recordedAt(DateTime? recordedAt) => _$this._recordedAt = recordedAt;

  IncidentLocationPointBuilder() {
    IncidentLocationPoint._defaults(this);
  }

  IncidentLocationPointBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _lat = $v.lat;
      _lng = $v.lng;
      _recordedAt = $v.recordedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(IncidentLocationPoint other) {
    _$v = other as _$IncidentLocationPoint;
  }

  @override
  void update(void Function(IncidentLocationPointBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  IncidentLocationPoint build() => _build();

  _$IncidentLocationPoint _build() {
    final _$result =
        _$v ??
        _$IncidentLocationPoint._(
          lat: BuiltValueNullFieldError.checkNotNull(
            lat,
            r'IncidentLocationPoint',
            'lat',
          ),
          lng: BuiltValueNullFieldError.checkNotNull(
            lng,
            r'IncidentLocationPoint',
            'lng',
          ),
          recordedAt: BuiltValueNullFieldError.checkNotNull(
            recordedAt,
            r'IncidentLocationPoint',
            'recordedAt',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

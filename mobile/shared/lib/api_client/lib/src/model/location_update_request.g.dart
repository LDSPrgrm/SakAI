// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_update_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$LocationUpdateRequest extends LocationUpdateRequest {
  @override
  final LatLng location;
  @override
  final double? heading;

  factory _$LocationUpdateRequest(
          [void Function(LocationUpdateRequestBuilder)? updates]) =>
      (LocationUpdateRequestBuilder()..update(updates))._build();

  _$LocationUpdateRequest._({required this.location, this.heading}) : super._();
  @override
  LocationUpdateRequest rebuild(
          void Function(LocationUpdateRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  LocationUpdateRequestBuilder toBuilder() =>
      LocationUpdateRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is LocationUpdateRequest &&
        location == other.location &&
        heading == other.heading;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, location.hashCode);
    _$hash = $jc(_$hash, heading.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'LocationUpdateRequest')
          ..add('location', location)
          ..add('heading', heading))
        .toString();
  }
}

class LocationUpdateRequestBuilder
    implements Builder<LocationUpdateRequest, LocationUpdateRequestBuilder> {
  _$LocationUpdateRequest? _$v;

  LatLngBuilder? _location;
  LatLngBuilder get location => _$this._location ??= LatLngBuilder();
  set location(LatLngBuilder? location) => _$this._location = location;

  double? _heading;
  double? get heading => _$this._heading;
  set heading(double? heading) => _$this._heading = heading;

  LocationUpdateRequestBuilder() {
    LocationUpdateRequest._defaults(this);
  }

  LocationUpdateRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _location = $v.location.toBuilder();
      _heading = $v.heading;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(LocationUpdateRequest other) {
    _$v = other as _$LocationUpdateRequest;
  }

  @override
  void update(void Function(LocationUpdateRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  LocationUpdateRequest build() => _build();

  _$LocationUpdateRequest _build() {
    _$LocationUpdateRequest _$result;
    try {
      _$result = _$v ??
          _$LocationUpdateRequest._(
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
            r'LocationUpdateRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

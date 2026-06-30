// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_complete_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RideCompleteRequest extends RideCompleteRequest {
  @override
  final LatLng driverLocation;

  factory _$RideCompleteRequest([
    void Function(RideCompleteRequestBuilder)? updates,
  ]) => (RideCompleteRequestBuilder()..update(updates))._build();

  _$RideCompleteRequest._({required this.driverLocation}) : super._();
  @override
  RideCompleteRequest rebuild(
    void Function(RideCompleteRequestBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  RideCompleteRequestBuilder toBuilder() =>
      RideCompleteRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RideCompleteRequest &&
        driverLocation == other.driverLocation;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, driverLocation.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'RideCompleteRequest',
    )..add('driverLocation', driverLocation)).toString();
  }
}

class RideCompleteRequestBuilder
    implements Builder<RideCompleteRequest, RideCompleteRequestBuilder> {
  _$RideCompleteRequest? _$v;

  LatLngBuilder? _driverLocation;
  LatLngBuilder get driverLocation =>
      _$this._driverLocation ??= LatLngBuilder();
  set driverLocation(LatLngBuilder? driverLocation) =>
      _$this._driverLocation = driverLocation;

  RideCompleteRequestBuilder() {
    RideCompleteRequest._defaults(this);
  }

  RideCompleteRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _driverLocation = $v.driverLocation.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RideCompleteRequest other) {
    _$v = other as _$RideCompleteRequest;
  }

  @override
  void update(void Function(RideCompleteRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RideCompleteRequest build() => _build();

  _$RideCompleteRequest _build() {
    _$RideCompleteRequest _$result;
    try {
      _$result =
          _$v ??
          _$RideCompleteRequest._(driverLocation: driverLocation.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'driverLocation';
        driverLocation.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'RideCompleteRequest',
          _$failedField,
          e.toString(),
        );
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

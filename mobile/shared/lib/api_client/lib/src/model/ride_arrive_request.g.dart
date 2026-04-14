// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_arrive_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RideArriveRequest extends RideArriveRequest {
  @override
  final LatLng driverLocation;

  factory _$RideArriveRequest([
    void Function(RideArriveRequestBuilder)? updates,
  ]) => (RideArriveRequestBuilder()..update(updates))._build();

  _$RideArriveRequest._({required this.driverLocation}) : super._();
  @override
  RideArriveRequest rebuild(void Function(RideArriveRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RideArriveRequestBuilder toBuilder() =>
      RideArriveRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RideArriveRequest && driverLocation == other.driverLocation;
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
      r'RideArriveRequest',
    )..add('driverLocation', driverLocation)).toString();
  }
}

class RideArriveRequestBuilder
    implements Builder<RideArriveRequest, RideArriveRequestBuilder> {
  _$RideArriveRequest? _$v;

  LatLngBuilder? _driverLocation;
  LatLngBuilder get driverLocation =>
      _$this._driverLocation ??= LatLngBuilder();
  set driverLocation(LatLngBuilder? driverLocation) =>
      _$this._driverLocation = driverLocation;

  RideArriveRequestBuilder() {
    RideArriveRequest._defaults(this);
  }

  RideArriveRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _driverLocation = $v.driverLocation.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RideArriveRequest other) {
    _$v = other as _$RideArriveRequest;
  }

  @override
  void update(void Function(RideArriveRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RideArriveRequest build() => _build();

  _$RideArriveRequest _build() {
    _$RideArriveRequest _$result;
    try {
      _$result =
          _$v ?? _$RideArriveRequest._(driverLocation: driverLocation.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'driverLocation';
        driverLocation.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'RideArriveRequest',
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

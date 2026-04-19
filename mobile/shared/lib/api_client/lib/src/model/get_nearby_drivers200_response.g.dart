// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_nearby_drivers200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetNearbyDrivers200Response extends GetNearbyDrivers200Response {
  @override
  final BuiltList<NearbyDriver>? drivers;

  factory _$GetNearbyDrivers200Response([
    void Function(GetNearbyDrivers200ResponseBuilder)? updates,
  ]) => (GetNearbyDrivers200ResponseBuilder()..update(updates))._build();

  _$GetNearbyDrivers200Response._({this.drivers}) : super._();
  @override
  GetNearbyDrivers200Response rebuild(
    void Function(GetNearbyDrivers200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GetNearbyDrivers200ResponseBuilder toBuilder() =>
      GetNearbyDrivers200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetNearbyDrivers200Response && drivers == other.drivers;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, drivers.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'GetNearbyDrivers200Response',
    )..add('drivers', drivers)).toString();
  }
}

class GetNearbyDrivers200ResponseBuilder
    implements
        Builder<
          GetNearbyDrivers200Response,
          GetNearbyDrivers200ResponseBuilder
        > {
  _$GetNearbyDrivers200Response? _$v;

  ListBuilder<NearbyDriver>? _drivers;
  ListBuilder<NearbyDriver> get drivers =>
      _$this._drivers ??= ListBuilder<NearbyDriver>();
  set drivers(ListBuilder<NearbyDriver>? drivers) => _$this._drivers = drivers;

  GetNearbyDrivers200ResponseBuilder() {
    GetNearbyDrivers200Response._defaults(this);
  }

  GetNearbyDrivers200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _drivers = $v.drivers?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetNearbyDrivers200Response other) {
    _$v = other as _$GetNearbyDrivers200Response;
  }

  @override
  void update(void Function(GetNearbyDrivers200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetNearbyDrivers200Response build() => _build();

  _$GetNearbyDrivers200Response _build() {
    _$GetNearbyDrivers200Response _$result;
    try {
      _$result =
          _$v ?? _$GetNearbyDrivers200Response._(drivers: _drivers?.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'drivers';
        _drivers?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'GetNearbyDrivers200Response',
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

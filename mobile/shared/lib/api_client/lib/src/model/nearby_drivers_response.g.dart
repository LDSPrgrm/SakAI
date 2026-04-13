// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nearby_drivers_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$NearbyDriversResponse extends NearbyDriversResponse {
  @override
  final BuiltList<NearbyDriver>? drivers;

  factory _$NearbyDriversResponse(
          [void Function(NearbyDriversResponseBuilder)? updates]) =>
      (NearbyDriversResponseBuilder()..update(updates))._build();

  _$NearbyDriversResponse._({this.drivers}) : super._();
  @override
  NearbyDriversResponse rebuild(
          void Function(NearbyDriversResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  NearbyDriversResponseBuilder toBuilder() =>
      NearbyDriversResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NearbyDriversResponse && drivers == other.drivers;
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
    return (newBuiltValueToStringHelper(r'NearbyDriversResponse')
          ..add('drivers', drivers))
        .toString();
  }
}

class NearbyDriversResponseBuilder
    implements Builder<NearbyDriversResponse, NearbyDriversResponseBuilder> {
  _$NearbyDriversResponse? _$v;

  ListBuilder<NearbyDriver>? _drivers;
  ListBuilder<NearbyDriver> get drivers =>
      _$this._drivers ??= ListBuilder<NearbyDriver>();
  set drivers(ListBuilder<NearbyDriver>? drivers) => _$this._drivers = drivers;

  NearbyDriversResponseBuilder() {
    NearbyDriversResponse._defaults(this);
  }

  NearbyDriversResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _drivers = $v.drivers?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(NearbyDriversResponse other) {
    _$v = other as _$NearbyDriversResponse;
  }

  @override
  void update(void Function(NearbyDriversResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  NearbyDriversResponse build() => _build();

  _$NearbyDriversResponse _build() {
    _$NearbyDriversResponse _$result;
    try {
      _$result = _$v ??
          _$NearbyDriversResponse._(
            drivers: _drivers?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'drivers';
        _drivers?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'NearbyDriversResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

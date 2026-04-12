// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_area_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ServiceAreaResponse extends ServiceAreaResponse {
  @override
  final BuiltList<ServiceArea>? areas;

  factory _$ServiceAreaResponse([
    void Function(ServiceAreaResponseBuilder)? updates,
  ]) => (ServiceAreaResponseBuilder()..update(updates))._build();

  _$ServiceAreaResponse._({this.areas}) : super._();
  @override
  ServiceAreaResponse rebuild(
    void Function(ServiceAreaResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ServiceAreaResponseBuilder toBuilder() =>
      ServiceAreaResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ServiceAreaResponse && areas == other.areas;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, areas.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'ServiceAreaResponse',
    )..add('areas', areas)).toString();
  }
}

class ServiceAreaResponseBuilder
    implements Builder<ServiceAreaResponse, ServiceAreaResponseBuilder> {
  _$ServiceAreaResponse? _$v;

  ListBuilder<ServiceArea>? _areas;
  ListBuilder<ServiceArea> get areas =>
      _$this._areas ??= ListBuilder<ServiceArea>();
  set areas(ListBuilder<ServiceArea>? areas) => _$this._areas = areas;

  ServiceAreaResponseBuilder() {
    ServiceAreaResponse._defaults(this);
  }

  ServiceAreaResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _areas = $v.areas?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ServiceAreaResponse other) {
    _$v = other as _$ServiceAreaResponse;
  }

  @override
  void update(void Function(ServiceAreaResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ServiceAreaResponse build() => _build();

  _$ServiceAreaResponse _build() {
    _$ServiceAreaResponse _$result;
    try {
      _$result = _$v ?? _$ServiceAreaResponse._(areas: _areas?.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'areas';
        _areas?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'ServiceAreaResponse',
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

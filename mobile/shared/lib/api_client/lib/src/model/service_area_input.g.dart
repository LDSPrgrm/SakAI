// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_area_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ServiceAreaInput extends ServiceAreaInput {
  @override
  final String name;
  @override
  final String? lguCode;
  @override
  final SurgeZone boundary;
  @override
  final bool? active;

  factory _$ServiceAreaInput([
    void Function(ServiceAreaInputBuilder)? updates,
  ]) => (ServiceAreaInputBuilder()..update(updates))._build();

  _$ServiceAreaInput._({
    required this.name,
    this.lguCode,
    required this.boundary,
    this.active,
  }) : super._();
  @override
  ServiceAreaInput rebuild(void Function(ServiceAreaInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ServiceAreaInputBuilder toBuilder() =>
      ServiceAreaInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ServiceAreaInput &&
        name == other.name &&
        lguCode == other.lguCode &&
        boundary == other.boundary &&
        active == other.active;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, lguCode.hashCode);
    _$hash = $jc(_$hash, boundary.hashCode);
    _$hash = $jc(_$hash, active.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ServiceAreaInput')
          ..add('name', name)
          ..add('lguCode', lguCode)
          ..add('boundary', boundary)
          ..add('active', active))
        .toString();
  }
}

class ServiceAreaInputBuilder
    implements Builder<ServiceAreaInput, ServiceAreaInputBuilder> {
  _$ServiceAreaInput? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _lguCode;
  String? get lguCode => _$this._lguCode;
  set lguCode(String? lguCode) => _$this._lguCode = lguCode;

  SurgeZoneBuilder? _boundary;
  SurgeZoneBuilder get boundary => _$this._boundary ??= SurgeZoneBuilder();
  set boundary(SurgeZoneBuilder? boundary) => _$this._boundary = boundary;

  bool? _active;
  bool? get active => _$this._active;
  set active(bool? active) => _$this._active = active;

  ServiceAreaInputBuilder() {
    ServiceAreaInput._defaults(this);
  }

  ServiceAreaInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _lguCode = $v.lguCode;
      _boundary = $v.boundary.toBuilder();
      _active = $v.active;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ServiceAreaInput other) {
    _$v = other as _$ServiceAreaInput;
  }

  @override
  void update(void Function(ServiceAreaInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ServiceAreaInput build() => _build();

  _$ServiceAreaInput _build() {
    _$ServiceAreaInput _$result;
    try {
      _$result =
          _$v ??
          _$ServiceAreaInput._(
            name: BuiltValueNullFieldError.checkNotNull(
              name,
              r'ServiceAreaInput',
              'name',
            ),
            lguCode: lguCode,
            boundary: boundary.build(),
            active: active,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'boundary';
        boundary.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'ServiceAreaInput',
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

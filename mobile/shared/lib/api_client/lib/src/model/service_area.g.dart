// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_area.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ServiceArea extends ServiceArea {
  @override
  final String id;
  @override
  final String name;
  @override
  final String? lguCode;
  @override
  final SurgeZone boundary;
  @override
  final bool active;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  factory _$ServiceArea([void Function(ServiceAreaBuilder)? updates]) =>
      (ServiceAreaBuilder()..update(updates))._build();

  _$ServiceArea._({
    required this.id,
    required this.name,
    this.lguCode,
    required this.boundary,
    required this.active,
    this.createdAt,
    this.updatedAt,
  }) : super._();
  @override
  ServiceArea rebuild(void Function(ServiceAreaBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ServiceAreaBuilder toBuilder() => ServiceAreaBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ServiceArea &&
        id == other.id &&
        name == other.name &&
        lguCode == other.lguCode &&
        boundary == other.boundary &&
        active == other.active &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, lguCode.hashCode);
    _$hash = $jc(_$hash, boundary.hashCode);
    _$hash = $jc(_$hash, active.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ServiceArea')
          ..add('id', id)
          ..add('name', name)
          ..add('lguCode', lguCode)
          ..add('boundary', boundary)
          ..add('active', active)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class ServiceAreaBuilder implements Builder<ServiceArea, ServiceAreaBuilder> {
  _$ServiceArea? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

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

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  ServiceAreaBuilder() {
    ServiceArea._defaults(this);
  }

  ServiceAreaBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _lguCode = $v.lguCode;
      _boundary = $v.boundary.toBuilder();
      _active = $v.active;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ServiceArea other) {
    _$v = other as _$ServiceArea;
  }

  @override
  void update(void Function(ServiceAreaBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ServiceArea build() => _build();

  _$ServiceArea _build() {
    _$ServiceArea _$result;
    try {
      _$result =
          _$v ??
          _$ServiceArea._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'ServiceArea', 'id'),
            name: BuiltValueNullFieldError.checkNotNull(
              name,
              r'ServiceArea',
              'name',
            ),
            lguCode: lguCode,
            boundary: boundary.build(),
            active: BuiltValueNullFieldError.checkNotNull(
              active,
              r'ServiceArea',
              'active',
            ),
            createdAt: createdAt,
            updatedAt: updatedAt,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'boundary';
        boundary.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'ServiceArea',
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

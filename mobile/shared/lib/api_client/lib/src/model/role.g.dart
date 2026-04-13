// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'role.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const RoleNameEnum _$roleNameEnum_passenger = const RoleNameEnum._('passenger');
const RoleNameEnum _$roleNameEnum_driver = const RoleNameEnum._('driver');
const RoleNameEnum _$roleNameEnum_admin = const RoleNameEnum._('admin');
const RoleNameEnum _$roleNameEnum_superadmin =
    const RoleNameEnum._('superadmin');

RoleNameEnum _$roleNameEnumValueOf(String name) {
  switch (name) {
    case 'passenger':
      return _$roleNameEnum_passenger;
    case 'driver':
      return _$roleNameEnum_driver;
    case 'admin':
      return _$roleNameEnum_admin;
    case 'superadmin':
      return _$roleNameEnum_superadmin;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<RoleNameEnum> _$roleNameEnumValues =
    BuiltSet<RoleNameEnum>(const <RoleNameEnum>[
  _$roleNameEnum_passenger,
  _$roleNameEnum_driver,
  _$roleNameEnum_admin,
  _$roleNameEnum_superadmin,
]);

Serializer<RoleNameEnum> _$roleNameEnumSerializer = _$RoleNameEnumSerializer();

class _$RoleNameEnumSerializer implements PrimitiveSerializer<RoleNameEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'passenger': 'passenger',
    'driver': 'driver',
    'admin': 'admin',
    'superadmin': 'superadmin',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'passenger': 'passenger',
    'driver': 'driver',
    'admin': 'admin',
    'superadmin': 'superadmin',
  };

  @override
  final Iterable<Type> types = const <Type>[RoleNameEnum];
  @override
  final String wireName = 'RoleNameEnum';

  @override
  Object serialize(Serializers serializers, RoleNameEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  RoleNameEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      RoleNameEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$Role extends Role {
  @override
  final String id;
  @override
  final RoleNameEnum name;
  @override
  final BuiltList<RolePermission> permissions;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  factory _$Role([void Function(RoleBuilder)? updates]) =>
      (RoleBuilder()..update(updates))._build();

  _$Role._(
      {required this.id,
      required this.name,
      required this.permissions,
      this.createdAt,
      this.updatedAt})
      : super._();
  @override
  Role rebuild(void Function(RoleBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RoleBuilder toBuilder() => RoleBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Role &&
        id == other.id &&
        name == other.name &&
        permissions == other.permissions &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, permissions.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Role')
          ..add('id', id)
          ..add('name', name)
          ..add('permissions', permissions)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class RoleBuilder implements Builder<Role, RoleBuilder> {
  _$Role? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  RoleNameEnum? _name;
  RoleNameEnum? get name => _$this._name;
  set name(RoleNameEnum? name) => _$this._name = name;

  ListBuilder<RolePermission>? _permissions;
  ListBuilder<RolePermission> get permissions =>
      _$this._permissions ??= ListBuilder<RolePermission>();
  set permissions(ListBuilder<RolePermission>? permissions) =>
      _$this._permissions = permissions;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  RoleBuilder() {
    Role._defaults(this);
  }

  RoleBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _permissions = $v.permissions.toBuilder();
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Role other) {
    _$v = other as _$Role;
  }

  @override
  void update(void Function(RoleBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Role build() => _build();

  _$Role _build() {
    _$Role _$result;
    try {
      _$result = _$v ??
          _$Role._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'Role', 'id'),
            name: BuiltValueNullFieldError.checkNotNull(name, r'Role', 'name'),
            permissions: permissions.build(),
            createdAt: createdAt,
            updatedAt: updatedAt,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'permissions';
        permissions.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(r'Role', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'role.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Role extends Role {
  @override
  final String id;
  @override
  final String name;
  @override
  final String? description;
  @override
  final bool? isSystem;
  @override
  final BuiltList<RolePermission> permissions;
  @override
  final int? adminCount;
  @override
  final String? createdBy;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  factory _$Role([void Function(RoleBuilder)? updates]) =>
      (RoleBuilder()..update(updates))._build();

  _$Role._({
    required this.id,
    required this.name,
    this.description,
    this.isSystem,
    required this.permissions,
    this.adminCount,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  }) : super._();
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
        description == other.description &&
        isSystem == other.isSystem &&
        permissions == other.permissions &&
        adminCount == other.adminCount &&
        createdBy == other.createdBy &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, isSystem.hashCode);
    _$hash = $jc(_$hash, permissions.hashCode);
    _$hash = $jc(_$hash, adminCount.hashCode);
    _$hash = $jc(_$hash, createdBy.hashCode);
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
          ..add('description', description)
          ..add('isSystem', isSystem)
          ..add('permissions', permissions)
          ..add('adminCount', adminCount)
          ..add('createdBy', createdBy)
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

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  bool? _isSystem;
  bool? get isSystem => _$this._isSystem;
  set isSystem(bool? isSystem) => _$this._isSystem = isSystem;

  ListBuilder<RolePermission>? _permissions;
  ListBuilder<RolePermission> get permissions =>
      _$this._permissions ??= ListBuilder<RolePermission>();
  set permissions(ListBuilder<RolePermission>? permissions) =>
      _$this._permissions = permissions;

  int? _adminCount;
  int? get adminCount => _$this._adminCount;
  set adminCount(int? adminCount) => _$this._adminCount = adminCount;

  String? _createdBy;
  String? get createdBy => _$this._createdBy;
  set createdBy(String? createdBy) => _$this._createdBy = createdBy;

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
      _description = $v.description;
      _isSystem = $v.isSystem;
      _permissions = $v.permissions.toBuilder();
      _adminCount = $v.adminCount;
      _createdBy = $v.createdBy;
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
      _$result =
          _$v ??
          _$Role._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'Role', 'id'),
            name: BuiltValueNullFieldError.checkNotNull(name, r'Role', 'name'),
            description: description,
            isSystem: isSystem,
            permissions: permissions.build(),
            adminCount: adminCount,
            createdBy: createdBy,
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

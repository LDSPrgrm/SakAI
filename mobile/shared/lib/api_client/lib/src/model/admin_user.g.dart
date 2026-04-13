// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_user.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminUserRoleEnum _$adminUserRoleEnum_passenger =
    const AdminUserRoleEnum._('passenger');
const AdminUserRoleEnum _$adminUserRoleEnum_driver =
    const AdminUserRoleEnum._('driver');

AdminUserRoleEnum _$adminUserRoleEnumValueOf(String name) {
  switch (name) {
    case 'passenger':
      return _$adminUserRoleEnum_passenger;
    case 'driver':
      return _$adminUserRoleEnum_driver;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<AdminUserRoleEnum> _$adminUserRoleEnumValues =
    BuiltSet<AdminUserRoleEnum>(const <AdminUserRoleEnum>[
  _$adminUserRoleEnum_passenger,
  _$adminUserRoleEnum_driver,
]);

const AdminUserStatusEnum _$adminUserStatusEnum_active =
    const AdminUserStatusEnum._('active');
const AdminUserStatusEnum _$adminUserStatusEnum_suspended =
    const AdminUserStatusEnum._('suspended');
const AdminUserStatusEnum _$adminUserStatusEnum_deactivated =
    const AdminUserStatusEnum._('deactivated');

AdminUserStatusEnum _$adminUserStatusEnumValueOf(String name) {
  switch (name) {
    case 'active':
      return _$adminUserStatusEnum_active;
    case 'suspended':
      return _$adminUserStatusEnum_suspended;
    case 'deactivated':
      return _$adminUserStatusEnum_deactivated;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<AdminUserStatusEnum> _$adminUserStatusEnumValues =
    BuiltSet<AdminUserStatusEnum>(const <AdminUserStatusEnum>[
  _$adminUserStatusEnum_active,
  _$adminUserStatusEnum_suspended,
  _$adminUserStatusEnum_deactivated,
]);

Serializer<AdminUserRoleEnum> _$adminUserRoleEnumSerializer =
    _$AdminUserRoleEnumSerializer();
Serializer<AdminUserStatusEnum> _$adminUserStatusEnumSerializer =
    _$AdminUserStatusEnumSerializer();

class _$AdminUserRoleEnumSerializer
    implements PrimitiveSerializer<AdminUserRoleEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'passenger': 'passenger',
    'driver': 'driver',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'passenger': 'passenger',
    'driver': 'driver',
  };

  @override
  final Iterable<Type> types = const <Type>[AdminUserRoleEnum];
  @override
  final String wireName = 'AdminUserRoleEnum';

  @override
  Object serialize(Serializers serializers, AdminUserRoleEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  AdminUserRoleEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      AdminUserRoleEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$AdminUserStatusEnumSerializer
    implements PrimitiveSerializer<AdminUserStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'active': 'active',
    'suspended': 'suspended',
    'deactivated': 'deactivated',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'active': 'active',
    'suspended': 'suspended',
    'deactivated': 'deactivated',
  };

  @override
  final Iterable<Type> types = const <Type>[AdminUserStatusEnum];
  @override
  final String wireName = 'AdminUserStatusEnum';

  @override
  Object serialize(Serializers serializers, AdminUserStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  AdminUserStatusEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      AdminUserStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$AdminUser extends AdminUser {
  @override
  final DateTime? lastLoginAt;
  @override
  final String? createdBy;
  @override
  final String? roleId;
  @override
  final String? roleName;
  @override
  final AdminUserStatusEnum? status;
  @override
  final String id;
  @override
  final String name;
  @override
  final String email;
  @override
  final UserProfileRoleEnum role;
  @override
  final VehicleInfo? vehicle;
  @override
  final DateTime createdAt;

  factory _$AdminUser([void Function(AdminUserBuilder)? updates]) =>
      (AdminUserBuilder()..update(updates))._build();

  _$AdminUser._(
      {this.lastLoginAt,
      this.createdBy,
      this.roleId,
      this.roleName,
      this.status,
      required this.id,
      required this.name,
      required this.email,
      required this.role,
      this.vehicle,
      required this.createdAt})
      : super._();
  @override
  AdminUser rebuild(void Function(AdminUserBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminUserBuilder toBuilder() => AdminUserBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminUser &&
        lastLoginAt == other.lastLoginAt &&
        createdBy == other.createdBy &&
        roleId == other.roleId &&
        roleName == other.roleName &&
        status == other.status &&
        id == other.id &&
        name == other.name &&
        email == other.email &&
        role == other.role &&
        vehicle == other.vehicle &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, lastLoginAt.hashCode);
    _$hash = $jc(_$hash, createdBy.hashCode);
    _$hash = $jc(_$hash, roleId.hashCode);
    _$hash = $jc(_$hash, roleName.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jc(_$hash, vehicle.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminUser')
          ..add('lastLoginAt', lastLoginAt)
          ..add('createdBy', createdBy)
          ..add('roleId', roleId)
          ..add('roleName', roleName)
          ..add('status', status)
          ..add('id', id)
          ..add('name', name)
          ..add('email', email)
          ..add('role', role)
          ..add('vehicle', vehicle)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class AdminUserBuilder
    implements Builder<AdminUser, AdminUserBuilder>, UserProfileBuilder {
  _$AdminUser? _$v;

  DateTime? _lastLoginAt;
  DateTime? get lastLoginAt => _$this._lastLoginAt;
  set lastLoginAt(covariant DateTime? lastLoginAt) =>
      _$this._lastLoginAt = lastLoginAt;

  String? _createdBy;
  String? get createdBy => _$this._createdBy;
  set createdBy(covariant String? createdBy) => _$this._createdBy = createdBy;

  String? _roleId;
  String? get roleId => _$this._roleId;
  set roleId(covariant String? roleId) => _$this._roleId = roleId;

  String? _roleName;
  String? get roleName => _$this._roleName;
  set roleName(covariant String? roleName) => _$this._roleName = roleName;

  AdminUserStatusEnum? _status;
  AdminUserStatusEnum? get status => _$this._status;
  set status(covariant AdminUserStatusEnum? status) => _$this._status = status;

  String? _id;
  String? get id => _$this._id;
  set id(covariant String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(covariant String? name) => _$this._name = name;

  String? _email;
  String? get email => _$this._email;
  set email(covariant String? email) => _$this._email = email;

  UserProfileRoleEnum? _role;
  UserProfileRoleEnum? get role => _$this._role;
  set role(covariant UserProfileRoleEnum? role) => _$this._role = role;

  VehicleInfoBuilder? _vehicle;
  VehicleInfoBuilder get vehicle => _$this._vehicle ??= VehicleInfoBuilder();
  set vehicle(covariant VehicleInfoBuilder? vehicle) =>
      _$this._vehicle = vehicle;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(covariant DateTime? createdAt) => _$this._createdAt = createdAt;

  AdminUserBuilder() {
    AdminUser._defaults(this);
  }

  AdminUserBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _lastLoginAt = $v.lastLoginAt;
      _createdBy = $v.createdBy;
      _roleId = $v.roleId;
      _roleName = $v.roleName;
      _status = $v.status;
      _id = $v.id;
      _name = $v.name;
      _email = $v.email;
      _role = $v.role;
      _vehicle = $v.vehicle?.toBuilder();
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant AdminUser other) {
    _$v = other as _$AdminUser;
  }

  @override
  void update(void Function(AdminUserBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminUser build() => _build();

  _$AdminUser _build() {
    _$AdminUser _$result;
    try {
      _$result = _$v ??
          _$AdminUser._(
            lastLoginAt: lastLoginAt,
            createdBy: createdBy,
            roleId: roleId,
            roleName: roleName,
            status: status,
            id: BuiltValueNullFieldError.checkNotNull(id, r'AdminUser', 'id'),
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'AdminUser', 'name'),
            email: BuiltValueNullFieldError.checkNotNull(
                email, r'AdminUser', 'email'),
            role: BuiltValueNullFieldError.checkNotNull(
                role, r'AdminUser', 'role'),
            vehicle: _vehicle?.build(),
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'AdminUser', 'createdAt'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'vehicle';
        _vehicle?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AdminUser', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

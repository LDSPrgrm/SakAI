// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const UserProfileRoleEnum _$userProfileRoleEnum_passenger =
    const UserProfileRoleEnum._('passenger');
const UserProfileRoleEnum _$userProfileRoleEnum_driver =
    const UserProfileRoleEnum._('driver');

UserProfileRoleEnum _$userProfileRoleEnumValueOf(String name) {
  switch (name) {
    case 'passenger':
      return _$userProfileRoleEnum_passenger;
    case 'driver':
      return _$userProfileRoleEnum_driver;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<UserProfileRoleEnum> _$userProfileRoleEnumValues =
    BuiltSet<UserProfileRoleEnum>(const <UserProfileRoleEnum>[
  _$userProfileRoleEnum_passenger,
  _$userProfileRoleEnum_driver,
]);

Serializer<UserProfileRoleEnum> _$userProfileRoleEnumSerializer =
    _$UserProfileRoleEnumSerializer();

class _$UserProfileRoleEnumSerializer
    implements PrimitiveSerializer<UserProfileRoleEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'passenger': 'passenger',
    'driver': 'driver',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'passenger': 'passenger',
    'driver': 'driver',
  };

  @override
  final Iterable<Type> types = const <Type>[UserProfileRoleEnum];
  @override
  final String wireName = 'UserProfileRoleEnum';

  @override
  Object serialize(Serializers serializers, UserProfileRoleEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  UserProfileRoleEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      UserProfileRoleEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

abstract class UserProfileBuilder {
  void replace(UserProfile other);
  void update(void Function(UserProfileBuilder) updates);
  String? get id;
  set id(String? id);

  String? get name;
  set name(String? name);

  String? get email;
  set email(String? email);

  UserProfileRoleEnum? get role;
  set role(UserProfileRoleEnum? role);

  VehicleInfoBuilder get vehicle;
  set vehicle(VehicleInfoBuilder? vehicle);

  DateTime? get createdAt;
  set createdAt(DateTime? createdAt);
}

class _$$UserProfile extends $UserProfile {
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

  factory _$$UserProfile([void Function($UserProfileBuilder)? updates]) =>
      ($UserProfileBuilder()..update(updates))._build();

  _$$UserProfile._(
      {required this.id,
      required this.name,
      required this.email,
      required this.role,
      this.vehicle,
      required this.createdAt})
      : super._();
  @override
  $UserProfile rebuild(void Function($UserProfileBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  $UserProfileBuilder toBuilder() => $UserProfileBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is $UserProfile &&
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
    return (newBuiltValueToStringHelper(r'$UserProfile')
          ..add('id', id)
          ..add('name', name)
          ..add('email', email)
          ..add('role', role)
          ..add('vehicle', vehicle)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class $UserProfileBuilder
    implements Builder<$UserProfile, $UserProfileBuilder>, UserProfileBuilder {
  _$$UserProfile? _$v;

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

  $UserProfileBuilder() {
    $UserProfile._defaults(this);
  }

  $UserProfileBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
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
  void replace(covariant $UserProfile other) {
    _$v = other as _$$UserProfile;
  }

  @override
  void update(void Function($UserProfileBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  $UserProfile build() => _build();

  _$$UserProfile _build() {
    _$$UserProfile _$result;
    try {
      _$result = _$v ??
          _$$UserProfile._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'$UserProfile', 'id'),
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'$UserProfile', 'name'),
            email: BuiltValueNullFieldError.checkNotNull(
                email, r'$UserProfile', 'email'),
            role: BuiltValueNullFieldError.checkNotNull(
                role, r'$UserProfile', 'role'),
            vehicle: _vehicle?.build(),
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'$UserProfile', 'createdAt'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'vehicle';
        _vehicle?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'$UserProfile', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

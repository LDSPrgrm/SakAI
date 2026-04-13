// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_admin_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CreateAdminRequestRoleEnum _$createAdminRequestRoleEnum_admin =
    const CreateAdminRequestRoleEnum._('admin');
const CreateAdminRequestRoleEnum _$createAdminRequestRoleEnum_superadmin =
    const CreateAdminRequestRoleEnum._('superadmin');
const CreateAdminRequestRoleEnum _$createAdminRequestRoleEnum_operations =
    const CreateAdminRequestRoleEnum._('operations');
const CreateAdminRequestRoleEnum _$createAdminRequestRoleEnum_finance =
    const CreateAdminRequestRoleEnum._('finance');
const CreateAdminRequestRoleEnum _$createAdminRequestRoleEnum_support =
    const CreateAdminRequestRoleEnum._('support');

CreateAdminRequestRoleEnum _$createAdminRequestRoleEnumValueOf(String name) {
  switch (name) {
    case 'admin':
      return _$createAdminRequestRoleEnum_admin;
    case 'superadmin':
      return _$createAdminRequestRoleEnum_superadmin;
    case 'operations':
      return _$createAdminRequestRoleEnum_operations;
    case 'finance':
      return _$createAdminRequestRoleEnum_finance;
    case 'support':
      return _$createAdminRequestRoleEnum_support;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CreateAdminRequestRoleEnum> _$createAdminRequestRoleEnumValues =
    BuiltSet<CreateAdminRequestRoleEnum>(const <CreateAdminRequestRoleEnum>[
      _$createAdminRequestRoleEnum_admin,
      _$createAdminRequestRoleEnum_superadmin,
      _$createAdminRequestRoleEnum_operations,
      _$createAdminRequestRoleEnum_finance,
      _$createAdminRequestRoleEnum_support,
    ]);

Serializer<CreateAdminRequestRoleEnum> _$createAdminRequestRoleEnumSerializer =
    _$CreateAdminRequestRoleEnumSerializer();

class _$CreateAdminRequestRoleEnumSerializer
    implements PrimitiveSerializer<CreateAdminRequestRoleEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'admin': 'admin',
    'superadmin': 'superadmin',
    'operations': 'operations',
    'finance': 'finance',
    'support': 'support',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'admin': 'admin',
    'superadmin': 'superadmin',
    'operations': 'operations',
    'finance': 'finance',
    'support': 'support',
  };

  @override
  final Iterable<Type> types = const <Type>[CreateAdminRequestRoleEnum];
  @override
  final String wireName = 'CreateAdminRequestRoleEnum';

  @override
  Object serialize(
    Serializers serializers,
    CreateAdminRequestRoleEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  CreateAdminRequestRoleEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => CreateAdminRequestRoleEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$CreateAdminRequest extends CreateAdminRequest {
  @override
  final String name;
  @override
  final String email;
  @override
  final String password;
  @override
  final CreateAdminRequestRoleEnum role;

  factory _$CreateAdminRequest([
    void Function(CreateAdminRequestBuilder)? updates,
  ]) => (CreateAdminRequestBuilder()..update(updates))._build();

  _$CreateAdminRequest._({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  }) : super._();
  @override
  CreateAdminRequest rebuild(
    void Function(CreateAdminRequestBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  CreateAdminRequestBuilder toBuilder() =>
      CreateAdminRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateAdminRequest &&
        name == other.name &&
        email == other.email &&
        password == other.password &&
        role == other.role;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, password.hashCode);
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateAdminRequest')
          ..add('name', name)
          ..add('email', email)
          ..add('password', password)
          ..add('role', role))
        .toString();
  }
}

class CreateAdminRequestBuilder
    implements Builder<CreateAdminRequest, CreateAdminRequestBuilder> {
  _$CreateAdminRequest? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  String? _password;
  String? get password => _$this._password;
  set password(String? password) => _$this._password = password;

  CreateAdminRequestRoleEnum? _role;
  CreateAdminRequestRoleEnum? get role => _$this._role;
  set role(CreateAdminRequestRoleEnum? role) => _$this._role = role;

  CreateAdminRequestBuilder() {
    CreateAdminRequest._defaults(this);
  }

  CreateAdminRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _email = $v.email;
      _password = $v.password;
      _role = $v.role;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateAdminRequest other) {
    _$v = other as _$CreateAdminRequest;
  }

  @override
  void update(void Function(CreateAdminRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateAdminRequest build() => _build();

  _$CreateAdminRequest _build() {
    final _$result =
        _$v ??
        _$CreateAdminRequest._(
          name: BuiltValueNullFieldError.checkNotNull(
            name,
            r'CreateAdminRequest',
            'name',
          ),
          email: BuiltValueNullFieldError.checkNotNull(
            email,
            r'CreateAdminRequest',
            'email',
          ),
          password: BuiltValueNullFieldError.checkNotNull(
            password,
            r'CreateAdminRequest',
            'password',
          ),
          role: BuiltValueNullFieldError.checkNotNull(
            role,
            r'CreateAdminRequest',
            'role',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

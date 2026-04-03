// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const RegisterRequestRoleEnum _$registerRequestRoleEnum_passenger =
    const RegisterRequestRoleEnum._('passenger');
const RegisterRequestRoleEnum _$registerRequestRoleEnum_driver =
    const RegisterRequestRoleEnum._('driver');

RegisterRequestRoleEnum _$registerRequestRoleEnumValueOf(String name) {
  switch (name) {
    case 'passenger':
      return _$registerRequestRoleEnum_passenger;
    case 'driver':
      return _$registerRequestRoleEnum_driver;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<RegisterRequestRoleEnum> _$registerRequestRoleEnumValues =
    BuiltSet<RegisterRequestRoleEnum>(const <RegisterRequestRoleEnum>[
      _$registerRequestRoleEnum_passenger,
      _$registerRequestRoleEnum_driver,
    ]);

Serializer<RegisterRequestRoleEnum> _$registerRequestRoleEnumSerializer =
    _$RegisterRequestRoleEnumSerializer();

class _$RegisterRequestRoleEnumSerializer
    implements PrimitiveSerializer<RegisterRequestRoleEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'passenger': 'passenger',
    'driver': 'driver',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'passenger': 'passenger',
    'driver': 'driver',
  };

  @override
  final Iterable<Type> types = const <Type>[RegisterRequestRoleEnum];
  @override
  final String wireName = 'RegisterRequestRoleEnum';

  @override
  Object serialize(
    Serializers serializers,
    RegisterRequestRoleEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  RegisterRequestRoleEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => RegisterRequestRoleEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$RegisterRequest extends RegisterRequest {
  @override
  final String name;
  @override
  final String email;
  @override
  final String password;
  @override
  final RegisterRequestRoleEnum role;

  factory _$RegisterRequest([void Function(RegisterRequestBuilder)? updates]) =>
      (RegisterRequestBuilder()..update(updates))._build();

  _$RegisterRequest._({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  }) : super._();
  @override
  RegisterRequest rebuild(void Function(RegisterRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RegisterRequestBuilder toBuilder() => RegisterRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RegisterRequest &&
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
    return (newBuiltValueToStringHelper(r'RegisterRequest')
          ..add('name', name)
          ..add('email', email)
          ..add('password', password)
          ..add('role', role))
        .toString();
  }
}

class RegisterRequestBuilder
    implements Builder<RegisterRequest, RegisterRequestBuilder> {
  _$RegisterRequest? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  String? _password;
  String? get password => _$this._password;
  set password(String? password) => _$this._password = password;

  RegisterRequestRoleEnum? _role;
  RegisterRequestRoleEnum? get role => _$this._role;
  set role(RegisterRequestRoleEnum? role) => _$this._role = role;

  RegisterRequestBuilder() {
    RegisterRequest._defaults(this);
  }

  RegisterRequestBuilder get _$this {
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
  void replace(RegisterRequest other) {
    _$v = other as _$RegisterRequest;
  }

  @override
  void update(void Function(RegisterRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RegisterRequest build() => _build();

  _$RegisterRequest _build() {
    final _$result =
        _$v ??
        _$RegisterRequest._(
          name: BuiltValueNullFieldError.checkNotNull(
            name,
            r'RegisterRequest',
            'name',
          ),
          email: BuiltValueNullFieldError.checkNotNull(
            email,
            r'RegisterRequest',
            'email',
          ),
          password: BuiltValueNullFieldError.checkNotNull(
            password,
            r'RegisterRequest',
            'password',
          ),
          role: BuiltValueNullFieldError.checkNotNull(
            role,
            r'RegisterRequest',
            'role',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

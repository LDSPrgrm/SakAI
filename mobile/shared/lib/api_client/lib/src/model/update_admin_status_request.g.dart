// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_admin_status_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const UpdateAdminStatusRequestRoleEnum
    _$updateAdminStatusRequestRoleEnum_admin =
    const UpdateAdminStatusRequestRoleEnum._('admin');
const UpdateAdminStatusRequestRoleEnum
    _$updateAdminStatusRequestRoleEnum_superadmin =
    const UpdateAdminStatusRequestRoleEnum._('superadmin');
const UpdateAdminStatusRequestRoleEnum
    _$updateAdminStatusRequestRoleEnum_operations =
    const UpdateAdminStatusRequestRoleEnum._('operations');
const UpdateAdminStatusRequestRoleEnum
    _$updateAdminStatusRequestRoleEnum_finance =
    const UpdateAdminStatusRequestRoleEnum._('finance');
const UpdateAdminStatusRequestRoleEnum
    _$updateAdminStatusRequestRoleEnum_support =
    const UpdateAdminStatusRequestRoleEnum._('support');

UpdateAdminStatusRequestRoleEnum _$updateAdminStatusRequestRoleEnumValueOf(
    String name) {
  switch (name) {
    case 'admin':
      return _$updateAdminStatusRequestRoleEnum_admin;
    case 'superadmin':
      return _$updateAdminStatusRequestRoleEnum_superadmin;
    case 'operations':
      return _$updateAdminStatusRequestRoleEnum_operations;
    case 'finance':
      return _$updateAdminStatusRequestRoleEnum_finance;
    case 'support':
      return _$updateAdminStatusRequestRoleEnum_support;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<UpdateAdminStatusRequestRoleEnum>
    _$updateAdminStatusRequestRoleEnumValues = BuiltSet<
        UpdateAdminStatusRequestRoleEnum>(const <UpdateAdminStatusRequestRoleEnum>[
  _$updateAdminStatusRequestRoleEnum_admin,
  _$updateAdminStatusRequestRoleEnum_superadmin,
  _$updateAdminStatusRequestRoleEnum_operations,
  _$updateAdminStatusRequestRoleEnum_finance,
  _$updateAdminStatusRequestRoleEnum_support,
]);

Serializer<UpdateAdminStatusRequestRoleEnum>
    _$updateAdminStatusRequestRoleEnumSerializer =
    _$UpdateAdminStatusRequestRoleEnumSerializer();

class _$UpdateAdminStatusRequestRoleEnumSerializer
    implements PrimitiveSerializer<UpdateAdminStatusRequestRoleEnum> {
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
  final Iterable<Type> types = const <Type>[UpdateAdminStatusRequestRoleEnum];
  @override
  final String wireName = 'UpdateAdminStatusRequestRoleEnum';

  @override
  Object serialize(
          Serializers serializers, UpdateAdminStatusRequestRoleEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  UpdateAdminStatusRequestRoleEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      UpdateAdminStatusRequestRoleEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$UpdateAdminStatusRequest extends UpdateAdminStatusRequest {
  @override
  final UpdateAdminStatusRequestRoleEnum role;

  factory _$UpdateAdminStatusRequest(
          [void Function(UpdateAdminStatusRequestBuilder)? updates]) =>
      (UpdateAdminStatusRequestBuilder()..update(updates))._build();

  _$UpdateAdminStatusRequest._({required this.role}) : super._();
  @override
  UpdateAdminStatusRequest rebuild(
          void Function(UpdateAdminStatusRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UpdateAdminStatusRequestBuilder toBuilder() =>
      UpdateAdminStatusRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UpdateAdminStatusRequest && role == other.role;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UpdateAdminStatusRequest')
          ..add('role', role))
        .toString();
  }
}

class UpdateAdminStatusRequestBuilder
    implements
        Builder<UpdateAdminStatusRequest, UpdateAdminStatusRequestBuilder> {
  _$UpdateAdminStatusRequest? _$v;

  UpdateAdminStatusRequestRoleEnum? _role;
  UpdateAdminStatusRequestRoleEnum? get role => _$this._role;
  set role(UpdateAdminStatusRequestRoleEnum? role) => _$this._role = role;

  UpdateAdminStatusRequestBuilder() {
    UpdateAdminStatusRequest._defaults(this);
  }

  UpdateAdminStatusRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _role = $v.role;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UpdateAdminStatusRequest other) {
    _$v = other as _$UpdateAdminStatusRequest;
  }

  @override
  void update(void Function(UpdateAdminStatusRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UpdateAdminStatusRequest build() => _build();

  _$UpdateAdminStatusRequest _build() {
    final _$result = _$v ??
        _$UpdateAdminStatusRequest._(
          role: BuiltValueNullFieldError.checkNotNull(
              role, r'UpdateAdminStatusRequest', 'role'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

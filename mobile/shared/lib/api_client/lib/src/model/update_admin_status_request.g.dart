// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_admin_status_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UpdateAdminStatusRequest extends UpdateAdminStatusRequest {
  @override
  final String? name;
  @override
  final String? email;
  @override
  final String roleId;

  factory _$UpdateAdminStatusRequest([
    void Function(UpdateAdminStatusRequestBuilder)? updates,
  ]) => (UpdateAdminStatusRequestBuilder()..update(updates))._build();

  _$UpdateAdminStatusRequest._({this.name, this.email, required this.roleId})
    : super._();
  @override
  UpdateAdminStatusRequest rebuild(
    void Function(UpdateAdminStatusRequestBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  UpdateAdminStatusRequestBuilder toBuilder() =>
      UpdateAdminStatusRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UpdateAdminStatusRequest &&
        name == other.name &&
        email == other.email &&
        roleId == other.roleId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, roleId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UpdateAdminStatusRequest')
          ..add('name', name)
          ..add('email', email)
          ..add('roleId', roleId))
        .toString();
  }
}

class UpdateAdminStatusRequestBuilder
    implements
        Builder<UpdateAdminStatusRequest, UpdateAdminStatusRequestBuilder> {
  _$UpdateAdminStatusRequest? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  String? _roleId;
  String? get roleId => _$this._roleId;
  set roleId(String? roleId) => _$this._roleId = roleId;

  UpdateAdminStatusRequestBuilder() {
    UpdateAdminStatusRequest._defaults(this);
  }

  UpdateAdminStatusRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _email = $v.email;
      _roleId = $v.roleId;
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
    final _$result =
        _$v ??
        _$UpdateAdminStatusRequest._(
          name: name,
          email: email,
          roleId: BuiltValueNullFieldError.checkNotNull(
            roleId,
            r'UpdateAdminStatusRequest',
            'roleId',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

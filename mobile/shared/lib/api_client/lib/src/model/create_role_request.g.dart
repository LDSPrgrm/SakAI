// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_role_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CreateRoleRequest extends CreateRoleRequest {
  @override
  final String name;
  @override
  final String? description;
  @override
  final BuiltList<RolePermission> permissions;

  factory _$CreateRoleRequest([
    void Function(CreateRoleRequestBuilder)? updates,
  ]) => (CreateRoleRequestBuilder()..update(updates))._build();

  _$CreateRoleRequest._({
    required this.name,
    this.description,
    required this.permissions,
  }) : super._();
  @override
  CreateRoleRequest rebuild(void Function(CreateRoleRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreateRoleRequestBuilder toBuilder() =>
      CreateRoleRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateRoleRequest &&
        name == other.name &&
        description == other.description &&
        permissions == other.permissions;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, permissions.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateRoleRequest')
          ..add('name', name)
          ..add('description', description)
          ..add('permissions', permissions))
        .toString();
  }
}

class CreateRoleRequestBuilder
    implements Builder<CreateRoleRequest, CreateRoleRequestBuilder> {
  _$CreateRoleRequest? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  ListBuilder<RolePermission>? _permissions;
  ListBuilder<RolePermission> get permissions =>
      _$this._permissions ??= ListBuilder<RolePermission>();
  set permissions(ListBuilder<RolePermission>? permissions) =>
      _$this._permissions = permissions;

  CreateRoleRequestBuilder() {
    CreateRoleRequest._defaults(this);
  }

  CreateRoleRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _description = $v.description;
      _permissions = $v.permissions.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateRoleRequest other) {
    _$v = other as _$CreateRoleRequest;
  }

  @override
  void update(void Function(CreateRoleRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateRoleRequest build() => _build();

  _$CreateRoleRequest _build() {
    _$CreateRoleRequest _$result;
    try {
      _$result =
          _$v ??
          _$CreateRoleRequest._(
            name: BuiltValueNullFieldError.checkNotNull(
              name,
              r'CreateRoleRequest',
              'name',
            ),
            description: description,
            permissions: permissions.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'permissions';
        permissions.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'CreateRoleRequest',
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

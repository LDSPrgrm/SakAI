// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'role_permission.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const RolePermissionPermissionKeyEnum
    _$rolePermissionPermissionKeyEnum_dashboard =
    const RolePermissionPermissionKeyEnum._('dashboard');
const RolePermissionPermissionKeyEnum
    _$rolePermissionPermissionKeyEnum_adminManagement =
    const RolePermissionPermissionKeyEnum._('adminManagement');
const RolePermissionPermissionKeyEnum
    _$rolePermissionPermissionKeyEnum_roleManagement =
    const RolePermissionPermissionKeyEnum._('roleManagement');
const RolePermissionPermissionKeyEnum
    _$rolePermissionPermissionKeyEnum_fareConfig =
    const RolePermissionPermissionKeyEnum._('fareConfig');
const RolePermissionPermissionKeyEnum
    _$rolePermissionPermissionKeyEnum_payments =
    const RolePermissionPermissionKeyEnum._('payments');
const RolePermissionPermissionKeyEnum
    _$rolePermissionPermissionKeyEnum_payouts =
    const RolePermissionPermissionKeyEnum._('payouts');
const RolePermissionPermissionKeyEnum
    _$rolePermissionPermissionKeyEnum_userManagement =
    const RolePermissionPermissionKeyEnum._('userManagement');
const RolePermissionPermissionKeyEnum
    _$rolePermissionPermissionKeyEnum_kycVerification =
    const RolePermissionPermissionKeyEnum._('kycVerification');
const RolePermissionPermissionKeyEnum
    _$rolePermissionPermissionKeyEnum_safetyIncidents =
    const RolePermissionPermissionKeyEnum._('safetyIncidents');
const RolePermissionPermissionKeyEnum
    _$rolePermissionPermissionKeyEnum_reports =
    const RolePermissionPermissionKeyEnum._('reports');
const RolePermissionPermissionKeyEnum
    _$rolePermissionPermissionKeyEnum_systemConfig =
    const RolePermissionPermissionKeyEnum._('systemConfig');
const RolePermissionPermissionKeyEnum
    _$rolePermissionPermissionKeyEnum_systemHealth =
    const RolePermissionPermissionKeyEnum._('systemHealth');
const RolePermissionPermissionKeyEnum
    _$rolePermissionPermissionKeyEnum_auditLog =
    const RolePermissionPermissionKeyEnum._('auditLog');
const RolePermissionPermissionKeyEnum
    _$rolePermissionPermissionKeyEnum_ltfrbCompliance =
    const RolePermissionPermissionKeyEnum._('ltfrbCompliance');

RolePermissionPermissionKeyEnum _$rolePermissionPermissionKeyEnumValueOf(
    String name) {
  switch (name) {
    case 'dashboard':
      return _$rolePermissionPermissionKeyEnum_dashboard;
    case 'adminManagement':
      return _$rolePermissionPermissionKeyEnum_adminManagement;
    case 'roleManagement':
      return _$rolePermissionPermissionKeyEnum_roleManagement;
    case 'fareConfig':
      return _$rolePermissionPermissionKeyEnum_fareConfig;
    case 'payments':
      return _$rolePermissionPermissionKeyEnum_payments;
    case 'payouts':
      return _$rolePermissionPermissionKeyEnum_payouts;
    case 'userManagement':
      return _$rolePermissionPermissionKeyEnum_userManagement;
    case 'kycVerification':
      return _$rolePermissionPermissionKeyEnum_kycVerification;
    case 'safetyIncidents':
      return _$rolePermissionPermissionKeyEnum_safetyIncidents;
    case 'reports':
      return _$rolePermissionPermissionKeyEnum_reports;
    case 'systemConfig':
      return _$rolePermissionPermissionKeyEnum_systemConfig;
    case 'systemHealth':
      return _$rolePermissionPermissionKeyEnum_systemHealth;
    case 'auditLog':
      return _$rolePermissionPermissionKeyEnum_auditLog;
    case 'ltfrbCompliance':
      return _$rolePermissionPermissionKeyEnum_ltfrbCompliance;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<RolePermissionPermissionKeyEnum>
    _$rolePermissionPermissionKeyEnumValues = BuiltSet<
        RolePermissionPermissionKeyEnum>(const <RolePermissionPermissionKeyEnum>[
  _$rolePermissionPermissionKeyEnum_dashboard,
  _$rolePermissionPermissionKeyEnum_adminManagement,
  _$rolePermissionPermissionKeyEnum_roleManagement,
  _$rolePermissionPermissionKeyEnum_fareConfig,
  _$rolePermissionPermissionKeyEnum_payments,
  _$rolePermissionPermissionKeyEnum_payouts,
  _$rolePermissionPermissionKeyEnum_userManagement,
  _$rolePermissionPermissionKeyEnum_kycVerification,
  _$rolePermissionPermissionKeyEnum_safetyIncidents,
  _$rolePermissionPermissionKeyEnum_reports,
  _$rolePermissionPermissionKeyEnum_systemConfig,
  _$rolePermissionPermissionKeyEnum_systemHealth,
  _$rolePermissionPermissionKeyEnum_auditLog,
  _$rolePermissionPermissionKeyEnum_ltfrbCompliance,
]);

Serializer<RolePermissionPermissionKeyEnum>
    _$rolePermissionPermissionKeyEnumSerializer =
    _$RolePermissionPermissionKeyEnumSerializer();

class _$RolePermissionPermissionKeyEnumSerializer
    implements PrimitiveSerializer<RolePermissionPermissionKeyEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'dashboard': 'dashboard',
    'adminManagement': 'admin_management',
    'roleManagement': 'role_management',
    'fareConfig': 'fare_config',
    'payments': 'payments',
    'payouts': 'payouts',
    'userManagement': 'user_management',
    'kycVerification': 'kyc_verification',
    'safetyIncidents': 'safety_incidents',
    'reports': 'reports',
    'systemConfig': 'system_config',
    'systemHealth': 'system_health',
    'auditLog': 'audit_log',
    'ltfrbCompliance': 'ltfrb_compliance',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'dashboard': 'dashboard',
    'admin_management': 'adminManagement',
    'role_management': 'roleManagement',
    'fare_config': 'fareConfig',
    'payments': 'payments',
    'payouts': 'payouts',
    'user_management': 'userManagement',
    'kyc_verification': 'kycVerification',
    'safety_incidents': 'safetyIncidents',
    'reports': 'reports',
    'system_config': 'systemConfig',
    'system_health': 'systemHealth',
    'audit_log': 'auditLog',
    'ltfrb_compliance': 'ltfrbCompliance',
  };

  @override
  final Iterable<Type> types = const <Type>[RolePermissionPermissionKeyEnum];
  @override
  final String wireName = 'RolePermissionPermissionKeyEnum';

  @override
  Object serialize(
          Serializers serializers, RolePermissionPermissionKeyEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  RolePermissionPermissionKeyEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      RolePermissionPermissionKeyEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$RolePermission extends RolePermission {
  @override
  final RolePermissionPermissionKeyEnum? permissionKey;
  @override
  final bool? read;
  @override
  final bool? write;

  factory _$RolePermission([void Function(RolePermissionBuilder)? updates]) =>
      (RolePermissionBuilder()..update(updates))._build();

  _$RolePermission._({this.permissionKey, this.read, this.write}) : super._();
  @override
  RolePermission rebuild(void Function(RolePermissionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RolePermissionBuilder toBuilder() => RolePermissionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RolePermission &&
        permissionKey == other.permissionKey &&
        read == other.read &&
        write == other.write;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, permissionKey.hashCode);
    _$hash = $jc(_$hash, read.hashCode);
    _$hash = $jc(_$hash, write.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RolePermission')
          ..add('permissionKey', permissionKey)
          ..add('read', read)
          ..add('write', write))
        .toString();
  }
}

class RolePermissionBuilder
    implements Builder<RolePermission, RolePermissionBuilder> {
  _$RolePermission? _$v;

  RolePermissionPermissionKeyEnum? _permissionKey;
  RolePermissionPermissionKeyEnum? get permissionKey => _$this._permissionKey;
  set permissionKey(RolePermissionPermissionKeyEnum? permissionKey) =>
      _$this._permissionKey = permissionKey;

  bool? _read;
  bool? get read => _$this._read;
  set read(bool? read) => _$this._read = read;

  bool? _write;
  bool? get write => _$this._write;
  set write(bool? write) => _$this._write = write;

  RolePermissionBuilder() {
    RolePermission._defaults(this);
  }

  RolePermissionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _permissionKey = $v.permissionKey;
      _read = $v.read;
      _write = $v.write;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RolePermission other) {
    _$v = other as _$RolePermission;
  }

  @override
  void update(void Function(RolePermissionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RolePermission build() => _build();

  _$RolePermission _build() {
    final _$result = _$v ??
        _$RolePermission._(
          permissionKey: permissionKey,
          read: read,
          write: write,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

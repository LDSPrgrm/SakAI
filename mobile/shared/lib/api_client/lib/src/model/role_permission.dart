// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'role_permission.g.dart';

/// RolePermission
///
/// Properties:
/// * [permissionKey] 
/// * [read] 
/// * [write] 
@BuiltValue()
abstract class RolePermission implements Built<RolePermission, RolePermissionBuilder> {
  @BuiltValueField(wireName: r'permission_key')
  RolePermissionPermissionKeyEnum? get permissionKey;
  // enum permissionKeyEnum {  dashboard,  admin_management,  role_management,  fare_config,  payments,  payouts,  user_management,  kyc_verification,  safety_incidents,  reports,  system_config,  system_health,  audit_log,  ltfrb_compliance,  };

  @BuiltValueField(wireName: r'read')
  bool? get read;

  @BuiltValueField(wireName: r'write')
  bool? get write;

  RolePermission._();

  factory RolePermission([void updates(RolePermissionBuilder b)]) = _$RolePermission;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RolePermissionBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RolePermission> get serializer => _$RolePermissionSerializer();
}

class _$RolePermissionSerializer implements PrimitiveSerializer<RolePermission> {
  @override
  final Iterable<Type> types = const [RolePermission, _$RolePermission];

  @override
  final String wireName = r'RolePermission';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RolePermission object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.permissionKey != null) {
      yield r'permission_key';
      yield serializers.serialize(
        object.permissionKey,
        specifiedType: const FullType(RolePermissionPermissionKeyEnum),
      );
    }
    if (object.read != null) {
      yield r'read';
      yield serializers.serialize(
        object.read,
        specifiedType: const FullType(bool),
      );
    }
    if (object.write != null) {
      yield r'write';
      yield serializers.serialize(
        object.write,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    RolePermission object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RolePermissionBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'permission_key':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(RolePermissionPermissionKeyEnum),
          ) as RolePermissionPermissionKeyEnum;
          result.permissionKey = valueDes;
          break;
        case r'read':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.read = valueDes;
          break;
        case r'write':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.write = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RolePermission deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RolePermissionBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}

class RolePermissionPermissionKeyEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'dashboard')
  static const RolePermissionPermissionKeyEnum dashboard = _$rolePermissionPermissionKeyEnum_dashboard;
  @BuiltValueEnumConst(wireName: r'admin_management')
  static const RolePermissionPermissionKeyEnum adminManagement = _$rolePermissionPermissionKeyEnum_adminManagement;
  @BuiltValueEnumConst(wireName: r'role_management')
  static const RolePermissionPermissionKeyEnum roleManagement = _$rolePermissionPermissionKeyEnum_roleManagement;
  @BuiltValueEnumConst(wireName: r'fare_config')
  static const RolePermissionPermissionKeyEnum fareConfig = _$rolePermissionPermissionKeyEnum_fareConfig;
  @BuiltValueEnumConst(wireName: r'payments')
  static const RolePermissionPermissionKeyEnum payments = _$rolePermissionPermissionKeyEnum_payments;
  @BuiltValueEnumConst(wireName: r'payouts')
  static const RolePermissionPermissionKeyEnum payouts = _$rolePermissionPermissionKeyEnum_payouts;
  @BuiltValueEnumConst(wireName: r'user_management')
  static const RolePermissionPermissionKeyEnum userManagement = _$rolePermissionPermissionKeyEnum_userManagement;
  @BuiltValueEnumConst(wireName: r'kyc_verification')
  static const RolePermissionPermissionKeyEnum kycVerification = _$rolePermissionPermissionKeyEnum_kycVerification;
  @BuiltValueEnumConst(wireName: r'safety_incidents')
  static const RolePermissionPermissionKeyEnum safetyIncidents = _$rolePermissionPermissionKeyEnum_safetyIncidents;
  @BuiltValueEnumConst(wireName: r'reports')
  static const RolePermissionPermissionKeyEnum reports = _$rolePermissionPermissionKeyEnum_reports;
  @BuiltValueEnumConst(wireName: r'system_config')
  static const RolePermissionPermissionKeyEnum systemConfig = _$rolePermissionPermissionKeyEnum_systemConfig;
  @BuiltValueEnumConst(wireName: r'system_health')
  static const RolePermissionPermissionKeyEnum systemHealth = _$rolePermissionPermissionKeyEnum_systemHealth;
  @BuiltValueEnumConst(wireName: r'audit_log')
  static const RolePermissionPermissionKeyEnum auditLog = _$rolePermissionPermissionKeyEnum_auditLog;
  @BuiltValueEnumConst(wireName: r'ltfrb_compliance')
  static const RolePermissionPermissionKeyEnum ltfrbCompliance = _$rolePermissionPermissionKeyEnum_ltfrbCompliance;

  static Serializer<RolePermissionPermissionKeyEnum> get serializer => _$rolePermissionPermissionKeyEnumSerializer;

  const RolePermissionPermissionKeyEnum._(String name): super(name);

  static BuiltSet<RolePermissionPermissionKeyEnum> get values => _$rolePermissionPermissionKeyEnumValues;
  static RolePermissionPermissionKeyEnum valueOf(String name) => _$rolePermissionPermissionKeyEnumValueOf(name);
}


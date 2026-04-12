//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sakai_api_client/src/model/user_profile.dart';
import 'package:built_collection/built_collection.dart';
import 'package:sakai_api_client/src/model/vehicle_info.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_user.g.dart';

/// AdminUser
///
/// Properties:
/// * [id] 
/// * [name] 
/// * [email] 
/// * [role] 
/// * [vehicle] - Present only when `role=driver`. Null for passengers.
/// * [createdAt] 
/// * [roleId] 
/// * [roleName] 
/// * [status] 
/// * [createdBy] 
/// * [lastLoginAt] 
@BuiltValue()
abstract class AdminUser implements UserProfile, Built<AdminUser, AdminUserBuilder> {
  @BuiltValueField(wireName: r'last_login_at')
  DateTime? get lastLoginAt;

  @BuiltValueField(wireName: r'created_by')
  String? get createdBy;

  @BuiltValueField(wireName: r'role_id')
  String? get roleId;

  @BuiltValueField(wireName: r'role_name')
  String? get roleName;

  @BuiltValueField(wireName: r'status')
  AdminUserStatusEnum? get status;
  // enum statusEnum {  active,  suspended,  deactivated,  };

  AdminUser._();

  factory AdminUser([void updates(AdminUserBuilder b)]) = _$AdminUser;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminUserBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminUser> get serializer => _$AdminUserSerializer();
}

class _$AdminUserSerializer implements PrimitiveSerializer<AdminUser> {
  @override
  final Iterable<Type> types = const [AdminUser, _$AdminUser];

  @override
  final String wireName = r'AdminUser';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminUser object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'created_at';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    if (object.lastLoginAt != null) {
      yield r'last_login_at';
      yield serializers.serialize(
        object.lastLoginAt,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
    yield r'role';
    yield serializers.serialize(
      object.role,
      specifiedType: const FullType(UserProfileRoleEnum),
    );
    if (object.createdBy != null) {
      yield r'created_by';
      yield serializers.serialize(
        object.createdBy,
        specifiedType: const FullType(String),
      );
    }
    if (object.roleId != null) {
      yield r'role_id';
      yield serializers.serialize(
        object.roleId,
        specifiedType: const FullType(String),
      );
    }
    if (object.roleName != null) {
      yield r'role_name';
      yield serializers.serialize(
        object.roleName,
        specifiedType: const FullType(String),
      );
    }
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'email';
    yield serializers.serialize(
      object.email,
      specifiedType: const FullType(String),
    );
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(AdminUserStatusEnum),
      );
    }
    if (object.vehicle != null) {
      yield r'vehicle';
      yield serializers.serialize(
        object.vehicle,
        specifiedType: const FullType.nullable(VehicleInfo),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminUser object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminUserBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'last_login_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.lastLoginAt = valueDes;
          break;
        case r'role':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(UserProfileRoleEnum),
          ) as UserProfileRoleEnum;
          result.role = valueDes;
          break;
        case r'created_by':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.createdBy = valueDes;
          break;
        case r'role_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.roleId = valueDes;
          break;
        case r'role_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.roleName = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'email':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.email = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdminUserStatusEnum),
          ) as AdminUserStatusEnum;
          result.status = valueDes;
          break;
        case r'vehicle':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(VehicleInfo),
          ) as VehicleInfo?;
          if (valueDes == null) continue;
          result.vehicle.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminUser deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminUserBuilder();
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

class AdminUserRoleEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'passenger')
  static const AdminUserRoleEnum passenger = _$adminUserRoleEnum_passenger;
  @BuiltValueEnumConst(wireName: r'driver')
  static const AdminUserRoleEnum driver = _$adminUserRoleEnum_driver;

  static Serializer<AdminUserRoleEnum> get serializer => _$adminUserRoleEnumSerializer;

  const AdminUserRoleEnum._(String name): super(name);

  static BuiltSet<AdminUserRoleEnum> get values => _$adminUserRoleEnumValues;
  static AdminUserRoleEnum valueOf(String name) => _$adminUserRoleEnumValueOf(name);
}

class AdminUserStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'active')
  static const AdminUserStatusEnum active = _$adminUserStatusEnum_active;
  @BuiltValueEnumConst(wireName: r'suspended')
  static const AdminUserStatusEnum suspended = _$adminUserStatusEnum_suspended;
  @BuiltValueEnumConst(wireName: r'deactivated')
  static const AdminUserStatusEnum deactivated = _$adminUserStatusEnum_deactivated;

  static Serializer<AdminUserStatusEnum> get serializer => _$adminUserStatusEnumSerializer;

  const AdminUserStatusEnum._(String name): super(name);

  static BuiltSet<AdminUserStatusEnum> get values => _$adminUserStatusEnumValues;
  static AdminUserStatusEnum valueOf(String name) => _$adminUserStatusEnumValueOf(name);
}


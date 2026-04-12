//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sakai_api_client/src/model/vehicle_info.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'user_profile.g.dart';

/// UserProfile
///
/// Properties:
/// * [id] 
/// * [name] 
/// * [email] 
/// * [role] 
/// * [vehicle] - Present only when `role=driver`. Null for passengers.
/// * [createdAt] 
@BuiltValue(instantiable: false)
abstract class UserProfile  {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'email')
  String get email;

  @BuiltValueField(wireName: r'role')
  UserProfileRoleEnum get role;
  // enum roleEnum {  passenger,  driver,  };

  /// Present only when `role=driver`. Null for passengers.
  @BuiltValueField(wireName: r'vehicle')
  VehicleInfo? get vehicle;

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  @BuiltValueSerializer(custom: true)
  static Serializer<UserProfile> get serializer => _$UserProfileSerializer();
}

class _$UserProfileSerializer implements PrimitiveSerializer<UserProfile> {
  @override
  final Iterable<Type> types = const [UserProfile];

  @override
  final String wireName = r'UserProfile';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UserProfile object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'email';
    yield serializers.serialize(
      object.email,
      specifiedType: const FullType(String),
    );
    yield r'role';
    yield serializers.serialize(
      object.role,
      specifiedType: const FullType(UserProfileRoleEnum),
    );
    if (object.vehicle != null) {
      yield r'vehicle';
      yield serializers.serialize(
        object.vehicle,
        specifiedType: const FullType.nullable(VehicleInfo),
      );
    }
    yield r'created_at';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    UserProfile object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  @override
  UserProfile deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return serializers.deserialize(serialized, specifiedType: FullType($UserProfile)) as $UserProfile;
  }
}

/// a concrete implementation of [UserProfile], since [UserProfile] is not instantiable
@BuiltValue(instantiable: true)
abstract class $UserProfile implements UserProfile, Built<$UserProfile, $UserProfileBuilder> {
  $UserProfile._();

  factory $UserProfile([void Function($UserProfileBuilder)? updates]) = _$$UserProfile;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults($UserProfileBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<$UserProfile> get serializer => _$$UserProfileSerializer();
}

class _$$UserProfileSerializer implements PrimitiveSerializer<$UserProfile> {
  @override
  final Iterable<Type> types = const [$UserProfile, _$$UserProfile];

  @override
  final String wireName = r'$UserProfile';

  @override
  Object serialize(
    Serializers serializers,
    $UserProfile object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return serializers.serialize(object, specifiedType: FullType(UserProfile))!;
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UserProfileBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'email':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.email = valueDes;
          break;
        case r'role':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(UserProfileRoleEnum),
          ) as UserProfileRoleEnum;
          result.role = valueDes;
          break;
        case r'vehicle':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(VehicleInfo),
          ) as VehicleInfo?;
          if (valueDes == null) continue;
          result.vehicle.replace(valueDes);
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  $UserProfile deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = $UserProfileBuilder();
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

class UserProfileRoleEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'passenger')
  static const UserProfileRoleEnum passenger = _$userProfileRoleEnum_passenger;
  @BuiltValueEnumConst(wireName: r'driver')
  static const UserProfileRoleEnum driver = _$userProfileRoleEnum_driver;

  static Serializer<UserProfileRoleEnum> get serializer => _$userProfileRoleEnumSerializer;

  const UserProfileRoleEnum._(String name): super(name);

  static BuiltSet<UserProfileRoleEnum> get values => _$userProfileRoleEnumValues;
  static UserProfileRoleEnum valueOf(String name) => _$userProfileRoleEnumValueOf(name);
}


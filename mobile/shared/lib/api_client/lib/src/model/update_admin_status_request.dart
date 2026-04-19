// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'update_admin_status_request.g.dart';

/// UpdateAdminStatusRequest
///
/// Properties:
/// * [role] 
@BuiltValue()
abstract class UpdateAdminStatusRequest implements Built<UpdateAdminStatusRequest, UpdateAdminStatusRequestBuilder> {
  @BuiltValueField(wireName: r'role')
  UpdateAdminStatusRequestRoleEnum get role;
  // enum roleEnum {  admin,  superadmin,  operations,  finance,  support,  };

  UpdateAdminStatusRequest._();

  factory UpdateAdminStatusRequest([void updates(UpdateAdminStatusRequestBuilder b)]) = _$UpdateAdminStatusRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UpdateAdminStatusRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UpdateAdminStatusRequest> get serializer => _$UpdateAdminStatusRequestSerializer();
}

class _$UpdateAdminStatusRequestSerializer implements PrimitiveSerializer<UpdateAdminStatusRequest> {
  @override
  final Iterable<Type> types = const [UpdateAdminStatusRequest, _$UpdateAdminStatusRequest];

  @override
  final String wireName = r'UpdateAdminStatusRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UpdateAdminStatusRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'role';
    yield serializers.serialize(
      object.role,
      specifiedType: const FullType(UpdateAdminStatusRequestRoleEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    UpdateAdminStatusRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UpdateAdminStatusRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'role':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(UpdateAdminStatusRequestRoleEnum),
          ) as UpdateAdminStatusRequestRoleEnum;
          result.role = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UpdateAdminStatusRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UpdateAdminStatusRequestBuilder();
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

class UpdateAdminStatusRequestRoleEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'admin')
  static const UpdateAdminStatusRequestRoleEnum admin = _$updateAdminStatusRequestRoleEnum_admin;
  @BuiltValueEnumConst(wireName: r'superadmin')
  static const UpdateAdminStatusRequestRoleEnum superadmin = _$updateAdminStatusRequestRoleEnum_superadmin;
  @BuiltValueEnumConst(wireName: r'operations')
  static const UpdateAdminStatusRequestRoleEnum operations = _$updateAdminStatusRequestRoleEnum_operations;
  @BuiltValueEnumConst(wireName: r'finance')
  static const UpdateAdminStatusRequestRoleEnum finance = _$updateAdminStatusRequestRoleEnum_finance;
  @BuiltValueEnumConst(wireName: r'support')
  static const UpdateAdminStatusRequestRoleEnum support = _$updateAdminStatusRequestRoleEnum_support;

  static Serializer<UpdateAdminStatusRequestRoleEnum> get serializer => _$updateAdminStatusRequestRoleEnumSerializer;

  const UpdateAdminStatusRequestRoleEnum._(String name): super(name);

  static BuiltSet<UpdateAdminStatusRequestRoleEnum> get values => _$updateAdminStatusRequestRoleEnumValues;
  static UpdateAdminStatusRequestRoleEnum valueOf(String name) => _$updateAdminStatusRequestRoleEnumValueOf(name);
}


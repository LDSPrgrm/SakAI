// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_update_kyc_status_request.g.dart';

/// AdminUpdateKycStatusRequest
///
/// Properties:
/// * [status] 
@BuiltValue()
abstract class AdminUpdateKycStatusRequest implements Built<AdminUpdateKycStatusRequest, AdminUpdateKycStatusRequestBuilder> {
  @BuiltValueField(wireName: r'status')
  AdminUpdateKycStatusRequestStatusEnum get status;
  // enum statusEnum {  approved,  rejected,  };

  AdminUpdateKycStatusRequest._();

  factory AdminUpdateKycStatusRequest([void updates(AdminUpdateKycStatusRequestBuilder b)]) = _$AdminUpdateKycStatusRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminUpdateKycStatusRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminUpdateKycStatusRequest> get serializer => _$AdminUpdateKycStatusRequestSerializer();
}

class _$AdminUpdateKycStatusRequestSerializer implements PrimitiveSerializer<AdminUpdateKycStatusRequest> {
  @override
  final Iterable<Type> types = const [AdminUpdateKycStatusRequest, _$AdminUpdateKycStatusRequest];

  @override
  final String wireName = r'AdminUpdateKycStatusRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminUpdateKycStatusRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(AdminUpdateKycStatusRequestStatusEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminUpdateKycStatusRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminUpdateKycStatusRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdminUpdateKycStatusRequestStatusEnum),
          ) as AdminUpdateKycStatusRequestStatusEnum;
          result.status = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminUpdateKycStatusRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminUpdateKycStatusRequestBuilder();
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

class AdminUpdateKycStatusRequestStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'approved')
  static const AdminUpdateKycStatusRequestStatusEnum approved = _$adminUpdateKycStatusRequestStatusEnum_approved;
  @BuiltValueEnumConst(wireName: r'rejected')
  static const AdminUpdateKycStatusRequestStatusEnum rejected = _$adminUpdateKycStatusRequestStatusEnum_rejected;

  static Serializer<AdminUpdateKycStatusRequestStatusEnum> get serializer => _$adminUpdateKycStatusRequestStatusEnumSerializer;

  const AdminUpdateKycStatusRequestStatusEnum._(String name): super(name);

  static BuiltSet<AdminUpdateKycStatusRequestStatusEnum> get values => _$adminUpdateKycStatusRequestStatusEnumValues;
  static AdminUpdateKycStatusRequestStatusEnum valueOf(String name) => _$adminUpdateKycStatusRequestStatusEnumValueOf(name);
}


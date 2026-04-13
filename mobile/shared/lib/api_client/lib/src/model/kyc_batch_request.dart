// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kyc_batch_request.g.dart';

/// KycBatchRequest
///
/// Properties:
/// * [ids] 
/// * [status] 
@BuiltValue()
abstract class KycBatchRequest implements Built<KycBatchRequest, KycBatchRequestBuilder> {
  @BuiltValueField(wireName: r'ids')
  BuiltList<String> get ids;

  @BuiltValueField(wireName: r'status')
  KycBatchRequestStatusEnum get status;
  // enum statusEnum {  approved,  rejected,  };

  KycBatchRequest._();

  factory KycBatchRequest([void updates(KycBatchRequestBuilder b)]) = _$KycBatchRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KycBatchRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KycBatchRequest> get serializer => _$KycBatchRequestSerializer();
}

class _$KycBatchRequestSerializer implements PrimitiveSerializer<KycBatchRequest> {
  @override
  final Iterable<Type> types = const [KycBatchRequest, _$KycBatchRequest];

  @override
  final String wireName = r'KycBatchRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KycBatchRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'ids';
    yield serializers.serialize(
      object.ids,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(KycBatchRequestStatusEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    KycBatchRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required KycBatchRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'ids':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.ids.replace(valueDes);
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(KycBatchRequestStatusEnum),
          ) as KycBatchRequestStatusEnum;
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
  KycBatchRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KycBatchRequestBuilder();
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

class KycBatchRequestStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'approved')
  static const KycBatchRequestStatusEnum approved = _$kycBatchRequestStatusEnum_approved;
  @BuiltValueEnumConst(wireName: r'rejected')
  static const KycBatchRequestStatusEnum rejected = _$kycBatchRequestStatusEnum_rejected;

  static Serializer<KycBatchRequestStatusEnum> get serializer => _$kycBatchRequestStatusEnumSerializer;

  const KycBatchRequestStatusEnum._(String name): super(name);

  static BuiltSet<KycBatchRequestStatusEnum> get values => _$kycBatchRequestStatusEnumValues;
  static KycBatchRequestStatusEnum valueOf(String name) => _$kycBatchRequestStatusEnumValueOf(name);
}


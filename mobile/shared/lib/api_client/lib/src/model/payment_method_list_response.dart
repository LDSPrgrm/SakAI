// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sakai_api_client/src/model/payment_method_details.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'payment_method_list_response.g.dart';

/// PaymentMethodListResponse
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class PaymentMethodListResponse implements Built<PaymentMethodListResponse, PaymentMethodListResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<PaymentMethodDetails> get data;

  PaymentMethodListResponse._();

  factory PaymentMethodListResponse([void updates(PaymentMethodListResponseBuilder b)]) = _$PaymentMethodListResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PaymentMethodListResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PaymentMethodListResponse> get serializer => _$PaymentMethodListResponseSerializer();
}

class _$PaymentMethodListResponseSerializer implements PrimitiveSerializer<PaymentMethodListResponse> {
  @override
  final Iterable<Type> types = const [PaymentMethodListResponse, _$PaymentMethodListResponse];

  @override
  final String wireName = r'PaymentMethodListResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PaymentMethodListResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(PaymentMethodDetails)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PaymentMethodListResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PaymentMethodListResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(PaymentMethodDetails)]),
          ) as BuiltList<PaymentMethodDetails>;
          result.data.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PaymentMethodListResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PaymentMethodListResponseBuilder();
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


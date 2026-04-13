// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'payment_failure_response.g.dart';

/// PaymentFailureResponse
///
/// Properties:
/// * [code] 
/// * [message] - Human-readable failure reason
/// * [gatewayErrorCode] - Original error code from payment gateway
@BuiltValue()
abstract class PaymentFailureResponse implements Built<PaymentFailureResponse, PaymentFailureResponseBuilder> {
  @BuiltValueField(wireName: r'code')
  PaymentFailureResponseCodeEnum get code;
  // enum codeEnum {  PAYMENT_FAILED,  };

  /// Human-readable failure reason
  @BuiltValueField(wireName: r'message')
  String get message;

  /// Original error code from payment gateway
  @BuiltValueField(wireName: r'gatewayErrorCode')
  String? get gatewayErrorCode;

  PaymentFailureResponse._();

  factory PaymentFailureResponse([void updates(PaymentFailureResponseBuilder b)]) = _$PaymentFailureResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PaymentFailureResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PaymentFailureResponse> get serializer => _$PaymentFailureResponseSerializer();
}

class _$PaymentFailureResponseSerializer implements PrimitiveSerializer<PaymentFailureResponse> {
  @override
  final Iterable<Type> types = const [PaymentFailureResponse, _$PaymentFailureResponse];

  @override
  final String wireName = r'PaymentFailureResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PaymentFailureResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(PaymentFailureResponseCodeEnum),
    );
    yield r'message';
    yield serializers.serialize(
      object.message,
      specifiedType: const FullType(String),
    );
    if (object.gatewayErrorCode != null) {
      yield r'gatewayErrorCode';
      yield serializers.serialize(
        object.gatewayErrorCode,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PaymentFailureResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PaymentFailureResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PaymentFailureResponseCodeEnum),
          ) as PaymentFailureResponseCodeEnum;
          result.code = valueDes;
          break;
        case r'message':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.message = valueDes;
          break;
        case r'gatewayErrorCode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.gatewayErrorCode = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PaymentFailureResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PaymentFailureResponseBuilder();
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

class PaymentFailureResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'PAYMENT_FAILED')
  static const PaymentFailureResponseCodeEnum PAYMENT_FAILED = _$paymentFailureResponseCodeEnum_PAYMENT_FAILED;

  static Serializer<PaymentFailureResponseCodeEnum> get serializer => _$paymentFailureResponseCodeEnumSerializer;

  const PaymentFailureResponseCodeEnum._(String name): super(name);

  static BuiltSet<PaymentFailureResponseCodeEnum> get values => _$paymentFailureResponseCodeEnumValues;
  static PaymentFailureResponseCodeEnum valueOf(String name) => _$paymentFailureResponseCodeEnumValueOf(name);
}


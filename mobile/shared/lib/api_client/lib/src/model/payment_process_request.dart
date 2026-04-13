// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'payment_process_request.g.dart';

/// PaymentProcessRequest
///
/// Properties:
/// * [rideId] - UUID of the completed ride
/// * [paymentMethodToken] - Tokenized payment method from mobile SDK (e.g., Stripe PaymentIntent token)
@BuiltValue()
abstract class PaymentProcessRequest implements Built<PaymentProcessRequest, PaymentProcessRequestBuilder> {
  /// UUID of the completed ride
  @BuiltValueField(wireName: r'rideId')
  String get rideId;

  /// Tokenized payment method from mobile SDK (e.g., Stripe PaymentIntent token)
  @BuiltValueField(wireName: r'paymentMethodToken')
  String get paymentMethodToken;

  PaymentProcessRequest._();

  factory PaymentProcessRequest([void updates(PaymentProcessRequestBuilder b)]) = _$PaymentProcessRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PaymentProcessRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PaymentProcessRequest> get serializer => _$PaymentProcessRequestSerializer();
}

class _$PaymentProcessRequestSerializer implements PrimitiveSerializer<PaymentProcessRequest> {
  @override
  final Iterable<Type> types = const [PaymentProcessRequest, _$PaymentProcessRequest];

  @override
  final String wireName = r'PaymentProcessRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PaymentProcessRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'rideId';
    yield serializers.serialize(
      object.rideId,
      specifiedType: const FullType(String),
    );
    yield r'paymentMethodToken';
    yield serializers.serialize(
      object.paymentMethodToken,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PaymentProcessRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PaymentProcessRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'rideId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.rideId = valueDes;
          break;
        case r'paymentMethodToken':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.paymentMethodToken = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PaymentProcessRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PaymentProcessRequestBuilder();
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


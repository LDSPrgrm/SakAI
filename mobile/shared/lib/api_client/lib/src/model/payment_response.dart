// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sakai_api_client/src/model/payment_method.dart';
import 'package:sakai_api_client/src/model/payment_status.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'payment_response.g.dart';

/// PaymentResponse
///
/// Properties:
/// * [id] 
/// * [rideId] 
/// * [amount] 
/// * [currency] 
/// * [method] 
/// * [status] 
/// * [gatewayTransactionId] - External payment gateway reference (e.g., Stripe PaymentIntent ID)
/// * [failureReason] - Error message or code when payment fails
/// * [processedAt] 
@BuiltValue()
abstract class PaymentResponse implements Built<PaymentResponse, PaymentResponseBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'rideId')
  String get rideId;

  @BuiltValueField(wireName: r'amount')
  double get amount;

  @BuiltValueField(wireName: r'currency')
  String get currency;

  @BuiltValueField(wireName: r'method')
  PaymentMethod get method;
  // enum methodEnum {  cash,  card,  gcash,  paymaya,  };

  @BuiltValueField(wireName: r'status')
  PaymentStatus get status;
  // enum statusEnum {  pending,  completed,  failed,  refunded,  };

  /// External payment gateway reference (e.g., Stripe PaymentIntent ID)
  @BuiltValueField(wireName: r'gatewayTransactionId')
  String? get gatewayTransactionId;

  /// Error message or code when payment fails
  @BuiltValueField(wireName: r'failureReason')
  String? get failureReason;

  @BuiltValueField(wireName: r'processedAt')
  DateTime get processedAt;

  PaymentResponse._();

  factory PaymentResponse([void updates(PaymentResponseBuilder b)]) = _$PaymentResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PaymentResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PaymentResponse> get serializer => _$PaymentResponseSerializer();
}

class _$PaymentResponseSerializer implements PrimitiveSerializer<PaymentResponse> {
  @override
  final Iterable<Type> types = const [PaymentResponse, _$PaymentResponse];

  @override
  final String wireName = r'PaymentResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PaymentResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'rideId';
    yield serializers.serialize(
      object.rideId,
      specifiedType: const FullType(String),
    );
    yield r'amount';
    yield serializers.serialize(
      object.amount,
      specifiedType: const FullType(double),
    );
    yield r'currency';
    yield serializers.serialize(
      object.currency,
      specifiedType: const FullType(String),
    );
    yield r'method';
    yield serializers.serialize(
      object.method,
      specifiedType: const FullType(PaymentMethod),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(PaymentStatus),
    );
    if (object.gatewayTransactionId != null) {
      yield r'gatewayTransactionId';
      yield serializers.serialize(
        object.gatewayTransactionId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.failureReason != null) {
      yield r'failureReason';
      yield serializers.serialize(
        object.failureReason,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'processedAt';
    yield serializers.serialize(
      object.processedAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PaymentResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PaymentResponseBuilder result,
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
        case r'rideId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.rideId = valueDes;
          break;
        case r'amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(double),
          ) as double;
          result.amount = valueDes;
          break;
        case r'currency':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.currency = valueDes;
          break;
        case r'method':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PaymentMethod),
          ) as PaymentMethod;
          result.method = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PaymentStatus),
          ) as PaymentStatus;
          result.status = valueDes;
          break;
        case r'gatewayTransactionId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.gatewayTransactionId = valueDes;
          break;
        case r'failureReason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.failureReason = valueDes;
          break;
        case r'processedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.processedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PaymentResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PaymentResponseBuilder();
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


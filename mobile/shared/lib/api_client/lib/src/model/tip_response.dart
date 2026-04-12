//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sakai_api_client/src/model/payment_method.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'tip_response.g.dart';

/// TipResponse
///
/// Properties:
/// * [rideId] 
/// * [baseFare] - Original base fare amount
/// * [tipAmount] - Tip amount added
/// * [finalTotal] - Total amount including tip
/// * [currency] 
/// * [paymentMethod] 
/// * [transactionId] - Payment gateway transaction ID
/// * [processedAt] 
@BuiltValue()
abstract class TipResponse implements Built<TipResponse, TipResponseBuilder> {
  @BuiltValueField(wireName: r'rideId')
  String get rideId;

  /// Original base fare amount
  @BuiltValueField(wireName: r'baseFare')
  double get baseFare;

  /// Tip amount added
  @BuiltValueField(wireName: r'tipAmount')
  double get tipAmount;

  /// Total amount including tip
  @BuiltValueField(wireName: r'finalTotal')
  double get finalTotal;

  @BuiltValueField(wireName: r'currency')
  String get currency;

  @BuiltValueField(wireName: r'paymentMethod')
  PaymentMethod get paymentMethod;
  // enum paymentMethodEnum {  cash,  card,  };

  /// Payment gateway transaction ID
  @BuiltValueField(wireName: r'transactionId')
  String get transactionId;

  @BuiltValueField(wireName: r'processedAt')
  DateTime? get processedAt;

  TipResponse._();

  factory TipResponse([void updates(TipResponseBuilder b)]) = _$TipResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TipResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TipResponse> get serializer => _$TipResponseSerializer();
}

class _$TipResponseSerializer implements PrimitiveSerializer<TipResponse> {
  @override
  final Iterable<Type> types = const [TipResponse, _$TipResponse];

  @override
  final String wireName = r'TipResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TipResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'rideId';
    yield serializers.serialize(
      object.rideId,
      specifiedType: const FullType(String),
    );
    yield r'baseFare';
    yield serializers.serialize(
      object.baseFare,
      specifiedType: const FullType(double),
    );
    yield r'tipAmount';
    yield serializers.serialize(
      object.tipAmount,
      specifiedType: const FullType(double),
    );
    yield r'finalTotal';
    yield serializers.serialize(
      object.finalTotal,
      specifiedType: const FullType(double),
    );
    yield r'currency';
    yield serializers.serialize(
      object.currency,
      specifiedType: const FullType(String),
    );
    yield r'paymentMethod';
    yield serializers.serialize(
      object.paymentMethod,
      specifiedType: const FullType(PaymentMethod),
    );
    yield r'transactionId';
    yield serializers.serialize(
      object.transactionId,
      specifiedType: const FullType(String),
    );
    if (object.processedAt != null) {
      yield r'processedAt';
      yield serializers.serialize(
        object.processedAt,
        specifiedType: const FullType(DateTime),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    TipResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TipResponseBuilder result,
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
        case r'baseFare':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(double),
          ) as double;
          result.baseFare = valueDes;
          break;
        case r'tipAmount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(double),
          ) as double;
          result.tipAmount = valueDes;
          break;
        case r'finalTotal':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(double),
          ) as double;
          result.finalTotal = valueDes;
          break;
        case r'currency':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.currency = valueDes;
          break;
        case r'paymentMethod':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PaymentMethod),
          ) as PaymentMethod;
          result.paymentMethod = valueDes;
          break;
        case r'transactionId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.transactionId = valueDes;
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
  TipResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TipResponseBuilder();
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


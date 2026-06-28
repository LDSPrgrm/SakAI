// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sakai_api_client/src/model/fare_breakdown.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ws_event_ride_completed.g.dart';

/// **Event:** `ride.completed` **Direction:** server → both passenger and driver Fired when the driver completes the ride and the fare is finalised. Passenger app should show the receipt; driver app should show the earnings reveal.  `fare_breakdown` may be omitted by older servers — clients should gracefully fall back to displaying only the total `fare`. 
///
/// Properties:
/// * [rideId] 
/// * [fare] - Total fare charged to the passenger in PHP.
/// * [fareBreakdown] 
/// * [paymentMethod] 
/// * [tipAmount] - Driver tip in PHP, when one was already received.
/// * [completedAt] 
@BuiltValue()
abstract class WsEventRideCompleted implements Built<WsEventRideCompleted, WsEventRideCompletedBuilder> {
  @BuiltValueField(wireName: r'ride_id')
  String get rideId;

  /// Total fare charged to the passenger in PHP.
  @BuiltValueField(wireName: r'fare')
  double get fare;

  @BuiltValueField(wireName: r'fare_breakdown')
  FareBreakdown? get fareBreakdown;

  @BuiltValueField(wireName: r'payment_method')
  WsEventRideCompletedPaymentMethodEnum get paymentMethod;
  // enum paymentMethodEnum {  cash,  gcash,  paymaya,  card,  };

  /// Driver tip in PHP, when one was already received.
  @BuiltValueField(wireName: r'tip_amount')
  double? get tipAmount;

  @BuiltValueField(wireName: r'completed_at')
  DateTime get completedAt;

  WsEventRideCompleted._();

  factory WsEventRideCompleted([void updates(WsEventRideCompletedBuilder b)]) = _$WsEventRideCompleted;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WsEventRideCompletedBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WsEventRideCompleted> get serializer => _$WsEventRideCompletedSerializer();
}

class _$WsEventRideCompletedSerializer implements PrimitiveSerializer<WsEventRideCompleted> {
  @override
  final Iterable<Type> types = const [WsEventRideCompleted, _$WsEventRideCompleted];

  @override
  final String wireName = r'WsEventRideCompleted';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    WsEventRideCompleted object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'ride_id';
    yield serializers.serialize(
      object.rideId,
      specifiedType: const FullType(String),
    );
    yield r'fare';
    yield serializers.serialize(
      object.fare,
      specifiedType: const FullType(double),
    );
    if (object.fareBreakdown != null) {
      yield r'fare_breakdown';
      yield serializers.serialize(
        object.fareBreakdown,
        specifiedType: const FullType(FareBreakdown),
      );
    }
    yield r'payment_method';
    yield serializers.serialize(
      object.paymentMethod,
      specifiedType: const FullType(WsEventRideCompletedPaymentMethodEnum),
    );
    if (object.tipAmount != null) {
      yield r'tip_amount';
      yield serializers.serialize(
        object.tipAmount,
        specifiedType: const FullType.nullable(double),
      );
    }
    yield r'completed_at';
    yield serializers.serialize(
      object.completedAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    WsEventRideCompleted object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required WsEventRideCompletedBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'ride_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.rideId = valueDes;
          break;
        case r'fare':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(double),
          ) as double;
          result.fare = valueDes;
          break;
        case r'fare_breakdown':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FareBreakdown),
          ) as FareBreakdown;
          result.fareBreakdown.replace(valueDes);
          break;
        case r'payment_method':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(WsEventRideCompletedPaymentMethodEnum),
          ) as WsEventRideCompletedPaymentMethodEnum;
          result.paymentMethod = valueDes;
          break;
        case r'tip_amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(double),
          ) as double?;
          if (valueDes == null) continue;
          result.tipAmount = valueDes;
          break;
        case r'completed_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.completedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  WsEventRideCompleted deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WsEventRideCompletedBuilder();
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

class WsEventRideCompletedPaymentMethodEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'cash')
  static const WsEventRideCompletedPaymentMethodEnum cash = _$wsEventRideCompletedPaymentMethodEnum_cash;
  @BuiltValueEnumConst(wireName: r'gcash')
  static const WsEventRideCompletedPaymentMethodEnum gcash = _$wsEventRideCompletedPaymentMethodEnum_gcash;
  @BuiltValueEnumConst(wireName: r'paymaya')
  static const WsEventRideCompletedPaymentMethodEnum paymaya = _$wsEventRideCompletedPaymentMethodEnum_paymaya;
  @BuiltValueEnumConst(wireName: r'card')
  static const WsEventRideCompletedPaymentMethodEnum card = _$wsEventRideCompletedPaymentMethodEnum_card;

  static Serializer<WsEventRideCompletedPaymentMethodEnum> get serializer => _$wsEventRideCompletedPaymentMethodEnumSerializer;

  const WsEventRideCompletedPaymentMethodEnum._(String name): super(name);

  static BuiltSet<WsEventRideCompletedPaymentMethodEnum> get values => _$wsEventRideCompletedPaymentMethodEnumValues;
  static WsEventRideCompletedPaymentMethodEnum valueOf(String name) => _$wsEventRideCompletedPaymentMethodEnumValueOf(name);
}


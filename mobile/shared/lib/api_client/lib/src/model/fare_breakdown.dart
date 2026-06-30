// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'fare_breakdown.g.dart';

/// Components of the final fare. Sum of (`base_fare` + `distance_charge` + `time_charge` + `booking_fee`) × `surge_multiplier` − `discount` should equal `fare` on `WsEventRideCompleted`. 
///
/// Properties:
/// * [baseFare] 
/// * [distanceCharge] 
/// * [timeCharge] 
/// * [bookingFee] 
/// * [surgeMultiplier] - Active surge multiplier (1.0 means no surge). Omitted when 1.0.
/// * [discount] - Total promo / loyalty discount applied. Omitted when zero.
@BuiltValue()
abstract class FareBreakdown implements Built<FareBreakdown, FareBreakdownBuilder> {
  @BuiltValueField(wireName: r'base_fare')
  double get baseFare;

  @BuiltValueField(wireName: r'distance_charge')
  double get distanceCharge;

  @BuiltValueField(wireName: r'time_charge')
  double get timeCharge;

  @BuiltValueField(wireName: r'booking_fee')
  double get bookingFee;

  /// Active surge multiplier (1.0 means no surge). Omitted when 1.0.
  @BuiltValueField(wireName: r'surge_multiplier')
  double? get surgeMultiplier;

  /// Total promo / loyalty discount applied. Omitted when zero.
  @BuiltValueField(wireName: r'discount')
  double? get discount;

  FareBreakdown._();

  factory FareBreakdown([void updates(FareBreakdownBuilder b)]) = _$FareBreakdown;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FareBreakdownBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FareBreakdown> get serializer => _$FareBreakdownSerializer();
}

class _$FareBreakdownSerializer implements PrimitiveSerializer<FareBreakdown> {
  @override
  final Iterable<Type> types = const [FareBreakdown, _$FareBreakdown];

  @override
  final String wireName = r'FareBreakdown';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FareBreakdown object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'base_fare';
    yield serializers.serialize(
      object.baseFare,
      specifiedType: const FullType(double),
    );
    yield r'distance_charge';
    yield serializers.serialize(
      object.distanceCharge,
      specifiedType: const FullType(double),
    );
    yield r'time_charge';
    yield serializers.serialize(
      object.timeCharge,
      specifiedType: const FullType(double),
    );
    yield r'booking_fee';
    yield serializers.serialize(
      object.bookingFee,
      specifiedType: const FullType(double),
    );
    if (object.surgeMultiplier != null) {
      yield r'surge_multiplier';
      yield serializers.serialize(
        object.surgeMultiplier,
        specifiedType: const FullType(double),
      );
    }
    if (object.discount != null) {
      yield r'discount';
      yield serializers.serialize(
        object.discount,
        specifiedType: const FullType(double),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    FareBreakdown object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required FareBreakdownBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'base_fare':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(double),
          ) as double;
          result.baseFare = valueDes;
          break;
        case r'distance_charge':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(double),
          ) as double;
          result.distanceCharge = valueDes;
          break;
        case r'time_charge':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(double),
          ) as double;
          result.timeCharge = valueDes;
          break;
        case r'booking_fee':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(double),
          ) as double;
          result.bookingFee = valueDes;
          break;
        case r'surge_multiplier':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(double),
          ) as double;
          result.surgeMultiplier = valueDes;
          break;
        case r'discount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(double),
          ) as double;
          result.discount = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  FareBreakdown deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FareBreakdownBuilder();
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


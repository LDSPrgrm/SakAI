//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'fare_config.g.dart';

/// FareConfig
///
/// Properties:
/// * [vehicleType] 
/// * [baseFare] 
/// * [perKmRate] 
/// * [perMinRate] 
/// * [minimumFare] 
/// * [bookingFee] 
/// * [cancellationFee] 
@BuiltValue()
abstract class FareConfig implements Built<FareConfig, FareConfigBuilder> {
  @BuiltValueField(wireName: r'vehicle_type')
  String get vehicleType;

  @BuiltValueField(wireName: r'base_fare')
  num get baseFare;

  @BuiltValueField(wireName: r'per_km_rate')
  num get perKmRate;

  @BuiltValueField(wireName: r'per_min_rate')
  num get perMinRate;

  @BuiltValueField(wireName: r'minimum_fare')
  num get minimumFare;

  @BuiltValueField(wireName: r'booking_fee')
  num get bookingFee;

  @BuiltValueField(wireName: r'cancellation_fee')
  num get cancellationFee;

  FareConfig._();

  factory FareConfig([void updates(FareConfigBuilder b)]) = _$FareConfig;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FareConfigBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FareConfig> get serializer => _$FareConfigSerializer();
}

class _$FareConfigSerializer implements PrimitiveSerializer<FareConfig> {
  @override
  final Iterable<Type> types = const [FareConfig, _$FareConfig];

  @override
  final String wireName = r'FareConfig';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FareConfig object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'vehicle_type';
    yield serializers.serialize(
      object.vehicleType,
      specifiedType: const FullType(String),
    );
    yield r'base_fare';
    yield serializers.serialize(
      object.baseFare,
      specifiedType: const FullType(num),
    );
    yield r'per_km_rate';
    yield serializers.serialize(
      object.perKmRate,
      specifiedType: const FullType(num),
    );
    yield r'per_min_rate';
    yield serializers.serialize(
      object.perMinRate,
      specifiedType: const FullType(num),
    );
    yield r'minimum_fare';
    yield serializers.serialize(
      object.minimumFare,
      specifiedType: const FullType(num),
    );
    yield r'booking_fee';
    yield serializers.serialize(
      object.bookingFee,
      specifiedType: const FullType(num),
    );
    yield r'cancellation_fee';
    yield serializers.serialize(
      object.cancellationFee,
      specifiedType: const FullType(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    FareConfig object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required FareConfigBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'vehicle_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.vehicleType = valueDes;
          break;
        case r'base_fare':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.baseFare = valueDes;
          break;
        case r'per_km_rate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.perKmRate = valueDes;
          break;
        case r'per_min_rate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.perMinRate = valueDes;
          break;
        case r'minimum_fare':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.minimumFare = valueDes;
          break;
        case r'booking_fee':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.bookingFee = valueDes;
          break;
        case r'cancellation_fee':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.cancellationFee = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  FareConfig deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FareConfigBuilder();
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


// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'fare_config.g.dart';

/// FareConfig
///
/// Properties:
/// * [id] 
/// * [vehicleType] 
/// * [baseFare] 
/// * [perKmRate] 
/// * [perMinRate] 
/// * [minimumFare] 
/// * [bookingFee] 
/// * [cancellationFee] 
/// * [updatedAt] 
/// * [updatedBy] 
/// * [updatedByName] - Display name of the admin who last updated this row (joined from users.name).
@BuiltValue()
abstract class FareConfig implements Built<FareConfig, FareConfigBuilder> {
  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'vehicle_type')
  String? get vehicleType;

  @BuiltValueField(wireName: r'base_fare')
  num? get baseFare;

  @BuiltValueField(wireName: r'per_km_rate')
  num? get perKmRate;

  @BuiltValueField(wireName: r'per_min_rate')
  num? get perMinRate;

  @BuiltValueField(wireName: r'minimum_fare')
  num? get minimumFare;

  @BuiltValueField(wireName: r'booking_fee')
  num? get bookingFee;

  @BuiltValueField(wireName: r'cancellation_fee')
  num? get cancellationFee;

  @BuiltValueField(wireName: r'updated_at')
  DateTime? get updatedAt;

  @BuiltValueField(wireName: r'updated_by')
  String? get updatedBy;

  /// Display name of the admin who last updated this row (joined from users.name).
  @BuiltValueField(wireName: r'updated_by_name')
  String? get updatedByName;

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
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
    if (object.vehicleType != null) {
      yield r'vehicle_type';
      yield serializers.serialize(
        object.vehicleType,
        specifiedType: const FullType(String),
      );
    }
    if (object.baseFare != null) {
      yield r'base_fare';
      yield serializers.serialize(
        object.baseFare,
        specifiedType: const FullType(num),
      );
    }
    if (object.perKmRate != null) {
      yield r'per_km_rate';
      yield serializers.serialize(
        object.perKmRate,
        specifiedType: const FullType(num),
      );
    }
    if (object.perMinRate != null) {
      yield r'per_min_rate';
      yield serializers.serialize(
        object.perMinRate,
        specifiedType: const FullType(num),
      );
    }
    if (object.minimumFare != null) {
      yield r'minimum_fare';
      yield serializers.serialize(
        object.minimumFare,
        specifiedType: const FullType(num),
      );
    }
    if (object.bookingFee != null) {
      yield r'booking_fee';
      yield serializers.serialize(
        object.bookingFee,
        specifiedType: const FullType(num),
      );
    }
    if (object.cancellationFee != null) {
      yield r'cancellation_fee';
      yield serializers.serialize(
        object.cancellationFee,
        specifiedType: const FullType(num),
      );
    }
    if (object.updatedAt != null) {
      yield r'updated_at';
      yield serializers.serialize(
        object.updatedAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.updatedBy != null) {
      yield r'updated_by';
      yield serializers.serialize(
        object.updatedBy,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.updatedByName != null) {
      yield r'updated_by_name';
      yield serializers.serialize(
        object.updatedByName,
        specifiedType: const FullType(String),
      );
    }
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
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
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
        case r'updated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.updatedAt = valueDes;
          break;
        case r'updated_by':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.updatedBy = valueDes;
          break;
        case r'updated_by_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.updatedByName = valueDes;
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


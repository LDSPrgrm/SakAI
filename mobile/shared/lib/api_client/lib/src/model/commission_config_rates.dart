// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'commission_config_rates.g.dart';

/// CommissionConfigRates
///
/// Properties:
/// * [motorcycle] 
/// * [tricycle] 
/// * [car] 
/// * [other] 
@BuiltValue()
abstract class CommissionConfigRates implements Built<CommissionConfigRates, CommissionConfigRatesBuilder> {
  @BuiltValueField(wireName: r'motorcycle')
  num? get motorcycle;

  @BuiltValueField(wireName: r'tricycle')
  num? get tricycle;

  @BuiltValueField(wireName: r'car')
  num? get car;

  @BuiltValueField(wireName: r'other')
  num? get other;

  CommissionConfigRates._();

  factory CommissionConfigRates([void updates(CommissionConfigRatesBuilder b)]) = _$CommissionConfigRates;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CommissionConfigRatesBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CommissionConfigRates> get serializer => _$CommissionConfigRatesSerializer();
}

class _$CommissionConfigRatesSerializer implements PrimitiveSerializer<CommissionConfigRates> {
  @override
  final Iterable<Type> types = const [CommissionConfigRates, _$CommissionConfigRates];

  @override
  final String wireName = r'CommissionConfigRates';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CommissionConfigRates object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.motorcycle != null) {
      yield r'motorcycle';
      yield serializers.serialize(
        object.motorcycle,
        specifiedType: const FullType(num),
      );
    }
    if (object.tricycle != null) {
      yield r'tricycle';
      yield serializers.serialize(
        object.tricycle,
        specifiedType: const FullType(num),
      );
    }
    if (object.car != null) {
      yield r'car';
      yield serializers.serialize(
        object.car,
        specifiedType: const FullType(num),
      );
    }
    if (object.other != null) {
      yield r'other';
      yield serializers.serialize(
        object.other,
        specifiedType: const FullType(num),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CommissionConfigRates object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CommissionConfigRatesBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'motorcycle':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.motorcycle = valueDes;
          break;
        case r'tricycle':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.tricycle = valueDes;
          break;
        case r'car':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.car = valueDes;
          break;
        case r'other':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.other = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CommissionConfigRates deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CommissionConfigRatesBuilder();
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


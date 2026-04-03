//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sakai_api_client/src/model/commission_config_rates.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'commission_config.g.dart';

/// CommissionConfig
///
/// Properties:
/// * [rates] 
/// * [minimumCommission] 
/// * [promotionalOverride] 
@BuiltValue()
abstract class CommissionConfig implements Built<CommissionConfig, CommissionConfigBuilder> {
  @BuiltValueField(wireName: r'rates')
  CommissionConfigRates? get rates;

  @BuiltValueField(wireName: r'minimum_commission')
  num? get minimumCommission;

  @BuiltValueField(wireName: r'promotional_override')
  num? get promotionalOverride;

  CommissionConfig._();

  factory CommissionConfig([void updates(CommissionConfigBuilder b)]) = _$CommissionConfig;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CommissionConfigBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CommissionConfig> get serializer => _$CommissionConfigSerializer();
}

class _$CommissionConfigSerializer implements PrimitiveSerializer<CommissionConfig> {
  @override
  final Iterable<Type> types = const [CommissionConfig, _$CommissionConfig];

  @override
  final String wireName = r'CommissionConfig';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CommissionConfig object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.rates != null) {
      yield r'rates';
      yield serializers.serialize(
        object.rates,
        specifiedType: const FullType(CommissionConfigRates),
      );
    }
    if (object.minimumCommission != null) {
      yield r'minimum_commission';
      yield serializers.serialize(
        object.minimumCommission,
        specifiedType: const FullType(num),
      );
    }
    if (object.promotionalOverride != null) {
      yield r'promotional_override';
      yield serializers.serialize(
        object.promotionalOverride,
        specifiedType: const FullType(num),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CommissionConfig object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CommissionConfigBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'rates':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CommissionConfigRates),
          ) as CommissionConfigRates;
          result.rates.replace(valueDes);
          break;
        case r'minimum_commission':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.minimumCommission = valueDes;
          break;
        case r'promotional_override':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.promotionalOverride = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CommissionConfig deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CommissionConfigBuilder();
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


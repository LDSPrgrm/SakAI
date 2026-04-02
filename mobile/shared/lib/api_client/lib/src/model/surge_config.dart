//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sakai_api_client/src/model/blackout_hour.dart';
import 'package:sakai_api_client/src/model/geo_json_feature_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'surge_config.g.dart';

/// SurgeConfig
///
/// Properties:
/// * [enabled] 
/// * [maxMultiplier] 
/// * [triggerRatio] 
/// * [zones] 
/// * [blackoutHours] 
@BuiltValue()
abstract class SurgeConfig implements Built<SurgeConfig, SurgeConfigBuilder> {
  @BuiltValueField(wireName: r'enabled')
  bool get enabled;

  @BuiltValueField(wireName: r'max_multiplier')
  num get maxMultiplier;

  @BuiltValueField(wireName: r'trigger_ratio')
  num get triggerRatio;

  @BuiltValueField(wireName: r'zones')
  GeoJSONFeatureCollection? get zones;

  @BuiltValueField(wireName: r'blackout_hours')
  BuiltList<BlackoutHour>? get blackoutHours;

  SurgeConfig._();

  factory SurgeConfig([void updates(SurgeConfigBuilder b)]) = _$SurgeConfig;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SurgeConfigBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SurgeConfig> get serializer => _$SurgeConfigSerializer();
}

class _$SurgeConfigSerializer implements PrimitiveSerializer<SurgeConfig> {
  @override
  final Iterable<Type> types = const [SurgeConfig, _$SurgeConfig];

  @override
  final String wireName = r'SurgeConfig';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SurgeConfig object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'enabled';
    yield serializers.serialize(
      object.enabled,
      specifiedType: const FullType(bool),
    );
    yield r'max_multiplier';
    yield serializers.serialize(
      object.maxMultiplier,
      specifiedType: const FullType(num),
    );
    yield r'trigger_ratio';
    yield serializers.serialize(
      object.triggerRatio,
      specifiedType: const FullType(num),
    );
    if (object.zones != null) {
      yield r'zones';
      yield serializers.serialize(
        object.zones,
        specifiedType: const FullType(GeoJSONFeatureCollection),
      );
    }
    if (object.blackoutHours != null) {
      yield r'blackout_hours';
      yield serializers.serialize(
        object.blackoutHours,
        specifiedType: const FullType(BuiltList, [FullType(BlackoutHour)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SurgeConfig object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SurgeConfigBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'enabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.enabled = valueDes;
          break;
        case r'max_multiplier':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.maxMultiplier = valueDes;
          break;
        case r'trigger_ratio':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.triggerRatio = valueDes;
          break;
        case r'zones':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GeoJSONFeatureCollection),
          ) as GeoJSONFeatureCollection;
          result.zones.replace(valueDes);
          break;
        case r'blackout_hours':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(BlackoutHour)]),
          ) as BuiltList<BlackoutHour>;
          result.blackoutHours.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SurgeConfig deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SurgeConfigBuilder();
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


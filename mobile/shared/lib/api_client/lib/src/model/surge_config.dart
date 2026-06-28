// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sakai_api_client/src/model/surge_zone.dart';
import 'package:sakai_api_client/src/model/blackout_hour.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'surge_config.g.dart';

/// SurgeConfig
///
/// Properties:
/// * [id] 
/// * [enabled] 
/// * [maxMultiplier] 
/// * [triggerRatio] 
/// * [zones] - Named polygons with per-zone multipliers. The fare calculator does origin-in-polygon (ray-casting) against this list during SimulateFare; falls back to max_multiplier when no zone matches. 
/// * [blackoutHours] 
/// * [updatedAt] 
/// * [updatedBy] 
/// * [updatedByName] - Admin display name resolved via LEFT JOIN users on updated_by.
@BuiltValue()
abstract class SurgeConfig implements Built<SurgeConfig, SurgeConfigBuilder> {
  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'enabled')
  bool? get enabled;

  @BuiltValueField(wireName: r'max_multiplier')
  num? get maxMultiplier;

  @BuiltValueField(wireName: r'trigger_ratio')
  num? get triggerRatio;

  /// Named polygons with per-zone multipliers. The fare calculator does origin-in-polygon (ray-casting) against this list during SimulateFare; falls back to max_multiplier when no zone matches. 
  @BuiltValueField(wireName: r'zones')
  BuiltList<SurgeZone>? get zones;

  @BuiltValueField(wireName: r'blackout_hours')
  BuiltList<BlackoutHour>? get blackoutHours;

  @BuiltValueField(wireName: r'updated_at')
  DateTime? get updatedAt;

  @BuiltValueField(wireName: r'updated_by')
  String? get updatedBy;

  /// Admin display name resolved via LEFT JOIN users on updated_by.
  @BuiltValueField(wireName: r'updated_by_name')
  String? get updatedByName;

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
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
    if (object.enabled != null) {
      yield r'enabled';
      yield serializers.serialize(
        object.enabled,
        specifiedType: const FullType(bool),
      );
    }
    if (object.maxMultiplier != null) {
      yield r'max_multiplier';
      yield serializers.serialize(
        object.maxMultiplier,
        specifiedType: const FullType(num),
      );
    }
    if (object.triggerRatio != null) {
      yield r'trigger_ratio';
      yield serializers.serialize(
        object.triggerRatio,
        specifiedType: const FullType(num),
      );
    }
    if (object.zones != null) {
      yield r'zones';
      yield serializers.serialize(
        object.zones,
        specifiedType: const FullType(BuiltList, [FullType(SurgeZone)]),
      );
    }
    if (object.blackoutHours != null) {
      yield r'blackout_hours';
      yield serializers.serialize(
        object.blackoutHours,
        specifiedType: const FullType(BuiltList, [FullType(BlackoutHour)]),
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
        specifiedType: const FullType(String),
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
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
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
            specifiedType: const FullType(BuiltList, [FullType(SurgeZone)]),
          ) as BuiltList<SurgeZone>;
          result.zones.replace(valueDes);
          break;
        case r'blackout_hours':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(BlackoutHour)]),
          ) as BuiltList<BlackoutHour>;
          result.blackoutHours.replace(valueDes);
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
            specifiedType: const FullType(String),
          ) as String;
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


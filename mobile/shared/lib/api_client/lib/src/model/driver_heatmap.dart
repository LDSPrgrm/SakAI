// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sakai_api_client/src/model/heatmap_position.dart';
import 'package:built_collection/built_collection.dart';
import 'package:sakai_api_client/src/model/heatmap_bounds.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'driver_heatmap.g.dart';

/// DriverHeatmap
///
/// Properties:
/// * [positions] 
/// * [bounds] 
/// * [generatedAt] 
@BuiltValue()
abstract class DriverHeatmap implements Built<DriverHeatmap, DriverHeatmapBuilder> {
  @BuiltValueField(wireName: r'positions')
  BuiltList<HeatmapPosition>? get positions;

  @BuiltValueField(wireName: r'bounds')
  HeatmapBounds? get bounds;

  @BuiltValueField(wireName: r'generated_at')
  DateTime? get generatedAt;

  DriverHeatmap._();

  factory DriverHeatmap([void updates(DriverHeatmapBuilder b)]) = _$DriverHeatmap;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DriverHeatmapBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DriverHeatmap> get serializer => _$DriverHeatmapSerializer();
}

class _$DriverHeatmapSerializer implements PrimitiveSerializer<DriverHeatmap> {
  @override
  final Iterable<Type> types = const [DriverHeatmap, _$DriverHeatmap];

  @override
  final String wireName = r'DriverHeatmap';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DriverHeatmap object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.positions != null) {
      yield r'positions';
      yield serializers.serialize(
        object.positions,
        specifiedType: const FullType(BuiltList, [FullType(HeatmapPosition)]),
      );
    }
    if (object.bounds != null) {
      yield r'bounds';
      yield serializers.serialize(
        object.bounds,
        specifiedType: const FullType(HeatmapBounds),
      );
    }
    if (object.generatedAt != null) {
      yield r'generated_at';
      yield serializers.serialize(
        object.generatedAt,
        specifiedType: const FullType(DateTime),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    DriverHeatmap object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DriverHeatmapBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'positions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(HeatmapPosition)]),
          ) as BuiltList<HeatmapPosition>;
          result.positions.replace(valueDes);
          break;
        case r'bounds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(HeatmapBounds),
          ) as HeatmapBounds;
          result.bounds.replace(valueDes);
          break;
        case r'generated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.generatedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DriverHeatmap deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DriverHeatmapBuilder();
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


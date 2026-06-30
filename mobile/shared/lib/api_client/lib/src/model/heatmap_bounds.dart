// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'heatmap_bounds.g.dart';

/// HeatmapBounds
///
/// Properties:
/// * [north] 
/// * [south] 
/// * [east] 
/// * [west] 
@BuiltValue()
abstract class HeatmapBounds implements Built<HeatmapBounds, HeatmapBoundsBuilder> {
  @BuiltValueField(wireName: r'north')
  double? get north;

  @BuiltValueField(wireName: r'south')
  double? get south;

  @BuiltValueField(wireName: r'east')
  double? get east;

  @BuiltValueField(wireName: r'west')
  double? get west;

  HeatmapBounds._();

  factory HeatmapBounds([void updates(HeatmapBoundsBuilder b)]) = _$HeatmapBounds;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(HeatmapBoundsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<HeatmapBounds> get serializer => _$HeatmapBoundsSerializer();
}

class _$HeatmapBoundsSerializer implements PrimitiveSerializer<HeatmapBounds> {
  @override
  final Iterable<Type> types = const [HeatmapBounds, _$HeatmapBounds];

  @override
  final String wireName = r'HeatmapBounds';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    HeatmapBounds object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.north != null) {
      yield r'north';
      yield serializers.serialize(
        object.north,
        specifiedType: const FullType(double),
      );
    }
    if (object.south != null) {
      yield r'south';
      yield serializers.serialize(
        object.south,
        specifiedType: const FullType(double),
      );
    }
    if (object.east != null) {
      yield r'east';
      yield serializers.serialize(
        object.east,
        specifiedType: const FullType(double),
      );
    }
    if (object.west != null) {
      yield r'west';
      yield serializers.serialize(
        object.west,
        specifiedType: const FullType(double),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    HeatmapBounds object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required HeatmapBoundsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'north':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(double),
          ) as double;
          result.north = valueDes;
          break;
        case r'south':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(double),
          ) as double;
          result.south = valueDes;
          break;
        case r'east':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(double),
          ) as double;
          result.east = valueDes;
          break;
        case r'west':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(double),
          ) as double;
          result.west = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  HeatmapBounds deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = HeatmapBoundsBuilder();
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


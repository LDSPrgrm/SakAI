//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'geo_json_polygon.g.dart';

/// GeoJSONPolygon
///
/// Properties:
/// * [type] 
/// * [coordinates] 
@BuiltValue()
abstract class GeoJSONPolygon implements Built<GeoJSONPolygon, GeoJSONPolygonBuilder> {
  @BuiltValueField(wireName: r'type')
  GeoJSONPolygonTypeEnum get type;
  // enum typeEnum {  Polygon,  };

  @BuiltValueField(wireName: r'coordinates')
  BuiltList<BuiltList<BuiltList<num>>> get coordinates;

  GeoJSONPolygon._();

  factory GeoJSONPolygon([void updates(GeoJSONPolygonBuilder b)]) = _$GeoJSONPolygon;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GeoJSONPolygonBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GeoJSONPolygon> get serializer => _$GeoJSONPolygonSerializer();
}

class _$GeoJSONPolygonSerializer implements PrimitiveSerializer<GeoJSONPolygon> {
  @override
  final Iterable<Type> types = const [GeoJSONPolygon, _$GeoJSONPolygon];

  @override
  final String wireName = r'GeoJSONPolygon';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GeoJSONPolygon object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(GeoJSONPolygonTypeEnum),
    );
    yield r'coordinates';
    yield serializers.serialize(
      object.coordinates,
      specifiedType: const FullType(BuiltList, [FullType(BuiltList, [FullType(BuiltList, [FullType(num)])])]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GeoJSONPolygon object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GeoJSONPolygonBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GeoJSONPolygonTypeEnum),
          ) as GeoJSONPolygonTypeEnum;
          result.type = valueDes;
          break;
        case r'coordinates':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(BuiltList, [FullType(BuiltList, [FullType(num)])])]),
          ) as BuiltList<BuiltList<BuiltList<num>>>;
          result.coordinates.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GeoJSONPolygon deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GeoJSONPolygonBuilder();
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

class GeoJSONPolygonTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'Polygon')
  static const GeoJSONPolygonTypeEnum polygon = _$geoJSONPolygonTypeEnum_polygon;

  static Serializer<GeoJSONPolygonTypeEnum> get serializer => _$geoJSONPolygonTypeEnumSerializer;

  const GeoJSONPolygonTypeEnum._(String name): super(name);

  static BuiltSet<GeoJSONPolygonTypeEnum> get values => _$geoJSONPolygonTypeEnumValues;
  static GeoJSONPolygonTypeEnum valueOf(String name) => _$geoJSONPolygonTypeEnumValueOf(name);
}


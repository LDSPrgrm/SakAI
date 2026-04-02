//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'geo_json_multi_polygon.g.dart';

/// GeoJSONMultiPolygon
///
/// Properties:
/// * [type] 
/// * [coordinates] 
@BuiltValue()
abstract class GeoJSONMultiPolygon implements Built<GeoJSONMultiPolygon, GeoJSONMultiPolygonBuilder> {
  @BuiltValueField(wireName: r'type')
  GeoJSONMultiPolygonTypeEnum get type;
  // enum typeEnum {  MultiPolygon,  };

  @BuiltValueField(wireName: r'coordinates')
  BuiltList<BuiltList<BuiltList<BuiltList<num>>>> get coordinates;

  GeoJSONMultiPolygon._();

  factory GeoJSONMultiPolygon([void updates(GeoJSONMultiPolygonBuilder b)]) = _$GeoJSONMultiPolygon;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GeoJSONMultiPolygonBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GeoJSONMultiPolygon> get serializer => _$GeoJSONMultiPolygonSerializer();
}

class _$GeoJSONMultiPolygonSerializer implements PrimitiveSerializer<GeoJSONMultiPolygon> {
  @override
  final Iterable<Type> types = const [GeoJSONMultiPolygon, _$GeoJSONMultiPolygon];

  @override
  final String wireName = r'GeoJSONMultiPolygon';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GeoJSONMultiPolygon object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(GeoJSONMultiPolygonTypeEnum),
    );
    yield r'coordinates';
    yield serializers.serialize(
      object.coordinates,
      specifiedType: const FullType(BuiltList, [FullType(BuiltList, [FullType(BuiltList, [FullType(BuiltList, [FullType(num)])])])]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GeoJSONMultiPolygon object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GeoJSONMultiPolygonBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GeoJSONMultiPolygonTypeEnum),
          ) as GeoJSONMultiPolygonTypeEnum;
          result.type = valueDes;
          break;
        case r'coordinates':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(BuiltList, [FullType(BuiltList, [FullType(BuiltList, [FullType(num)])])])]),
          ) as BuiltList<BuiltList<BuiltList<BuiltList<num>>>>;
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
  GeoJSONMultiPolygon deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GeoJSONMultiPolygonBuilder();
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

class GeoJSONMultiPolygonTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'MultiPolygon')
  static const GeoJSONMultiPolygonTypeEnum multiPolygon = _$geoJSONMultiPolygonTypeEnum_multiPolygon;

  static Serializer<GeoJSONMultiPolygonTypeEnum> get serializer => _$geoJSONMultiPolygonTypeEnumSerializer;

  const GeoJSONMultiPolygonTypeEnum._(String name): super(name);

  static BuiltSet<GeoJSONMultiPolygonTypeEnum> get values => _$geoJSONMultiPolygonTypeEnumValues;
  static GeoJSONMultiPolygonTypeEnum valueOf(String name) => _$geoJSONMultiPolygonTypeEnumValueOf(name);
}


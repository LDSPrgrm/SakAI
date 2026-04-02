//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sakai_api_client/src/model/geo_json_point.dart';
import 'package:built_collection/built_collection.dart';
import 'package:sakai_api_client/src/model/geo_json_multi_polygon.dart';
import 'package:sakai_api_client/src/model/geo_json_polygon.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/one_of.dart';

part 'geo_json_geometry.g.dart';

/// GeoJSONGeometry
///
/// Properties:
/// * [type] 
/// * [coordinates] 
@BuiltValue()
abstract class GeoJSONGeometry implements Built<GeoJSONGeometry, GeoJSONGeometryBuilder> {
  /// One Of [GeoJSONMultiPolygon], [GeoJSONPoint], [GeoJSONPolygon]
  OneOf get oneOf;

  static const String discriminatorFieldName = r'type';

  static const Map<String, Type> discriminatorMapping = {
    r'GeoJSONMultiPolygon': GeoJSONMultiPolygon,
    r'GeoJSONPoint': GeoJSONPoint,
    r'GeoJSONPolygon': GeoJSONPolygon,
  };

  GeoJSONGeometry._();

  factory GeoJSONGeometry([void updates(GeoJSONGeometryBuilder b)]) = _$GeoJSONGeometry;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GeoJSONGeometryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GeoJSONGeometry> get serializer => _$GeoJSONGeometrySerializer();
}

extension GeoJSONGeometryDiscriminatorExt on GeoJSONGeometry {
    String? get discriminatorValue {
        if (this is GeoJSONMultiPolygon) {
            return r'GeoJSONMultiPolygon';
        }
        if (this is GeoJSONPoint) {
            return r'GeoJSONPoint';
        }
        if (this is GeoJSONPolygon) {
            return r'GeoJSONPolygon';
        }
        return null;
    }
}
extension GeoJSONGeometryBuilderDiscriminatorExt on GeoJSONGeometryBuilder {
    String? get discriminatorValue {
        if (this is GeoJSONMultiPolygonBuilder) {
            return r'GeoJSONMultiPolygon';
        }
        if (this is GeoJSONPointBuilder) {
            return r'GeoJSONPoint';
        }
        if (this is GeoJSONPolygonBuilder) {
            return r'GeoJSONPolygon';
        }
        return null;
    }
}

class _$GeoJSONGeometrySerializer implements PrimitiveSerializer<GeoJSONGeometry> {
  @override
  final Iterable<Type> types = const [GeoJSONGeometry, _$GeoJSONGeometry];

  @override
  final String wireName = r'GeoJSONGeometry';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GeoJSONGeometry object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
  }

  @override
  Object serialize(
    Serializers serializers,
    GeoJSONGeometry object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final oneOf = object.oneOf;
    return serializers.serialize(oneOf.value, specifiedType: FullType(oneOf.valueType))!;
  }

  @override
  GeoJSONGeometry deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GeoJSONGeometryBuilder();
    Object? oneOfDataSrc;
    final serializedList = (serialized as Iterable<Object?>).toList();
    final discIndex = serializedList.indexOf(GeoJSONGeometry.discriminatorFieldName) + 1;
    final discValue = serializers.deserialize(serializedList[discIndex], specifiedType: FullType(String)) as String;
    oneOfDataSrc = serialized;
    final oneOfTypes = [GeoJSONMultiPolygon, GeoJSONPoint, GeoJSONPolygon, ];
    Object oneOfResult;
    Type oneOfType;
    switch (discValue) {
      case r'GeoJSONMultiPolygon':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(GeoJSONMultiPolygon),
        ) as GeoJSONMultiPolygon;
        oneOfType = GeoJSONMultiPolygon;
        break;
      case r'GeoJSONPoint':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(GeoJSONPoint),
        ) as GeoJSONPoint;
        oneOfType = GeoJSONPoint;
        break;
      case r'GeoJSONPolygon':
        oneOfResult = serializers.deserialize(
          oneOfDataSrc,
          specifiedType: FullType(GeoJSONPolygon),
        ) as GeoJSONPolygon;
        oneOfType = GeoJSONPolygon;
        break;
      default:
        throw UnsupportedError("Couldn't deserialize oneOf for the discriminator value: ${discValue}");
    }
    result.oneOf = OneOfDynamic(typeIndex: oneOfTypes.indexOf(oneOfType), types: oneOfTypes, value: oneOfResult);
    return result.build();
  }
}

class GeoJSONGeometryTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'Point')
  static const GeoJSONGeometryTypeEnum point = _$geoJSONGeometryTypeEnum_point;
  @BuiltValueEnumConst(wireName: r'Polygon')
  static const GeoJSONGeometryTypeEnum polygon = _$geoJSONGeometryTypeEnum_polygon;
  @BuiltValueEnumConst(wireName: r'MultiPolygon')
  static const GeoJSONGeometryTypeEnum multiPolygon = _$geoJSONGeometryTypeEnum_multiPolygon;

  static Serializer<GeoJSONGeometryTypeEnum> get serializer => _$geoJSONGeometryTypeEnumSerializer;

  const GeoJSONGeometryTypeEnum._(String name): super(name);

  static BuiltSet<GeoJSONGeometryTypeEnum> get values => _$geoJSONGeometryTypeEnumValues;
  static GeoJSONGeometryTypeEnum valueOf(String name) => _$geoJSONGeometryTypeEnumValueOf(name);
}


// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'geo_json_feature_collection_features_inner_geometry.g.dart';

/// GeoJSONFeatureCollectionFeaturesInnerGeometry
///
/// Properties:
/// * [type] 
/// * [coordinates] 
@BuiltValue()
abstract class GeoJSONFeatureCollectionFeaturesInnerGeometry implements Built<GeoJSONFeatureCollectionFeaturesInnerGeometry, GeoJSONFeatureCollectionFeaturesInnerGeometryBuilder> {
  @BuiltValueField(wireName: r'type')
  GeoJSONFeatureCollectionFeaturesInnerGeometryTypeEnum get type;
  // enum typeEnum {  Polygon,  MultiPolygon,  };

  @BuiltValueField(wireName: r'coordinates')
  BuiltList<BuiltList<BuiltList<num>>> get coordinates;

  GeoJSONFeatureCollectionFeaturesInnerGeometry._();

  factory GeoJSONFeatureCollectionFeaturesInnerGeometry([void updates(GeoJSONFeatureCollectionFeaturesInnerGeometryBuilder b)]) = _$GeoJSONFeatureCollectionFeaturesInnerGeometry;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GeoJSONFeatureCollectionFeaturesInnerGeometryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GeoJSONFeatureCollectionFeaturesInnerGeometry> get serializer => _$GeoJSONFeatureCollectionFeaturesInnerGeometrySerializer();
}

class _$GeoJSONFeatureCollectionFeaturesInnerGeometrySerializer implements PrimitiveSerializer<GeoJSONFeatureCollectionFeaturesInnerGeometry> {
  @override
  final Iterable<Type> types = const [GeoJSONFeatureCollectionFeaturesInnerGeometry, _$GeoJSONFeatureCollectionFeaturesInnerGeometry];

  @override
  final String wireName = r'GeoJSONFeatureCollectionFeaturesInnerGeometry';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GeoJSONFeatureCollectionFeaturesInnerGeometry object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(GeoJSONFeatureCollectionFeaturesInnerGeometryTypeEnum),
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
    GeoJSONFeatureCollectionFeaturesInnerGeometry object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GeoJSONFeatureCollectionFeaturesInnerGeometryBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GeoJSONFeatureCollectionFeaturesInnerGeometryTypeEnum),
          ) as GeoJSONFeatureCollectionFeaturesInnerGeometryTypeEnum;
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
  GeoJSONFeatureCollectionFeaturesInnerGeometry deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GeoJSONFeatureCollectionFeaturesInnerGeometryBuilder();
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

class GeoJSONFeatureCollectionFeaturesInnerGeometryTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'Polygon')
  static const GeoJSONFeatureCollectionFeaturesInnerGeometryTypeEnum polygon = _$geoJSONFeatureCollectionFeaturesInnerGeometryTypeEnum_polygon;
  @BuiltValueEnumConst(wireName: r'MultiPolygon')
  static const GeoJSONFeatureCollectionFeaturesInnerGeometryTypeEnum multiPolygon = _$geoJSONFeatureCollectionFeaturesInnerGeometryTypeEnum_multiPolygon;

  static Serializer<GeoJSONFeatureCollectionFeaturesInnerGeometryTypeEnum> get serializer => _$geoJSONFeatureCollectionFeaturesInnerGeometryTypeEnumSerializer;

  const GeoJSONFeatureCollectionFeaturesInnerGeometryTypeEnum._(String name): super(name);

  static BuiltSet<GeoJSONFeatureCollectionFeaturesInnerGeometryTypeEnum> get values => _$geoJSONFeatureCollectionFeaturesInnerGeometryTypeEnumValues;
  static GeoJSONFeatureCollectionFeaturesInnerGeometryTypeEnum valueOf(String name) => _$geoJSONFeatureCollectionFeaturesInnerGeometryTypeEnumValueOf(name);
}


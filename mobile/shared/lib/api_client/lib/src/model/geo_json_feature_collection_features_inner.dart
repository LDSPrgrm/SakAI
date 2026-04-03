//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sakai_api_client/src/model/geo_json_feature_collection_features_inner_geometry.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'geo_json_feature_collection_features_inner.g.dart';

/// GeoJSONFeatureCollectionFeaturesInner
///
/// Properties:
/// * [type] 
/// * [geometry] 
/// * [properties] 
@BuiltValue()
abstract class GeoJSONFeatureCollectionFeaturesInner implements Built<GeoJSONFeatureCollectionFeaturesInner, GeoJSONFeatureCollectionFeaturesInnerBuilder> {
  @BuiltValueField(wireName: r'type')
  GeoJSONFeatureCollectionFeaturesInnerTypeEnum get type;
  // enum typeEnum {  Feature,  };

  @BuiltValueField(wireName: r'geometry')
  GeoJSONFeatureCollectionFeaturesInnerGeometry get geometry;

  @BuiltValueField(wireName: r'properties')
  BuiltMap<String, JsonObject?>? get properties;

  GeoJSONFeatureCollectionFeaturesInner._();

  factory GeoJSONFeatureCollectionFeaturesInner([void updates(GeoJSONFeatureCollectionFeaturesInnerBuilder b)]) = _$GeoJSONFeatureCollectionFeaturesInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GeoJSONFeatureCollectionFeaturesInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GeoJSONFeatureCollectionFeaturesInner> get serializer => _$GeoJSONFeatureCollectionFeaturesInnerSerializer();
}

class _$GeoJSONFeatureCollectionFeaturesInnerSerializer implements PrimitiveSerializer<GeoJSONFeatureCollectionFeaturesInner> {
  @override
  final Iterable<Type> types = const [GeoJSONFeatureCollectionFeaturesInner, _$GeoJSONFeatureCollectionFeaturesInner];

  @override
  final String wireName = r'GeoJSONFeatureCollectionFeaturesInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GeoJSONFeatureCollectionFeaturesInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(GeoJSONFeatureCollectionFeaturesInnerTypeEnum),
    );
    yield r'geometry';
    yield serializers.serialize(
      object.geometry,
      specifiedType: const FullType(GeoJSONFeatureCollectionFeaturesInnerGeometry),
    );
    if (object.properties != null) {
      yield r'properties';
      yield serializers.serialize(
        object.properties,
        specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GeoJSONFeatureCollectionFeaturesInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GeoJSONFeatureCollectionFeaturesInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GeoJSONFeatureCollectionFeaturesInnerTypeEnum),
          ) as GeoJSONFeatureCollectionFeaturesInnerTypeEnum;
          result.type = valueDes;
          break;
        case r'geometry':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GeoJSONFeatureCollectionFeaturesInnerGeometry),
          ) as GeoJSONFeatureCollectionFeaturesInnerGeometry;
          result.geometry.replace(valueDes);
          break;
        case r'properties':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>;
          result.properties.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GeoJSONFeatureCollectionFeaturesInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GeoJSONFeatureCollectionFeaturesInnerBuilder();
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

class GeoJSONFeatureCollectionFeaturesInnerTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'Feature')
  static const GeoJSONFeatureCollectionFeaturesInnerTypeEnum feature = _$geoJSONFeatureCollectionFeaturesInnerTypeEnum_feature;

  static Serializer<GeoJSONFeatureCollectionFeaturesInnerTypeEnum> get serializer => _$geoJSONFeatureCollectionFeaturesInnerTypeEnumSerializer;

  const GeoJSONFeatureCollectionFeaturesInnerTypeEnum._(String name): super(name);

  static BuiltSet<GeoJSONFeatureCollectionFeaturesInnerTypeEnum> get values => _$geoJSONFeatureCollectionFeaturesInnerTypeEnumValues;
  static GeoJSONFeatureCollectionFeaturesInnerTypeEnum valueOf(String name) => _$geoJSONFeatureCollectionFeaturesInnerTypeEnumValueOf(name);
}


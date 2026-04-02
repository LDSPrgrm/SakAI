//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sakai_api_client/src/model/geo_json_geometry.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'geo_json_feature.g.dart';

/// GeoJSONFeature
///
/// Properties:
/// * [type] 
/// * [geometry] 
/// * [properties] 
@BuiltValue()
abstract class GeoJSONFeature implements Built<GeoJSONFeature, GeoJSONFeatureBuilder> {
  @BuiltValueField(wireName: r'type')
  GeoJSONFeatureTypeEnum get type;
  // enum typeEnum {  Feature,  };

  @BuiltValueField(wireName: r'geometry')
  GeoJSONGeometry get geometry;

  @BuiltValueField(wireName: r'properties')
  JsonObject get properties;

  GeoJSONFeature._();

  factory GeoJSONFeature([void updates(GeoJSONFeatureBuilder b)]) = _$GeoJSONFeature;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GeoJSONFeatureBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GeoJSONFeature> get serializer => _$GeoJSONFeatureSerializer();
}

class _$GeoJSONFeatureSerializer implements PrimitiveSerializer<GeoJSONFeature> {
  @override
  final Iterable<Type> types = const [GeoJSONFeature, _$GeoJSONFeature];

  @override
  final String wireName = r'GeoJSONFeature';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GeoJSONFeature object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(GeoJSONFeatureTypeEnum),
    );
    yield r'geometry';
    yield serializers.serialize(
      object.geometry,
      specifiedType: const FullType(GeoJSONGeometry),
    );
    yield r'properties';
    yield serializers.serialize(
      object.properties,
      specifiedType: const FullType(JsonObject),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GeoJSONFeature object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GeoJSONFeatureBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GeoJSONFeatureTypeEnum),
          ) as GeoJSONFeatureTypeEnum;
          result.type = valueDes;
          break;
        case r'geometry':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GeoJSONGeometry),
          ) as GeoJSONGeometry;
          result.geometry.replace(valueDes);
          break;
        case r'properties':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.properties = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GeoJSONFeature deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GeoJSONFeatureBuilder();
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

class GeoJSONFeatureTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'Feature')
  static const GeoJSONFeatureTypeEnum feature = _$geoJSONFeatureTypeEnum_feature;

  static Serializer<GeoJSONFeatureTypeEnum> get serializer => _$geoJSONFeatureTypeEnumSerializer;

  const GeoJSONFeatureTypeEnum._(String name): super(name);

  static BuiltSet<GeoJSONFeatureTypeEnum> get values => _$geoJSONFeatureTypeEnumValues;
  static GeoJSONFeatureTypeEnum valueOf(String name) => _$geoJSONFeatureTypeEnumValueOf(name);
}


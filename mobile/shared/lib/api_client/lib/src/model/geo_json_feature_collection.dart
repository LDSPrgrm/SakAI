// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sakai_api_client/src/model/geo_json_feature_collection_features_inner.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'geo_json_feature_collection.g.dart';

/// GeoJSONFeatureCollection
///
/// Properties:
/// * [type] 
/// * [features] 
@BuiltValue()
abstract class GeoJSONFeatureCollection implements Built<GeoJSONFeatureCollection, GeoJSONFeatureCollectionBuilder> {
  @BuiltValueField(wireName: r'type')
  GeoJSONFeatureCollectionTypeEnum get type;
  // enum typeEnum {  FeatureCollection,  };

  @BuiltValueField(wireName: r'features')
  BuiltList<GeoJSONFeatureCollectionFeaturesInner> get features;

  GeoJSONFeatureCollection._();

  factory GeoJSONFeatureCollection([void updates(GeoJSONFeatureCollectionBuilder b)]) = _$GeoJSONFeatureCollection;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GeoJSONFeatureCollectionBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GeoJSONFeatureCollection> get serializer => _$GeoJSONFeatureCollectionSerializer();
}

class _$GeoJSONFeatureCollectionSerializer implements PrimitiveSerializer<GeoJSONFeatureCollection> {
  @override
  final Iterable<Type> types = const [GeoJSONFeatureCollection, _$GeoJSONFeatureCollection];

  @override
  final String wireName = r'GeoJSONFeatureCollection';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GeoJSONFeatureCollection object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(GeoJSONFeatureCollectionTypeEnum),
    );
    yield r'features';
    yield serializers.serialize(
      object.features,
      specifiedType: const FullType(BuiltList, [FullType(GeoJSONFeatureCollectionFeaturesInner)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GeoJSONFeatureCollection object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GeoJSONFeatureCollectionBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GeoJSONFeatureCollectionTypeEnum),
          ) as GeoJSONFeatureCollectionTypeEnum;
          result.type = valueDes;
          break;
        case r'features':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(GeoJSONFeatureCollectionFeaturesInner)]),
          ) as BuiltList<GeoJSONFeatureCollectionFeaturesInner>;
          result.features.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GeoJSONFeatureCollection deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GeoJSONFeatureCollectionBuilder();
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

class GeoJSONFeatureCollectionTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'FeatureCollection')
  static const GeoJSONFeatureCollectionTypeEnum featureCollection = _$geoJSONFeatureCollectionTypeEnum_featureCollection;

  static Serializer<GeoJSONFeatureCollectionTypeEnum> get serializer => _$geoJSONFeatureCollectionTypeEnumSerializer;

  const GeoJSONFeatureCollectionTypeEnum._(String name): super(name);

  static BuiltSet<GeoJSONFeatureCollectionTypeEnum> get values => _$geoJSONFeatureCollectionTypeEnumValues;
  static GeoJSONFeatureCollectionTypeEnum valueOf(String name) => _$geoJSONFeatureCollectionTypeEnumValueOf(name);
}


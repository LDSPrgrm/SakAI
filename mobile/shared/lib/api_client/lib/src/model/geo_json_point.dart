//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'geo_json_point.g.dart';

/// GeoJSONPoint
///
/// Properties:
/// * [type] 
/// * [coordinates] 
@BuiltValue()
abstract class GeoJSONPoint implements Built<GeoJSONPoint, GeoJSONPointBuilder> {
  @BuiltValueField(wireName: r'type')
  GeoJSONPointTypeEnum get type;
  // enum typeEnum {  Point,  };

  @BuiltValueField(wireName: r'coordinates')
  BuiltList<num> get coordinates;

  GeoJSONPoint._();

  factory GeoJSONPoint([void updates(GeoJSONPointBuilder b)]) = _$GeoJSONPoint;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GeoJSONPointBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GeoJSONPoint> get serializer => _$GeoJSONPointSerializer();
}

class _$GeoJSONPointSerializer implements PrimitiveSerializer<GeoJSONPoint> {
  @override
  final Iterable<Type> types = const [GeoJSONPoint, _$GeoJSONPoint];

  @override
  final String wireName = r'GeoJSONPoint';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GeoJSONPoint object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(GeoJSONPointTypeEnum),
    );
    yield r'coordinates';
    yield serializers.serialize(
      object.coordinates,
      specifiedType: const FullType(BuiltList, [FullType(num)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GeoJSONPoint object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GeoJSONPointBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GeoJSONPointTypeEnum),
          ) as GeoJSONPointTypeEnum;
          result.type = valueDes;
          break;
        case r'coordinates':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(num)]),
          ) as BuiltList<num>;
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
  GeoJSONPoint deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GeoJSONPointBuilder();
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

class GeoJSONPointTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'Point')
  static const GeoJSONPointTypeEnum point = _$geoJSONPointTypeEnum_point;

  static Serializer<GeoJSONPointTypeEnum> get serializer => _$geoJSONPointTypeEnumSerializer;

  const GeoJSONPointTypeEnum._(String name): super(name);

  static BuiltSet<GeoJSONPointTypeEnum> get values => _$geoJSONPointTypeEnumValues;
  static GeoJSONPointTypeEnum valueOf(String name) => _$geoJSONPointTypeEnumValueOf(name);
}


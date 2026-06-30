// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'surge_zone.g.dart';

/// Named polygon + multiplier. Consumed by the fare calculator for point-in-polygon origin lookup (usecase.FindZoneMultiplier) and reused as the boundary shape for service areas. 
///
/// Properties:
/// * [name] 
/// * [multiplier] 
/// * [polygon] - Ring of [lat, lng] pairs (closing vertex optional).
@BuiltValue()
abstract class SurgeZone implements Built<SurgeZone, SurgeZoneBuilder> {
  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'multiplier')
  double get multiplier;

  /// Ring of [lat, lng] pairs (closing vertex optional).
  @BuiltValueField(wireName: r'polygon')
  BuiltList<BuiltList<num>> get polygon;

  SurgeZone._();

  factory SurgeZone([void updates(SurgeZoneBuilder b)]) = _$SurgeZone;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SurgeZoneBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SurgeZone> get serializer => _$SurgeZoneSerializer();
}

class _$SurgeZoneSerializer implements PrimitiveSerializer<SurgeZone> {
  @override
  final Iterable<Type> types = const [SurgeZone, _$SurgeZone];

  @override
  final String wireName = r'SurgeZone';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SurgeZone object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'multiplier';
    yield serializers.serialize(
      object.multiplier,
      specifiedType: const FullType(double),
    );
    yield r'polygon';
    yield serializers.serialize(
      object.polygon,
      specifiedType: const FullType(BuiltList, [FullType(BuiltList, [FullType(num)])]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SurgeZone object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SurgeZoneBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'multiplier':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(double),
          ) as double;
          result.multiplier = valueDes;
          break;
        case r'polygon':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(BuiltList, [FullType(num)])]),
          ) as BuiltList<BuiltList<num>>;
          result.polygon.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SurgeZone deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SurgeZoneBuilder();
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


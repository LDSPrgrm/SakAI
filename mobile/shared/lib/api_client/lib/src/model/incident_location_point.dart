// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'incident_location_point.g.dart';

/// IncidentLocationPoint
///
/// Properties:
/// * [lat] 
/// * [lng] 
/// * [recordedAt] 
@BuiltValue()
abstract class IncidentLocationPoint implements Built<IncidentLocationPoint, IncidentLocationPointBuilder> {
  @BuiltValueField(wireName: r'lat')
  double get lat;

  @BuiltValueField(wireName: r'lng')
  double get lng;

  @BuiltValueField(wireName: r'recorded_at')
  DateTime get recordedAt;

  IncidentLocationPoint._();

  factory IncidentLocationPoint([void updates(IncidentLocationPointBuilder b)]) = _$IncidentLocationPoint;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(IncidentLocationPointBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<IncidentLocationPoint> get serializer => _$IncidentLocationPointSerializer();
}

class _$IncidentLocationPointSerializer implements PrimitiveSerializer<IncidentLocationPoint> {
  @override
  final Iterable<Type> types = const [IncidentLocationPoint, _$IncidentLocationPoint];

  @override
  final String wireName = r'IncidentLocationPoint';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    IncidentLocationPoint object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'lat';
    yield serializers.serialize(
      object.lat,
      specifiedType: const FullType(double),
    );
    yield r'lng';
    yield serializers.serialize(
      object.lng,
      specifiedType: const FullType(double),
    );
    yield r'recorded_at';
    yield serializers.serialize(
      object.recordedAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    IncidentLocationPoint object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required IncidentLocationPointBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'lat':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(double),
          ) as double;
          result.lat = valueDes;
          break;
        case r'lng':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(double),
          ) as double;
          result.lng = valueDes;
          break;
        case r'recorded_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.recordedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  IncidentLocationPoint deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = IncidentLocationPointBuilder();
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


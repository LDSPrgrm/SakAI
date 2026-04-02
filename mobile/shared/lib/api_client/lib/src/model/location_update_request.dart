//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sakai_api_client/src/model/lat_lng.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'location_update_request.g.dart';

/// LocationUpdateRequest
///
/// Properties:
/// * [location] 
/// * [heading] - Compass heading in degrees (0–360), optional. Used to rotate driver icon on map.
@BuiltValue()
abstract class LocationUpdateRequest implements Built<LocationUpdateRequest, LocationUpdateRequestBuilder> {
  @BuiltValueField(wireName: r'location')
  LatLng get location;

  /// Compass heading in degrees (0–360), optional. Used to rotate driver icon on map.
  @BuiltValueField(wireName: r'heading')
  double? get heading;

  LocationUpdateRequest._();

  factory LocationUpdateRequest([void updates(LocationUpdateRequestBuilder b)]) = _$LocationUpdateRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(LocationUpdateRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<LocationUpdateRequest> get serializer => _$LocationUpdateRequestSerializer();
}

class _$LocationUpdateRequestSerializer implements PrimitiveSerializer<LocationUpdateRequest> {
  @override
  final Iterable<Type> types = const [LocationUpdateRequest, _$LocationUpdateRequest];

  @override
  final String wireName = r'LocationUpdateRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    LocationUpdateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'location';
    yield serializers.serialize(
      object.location,
      specifiedType: const FullType(LatLng),
    );
    if (object.heading != null) {
      yield r'heading';
      yield serializers.serialize(
        object.heading,
        specifiedType: const FullType(double),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    LocationUpdateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required LocationUpdateRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'location':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(LatLng),
          ) as LatLng;
          result.location.replace(valueDes);
          break;
        case r'heading':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(double),
          ) as double;
          result.heading = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  LocationUpdateRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = LocationUpdateRequestBuilder();
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


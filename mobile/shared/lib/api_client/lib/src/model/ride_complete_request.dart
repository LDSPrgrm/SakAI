// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sakai_api_client/src/model/lat_lng.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ride_complete_request.g.dart';

/// RideCompleteRequest
///
/// Properties:
/// * [driverLocation] - Driver's current GPS coordinates at time of completion
@BuiltValue()
abstract class RideCompleteRequest implements Built<RideCompleteRequest, RideCompleteRequestBuilder> {
  /// Driver's current GPS coordinates at time of completion
  @BuiltValueField(wireName: r'driver_location')
  LatLng get driverLocation;

  RideCompleteRequest._();

  factory RideCompleteRequest([void updates(RideCompleteRequestBuilder b)]) = _$RideCompleteRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RideCompleteRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RideCompleteRequest> get serializer => _$RideCompleteRequestSerializer();
}

class _$RideCompleteRequestSerializer implements PrimitiveSerializer<RideCompleteRequest> {
  @override
  final Iterable<Type> types = const [RideCompleteRequest, _$RideCompleteRequest];

  @override
  final String wireName = r'RideCompleteRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RideCompleteRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'driver_location';
    yield serializers.serialize(
      object.driverLocation,
      specifiedType: const FullType(LatLng),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RideCompleteRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RideCompleteRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'driver_location':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(LatLng),
          ) as LatLng;
          result.driverLocation.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RideCompleteRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RideCompleteRequestBuilder();
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


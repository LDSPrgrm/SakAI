//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sakai_api_client/src/model/lat_lng.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ride_arrive_request.g.dart';

/// RideArriveRequest
///
/// Properties:
/// * [driverLocation] 
@BuiltValue()
abstract class RideArriveRequest implements Built<RideArriveRequest, RideArriveRequestBuilder> {
  @BuiltValueField(wireName: r'driver_location')
  LatLng get driverLocation;

  RideArriveRequest._();

  factory RideArriveRequest([void updates(RideArriveRequestBuilder b)]) = _$RideArriveRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RideArriveRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RideArriveRequest> get serializer => _$RideArriveRequestSerializer();
}

class _$RideArriveRequestSerializer implements PrimitiveSerializer<RideArriveRequest> {
  @override
  final Iterable<Type> types = const [RideArriveRequest, _$RideArriveRequest];

  @override
  final String wireName = r'RideArriveRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RideArriveRequest object, {
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
    RideArriveRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RideArriveRequestBuilder result,
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
  RideArriveRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RideArriveRequestBuilder();
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


// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sakai_api_client/src/model/ride_status.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ride_event_payload.g.dart';

/// Consistent payload for ride WebSocket events
///
/// Properties:
/// * [rideId] 
/// * [status] 
/// * [driverId] 
/// * [passengerId] 
@BuiltValue()
abstract class RideEventPayload implements Built<RideEventPayload, RideEventPayloadBuilder> {
  @BuiltValueField(wireName: r'ride_id')
  String? get rideId;

  @BuiltValueField(wireName: r'status')
  RideStatus? get status;
  // enum statusEnum {  created,  requested,  accepted,  arrived,  in_progress,  payment_pending,  completed,  cancelled,  };

  @BuiltValueField(wireName: r'driver_id')
  String? get driverId;

  @BuiltValueField(wireName: r'passenger_id')
  String? get passengerId;

  RideEventPayload._();

  factory RideEventPayload([void updates(RideEventPayloadBuilder b)]) = _$RideEventPayload;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RideEventPayloadBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RideEventPayload> get serializer => _$RideEventPayloadSerializer();
}

class _$RideEventPayloadSerializer implements PrimitiveSerializer<RideEventPayload> {
  @override
  final Iterable<Type> types = const [RideEventPayload, _$RideEventPayload];

  @override
  final String wireName = r'RideEventPayload';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RideEventPayload object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.rideId != null) {
      yield r'ride_id';
      yield serializers.serialize(
        object.rideId,
        specifiedType: const FullType(String),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(RideStatus),
      );
    }
    if (object.driverId != null) {
      yield r'driver_id';
      yield serializers.serialize(
        object.driverId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.passengerId != null) {
      yield r'passenger_id';
      yield serializers.serialize(
        object.passengerId,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    RideEventPayload object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RideEventPayloadBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'ride_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.rideId = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(RideStatus),
          ) as RideStatus;
          result.status = valueDes;
          break;
        case r'driver_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.driverId = valueDes;
          break;
        case r'passenger_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.passengerId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RideEventPayload deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RideEventPayloadBuilder();
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


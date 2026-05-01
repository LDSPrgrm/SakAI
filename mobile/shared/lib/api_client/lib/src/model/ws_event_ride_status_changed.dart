// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sakai_api_client/src/model/ride_status.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ws_event_ride_status_changed.g.dart';

/// **Event:** `ride.status_changed` **Direction:** server â†’ both passenger and driver Fired on transitions: `arrived`, `in_progress`, `completed`. Both apps should update their local ride state from this event. 
///
/// Properties:
/// * [rideId] 
/// * [status] 
/// * [updatedAt] 
@BuiltValue()
abstract class WsEventRideStatusChanged implements Built<WsEventRideStatusChanged, WsEventRideStatusChangedBuilder> {
  @BuiltValueField(wireName: r'ride_id')
  String get rideId;

  @BuiltValueField(wireName: r'status')
  RideStatus get status;
  // enum statusEnum {  requested,  accepted,  arrived,  in_progress,  completed,  cancelled,  };

  @BuiltValueField(wireName: r'updated_at')
  DateTime get updatedAt;

  WsEventRideStatusChanged._();

  factory WsEventRideStatusChanged([void updates(WsEventRideStatusChangedBuilder b)]) = _$WsEventRideStatusChanged;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WsEventRideStatusChangedBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WsEventRideStatusChanged> get serializer => _$WsEventRideStatusChangedSerializer();
}

class _$WsEventRideStatusChangedSerializer implements PrimitiveSerializer<WsEventRideStatusChanged> {
  @override
  final Iterable<Type> types = const [WsEventRideStatusChanged, _$WsEventRideStatusChanged];

  @override
  final String wireName = r'WsEventRideStatusChanged';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    WsEventRideStatusChanged object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'ride_id';
    yield serializers.serialize(
      object.rideId,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(RideStatus),
    );
    yield r'updated_at';
    yield serializers.serialize(
      object.updatedAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    WsEventRideStatusChanged object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required WsEventRideStatusChangedBuilder result,
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
        case r'updated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.updatedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  WsEventRideStatusChanged deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WsEventRideStatusChangedBuilder();
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


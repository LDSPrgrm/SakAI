// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sakai_api_client/src/model/ride_status.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ws_event_ride_state_sync.g.dart';

/// **Event:** `ride.state_sync` **Direction:** server → client (originating user only) Emitted by the WS handler when a reconnecting client's `last_event_id` falls outside the replay window. Carries a snapshot of the user's active-ride state so the UI can reconcile without round-tripping REST.  When `has_active_ride` is false, the client should drop into the \"no active ride\" screen and clear local ride state. 
///
/// Properties:
/// * [hasActiveRide] 
/// * [rideId] 
/// * [status] 
/// * [driverId] 
/// * [passengerId] 
/// * [updatedAt] 
@BuiltValue()
abstract class WsEventRideStateSync implements Built<WsEventRideStateSync, WsEventRideStateSyncBuilder> {
  @BuiltValueField(wireName: r'has_active_ride')
  bool get hasActiveRide;

  @BuiltValueField(wireName: r'ride_id')
  String? get rideId;

  @BuiltValueField(wireName: r'status')
  RideStatus? get status;
  // enum statusEnum {  created,  requested,  accepted,  arrived,  in_progress,  payment_pending,  completed,  cancelled,  };

  @BuiltValueField(wireName: r'driver_id')
  String? get driverId;

  @BuiltValueField(wireName: r'passenger_id')
  String? get passengerId;

  @BuiltValueField(wireName: r'updated_at')
  DateTime? get updatedAt;

  WsEventRideStateSync._();

  factory WsEventRideStateSync([void updates(WsEventRideStateSyncBuilder b)]) = _$WsEventRideStateSync;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WsEventRideStateSyncBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WsEventRideStateSync> get serializer => _$WsEventRideStateSyncSerializer();
}

class _$WsEventRideStateSyncSerializer implements PrimitiveSerializer<WsEventRideStateSync> {
  @override
  final Iterable<Type> types = const [WsEventRideStateSync, _$WsEventRideStateSync];

  @override
  final String wireName = r'WsEventRideStateSync';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    WsEventRideStateSync object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'has_active_ride';
    yield serializers.serialize(
      object.hasActiveRide,
      specifiedType: const FullType(bool),
    );
    if (object.rideId != null) {
      yield r'ride_id';
      yield serializers.serialize(
        object.rideId,
        specifiedType: const FullType.nullable(String),
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
    if (object.updatedAt != null) {
      yield r'updated_at';
      yield serializers.serialize(
        object.updatedAt,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    WsEventRideStateSync object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required WsEventRideStateSyncBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'has_active_ride':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.hasActiveRide = valueDes;
          break;
        case r'ride_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
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
        case r'updated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
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
  WsEventRideStateSync deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WsEventRideStateSyncBuilder();
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


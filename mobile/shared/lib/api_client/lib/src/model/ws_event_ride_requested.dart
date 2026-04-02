//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sakai_api_client/src/model/user_profile.dart';
import 'package:sakai_api_client/src/model/lat_lng.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ws_event_ride_requested.g.dart';

/// **Event:** `ride.requested` **Direction:** server → driver Sent when the matching engine assigns a ride offer to the driver. The driver must accept or decline before `expires_at`. If no response is received by `expires_at`, the offer is withdrawn and `ride.offer_expired` is sent to the driver, and re-matching begins. 
///
/// Properties:
/// * [rideId] 
/// * [passenger] 
/// * [origin] 
/// * [destination] 
/// * [originAddress] 
/// * [destinationAddress] 
/// * [notes] 
/// * [expiresAt] - Deadline to accept/decline. Driver UI should display a countdown.
@BuiltValue()
abstract class WsEventRideRequested implements Built<WsEventRideRequested, WsEventRideRequestedBuilder> {
  @BuiltValueField(wireName: r'ride_id')
  String get rideId;

  @BuiltValueField(wireName: r'passenger')
  UserProfile get passenger;

  @BuiltValueField(wireName: r'origin')
  LatLng get origin;

  @BuiltValueField(wireName: r'destination')
  LatLng get destination;

  @BuiltValueField(wireName: r'origin_address')
  String? get originAddress;

  @BuiltValueField(wireName: r'destination_address')
  String? get destinationAddress;

  @BuiltValueField(wireName: r'notes')
  String? get notes;

  /// Deadline to accept/decline. Driver UI should display a countdown.
  @BuiltValueField(wireName: r'expires_at')
  DateTime get expiresAt;

  WsEventRideRequested._();

  factory WsEventRideRequested([void updates(WsEventRideRequestedBuilder b)]) = _$WsEventRideRequested;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WsEventRideRequestedBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WsEventRideRequested> get serializer => _$WsEventRideRequestedSerializer();
}

class _$WsEventRideRequestedSerializer implements PrimitiveSerializer<WsEventRideRequested> {
  @override
  final Iterable<Type> types = const [WsEventRideRequested, _$WsEventRideRequested];

  @override
  final String wireName = r'WsEventRideRequested';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    WsEventRideRequested object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'ride_id';
    yield serializers.serialize(
      object.rideId,
      specifiedType: const FullType(String),
    );
    yield r'passenger';
    yield serializers.serialize(
      object.passenger,
      specifiedType: const FullType(UserProfile),
    );
    yield r'origin';
    yield serializers.serialize(
      object.origin,
      specifiedType: const FullType(LatLng),
    );
    yield r'destination';
    yield serializers.serialize(
      object.destination,
      specifiedType: const FullType(LatLng),
    );
    if (object.originAddress != null) {
      yield r'origin_address';
      yield serializers.serialize(
        object.originAddress,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.destinationAddress != null) {
      yield r'destination_address';
      yield serializers.serialize(
        object.destinationAddress,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.notes != null) {
      yield r'notes';
      yield serializers.serialize(
        object.notes,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'expires_at';
    yield serializers.serialize(
      object.expiresAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    WsEventRideRequested object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required WsEventRideRequestedBuilder result,
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
        case r'passenger':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(UserProfile),
          ) as UserProfile;
          result.passenger.replace(valueDes);
          break;
        case r'origin':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(LatLng),
          ) as LatLng;
          result.origin.replace(valueDes);
          break;
        case r'destination':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(LatLng),
          ) as LatLng;
          result.destination.replace(valueDes);
          break;
        case r'origin_address':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.originAddress = valueDes;
          break;
        case r'destination_address':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.destinationAddress = valueDes;
          break;
        case r'notes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.notes = valueDes;
          break;
        case r'expires_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.expiresAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  WsEventRideRequested deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WsEventRideRequestedBuilder();
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


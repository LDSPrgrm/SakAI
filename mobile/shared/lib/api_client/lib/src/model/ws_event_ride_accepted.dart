// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sakai_api_client/src/model/driver_summary.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ws_event_ride_accepted.g.dart';

/// **Event:** `ride.accepted` **Direction:** server â†’ passenger Sent when the matched driver accepts the ride. Passenger app should display driver details and begin showing live location. 
///
/// Properties:
/// * [rideId] 
/// * [driver] 
@BuiltValue()
abstract class WsEventRideAccepted implements Built<WsEventRideAccepted, WsEventRideAcceptedBuilder> {
  @BuiltValueField(wireName: r'ride_id')
  String get rideId;

  @BuiltValueField(wireName: r'driver')
  DriverSummary get driver;

  WsEventRideAccepted._();

  factory WsEventRideAccepted([void updates(WsEventRideAcceptedBuilder b)]) = _$WsEventRideAccepted;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WsEventRideAcceptedBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WsEventRideAccepted> get serializer => _$WsEventRideAcceptedSerializer();
}

class _$WsEventRideAcceptedSerializer implements PrimitiveSerializer<WsEventRideAccepted> {
  @override
  final Iterable<Type> types = const [WsEventRideAccepted, _$WsEventRideAccepted];

  @override
  final String wireName = r'WsEventRideAccepted';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    WsEventRideAccepted object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'ride_id';
    yield serializers.serialize(
      object.rideId,
      specifiedType: const FullType(String),
    );
    yield r'driver';
    yield serializers.serialize(
      object.driver,
      specifiedType: const FullType(DriverSummary),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    WsEventRideAccepted object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required WsEventRideAcceptedBuilder result,
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
        case r'driver':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DriverSummary),
          ) as DriverSummary;
          result.driver.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  WsEventRideAccepted deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WsEventRideAcceptedBuilder();
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


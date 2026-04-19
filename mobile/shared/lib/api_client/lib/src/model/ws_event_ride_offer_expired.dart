// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ws_event_ride_offer_expired.g.dart';

/// **Event:** `ride.offer_expired` **Direction:** server → driver Sent when the driver's acceptance window closes without a response. The driver UI should dismiss the incoming request card. Re-matching will begin automatically. 
///
/// Properties:
/// * [rideId] 
@BuiltValue()
abstract class WsEventRideOfferExpired implements Built<WsEventRideOfferExpired, WsEventRideOfferExpiredBuilder> {
  @BuiltValueField(wireName: r'ride_id')
  String get rideId;

  WsEventRideOfferExpired._();

  factory WsEventRideOfferExpired([void updates(WsEventRideOfferExpiredBuilder b)]) = _$WsEventRideOfferExpired;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WsEventRideOfferExpiredBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WsEventRideOfferExpired> get serializer => _$WsEventRideOfferExpiredSerializer();
}

class _$WsEventRideOfferExpiredSerializer implements PrimitiveSerializer<WsEventRideOfferExpired> {
  @override
  final Iterable<Type> types = const [WsEventRideOfferExpired, _$WsEventRideOfferExpired];

  @override
  final String wireName = r'WsEventRideOfferExpired';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    WsEventRideOfferExpired object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'ride_id';
    yield serializers.serialize(
      object.rideId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    WsEventRideOfferExpired object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required WsEventRideOfferExpiredBuilder result,
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  WsEventRideOfferExpired deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WsEventRideOfferExpiredBuilder();
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


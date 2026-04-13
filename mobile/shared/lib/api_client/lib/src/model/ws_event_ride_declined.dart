// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ws_event_ride_declined.g.dart';

/// **Event:** `ride.declined` **Direction:** server → passenger Sent when the assigned driver explicitly declines. Passenger app should show a \"finding another driver\" state. 
///
/// Properties:
/// * [rideId] 
/// * [message] 
@BuiltValue()
abstract class WsEventRideDeclined implements Built<WsEventRideDeclined, WsEventRideDeclinedBuilder> {
  @BuiltValueField(wireName: r'ride_id')
  String get rideId;

  @BuiltValueField(wireName: r'message')
  String? get message;

  WsEventRideDeclined._();

  factory WsEventRideDeclined([void updates(WsEventRideDeclinedBuilder b)]) = _$WsEventRideDeclined;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WsEventRideDeclinedBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WsEventRideDeclined> get serializer => _$WsEventRideDeclinedSerializer();
}

class _$WsEventRideDeclinedSerializer implements PrimitiveSerializer<WsEventRideDeclined> {
  @override
  final Iterable<Type> types = const [WsEventRideDeclined, _$WsEventRideDeclined];

  @override
  final String wireName = r'WsEventRideDeclined';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    WsEventRideDeclined object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'ride_id';
    yield serializers.serialize(
      object.rideId,
      specifiedType: const FullType(String),
    );
    if (object.message != null) {
      yield r'message';
      yield serializers.serialize(
        object.message,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    WsEventRideDeclined object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required WsEventRideDeclinedBuilder result,
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
        case r'message':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.message = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  WsEventRideDeclined deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WsEventRideDeclinedBuilder();
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


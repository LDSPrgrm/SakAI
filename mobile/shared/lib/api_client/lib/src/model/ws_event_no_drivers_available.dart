// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ws_event_no_drivers_available.g.dart';

/// **Event:** `ride.no_drivers` **Direction:** server → passenger Fired when the matching engine exhausts all available drivers. The ride is automatically set to `cancelled`. Passenger app should exit the ride flow and prompt the user to try again later. 
///
/// Properties:
/// * [rideId] 
/// * [message] 
@BuiltValue()
abstract class WsEventNoDriversAvailable implements Built<WsEventNoDriversAvailable, WsEventNoDriversAvailableBuilder> {
  @BuiltValueField(wireName: r'ride_id')
  String get rideId;

  @BuiltValueField(wireName: r'message')
  String? get message;

  WsEventNoDriversAvailable._();

  factory WsEventNoDriversAvailable([void updates(WsEventNoDriversAvailableBuilder b)]) = _$WsEventNoDriversAvailable;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WsEventNoDriversAvailableBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WsEventNoDriversAvailable> get serializer => _$WsEventNoDriversAvailableSerializer();
}

class _$WsEventNoDriversAvailableSerializer implements PrimitiveSerializer<WsEventNoDriversAvailable> {
  @override
  final Iterable<Type> types = const [WsEventNoDriversAvailable, _$WsEventNoDriversAvailable];

  @override
  final String wireName = r'WsEventNoDriversAvailable';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    WsEventNoDriversAvailable object, {
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
    WsEventNoDriversAvailable object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required WsEventNoDriversAvailableBuilder result,
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
  WsEventNoDriversAvailable deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WsEventNoDriversAvailableBuilder();
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


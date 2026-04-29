// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ws_event_ride_cancelled.g.dart';

/// **Event:** `ride.cancelled` **Direction:** server â†’ both passenger and driver Fired when either party cancels. Both apps should exit the ride flow and display an appropriate message based on `cancelled_by`. 
///
/// Properties:
/// * [rideId] 
/// * [cancelledBy] 
/// * [reason] 
@BuiltValue()
abstract class WsEventRideCancelled implements Built<WsEventRideCancelled, WsEventRideCancelledBuilder> {
  @BuiltValueField(wireName: r'ride_id')
  String get rideId;

  @BuiltValueField(wireName: r'cancelled_by')
  WsEventRideCancelledCancelledByEnum get cancelledBy;
  // enum cancelledByEnum {  passenger,  driver,  };

  @BuiltValueField(wireName: r'reason')
  String? get reason;

  WsEventRideCancelled._();

  factory WsEventRideCancelled([void updates(WsEventRideCancelledBuilder b)]) = _$WsEventRideCancelled;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WsEventRideCancelledBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WsEventRideCancelled> get serializer => _$WsEventRideCancelledSerializer();
}

class _$WsEventRideCancelledSerializer implements PrimitiveSerializer<WsEventRideCancelled> {
  @override
  final Iterable<Type> types = const [WsEventRideCancelled, _$WsEventRideCancelled];

  @override
  final String wireName = r'WsEventRideCancelled';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    WsEventRideCancelled object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'ride_id';
    yield serializers.serialize(
      object.rideId,
      specifiedType: const FullType(String),
    );
    yield r'cancelled_by';
    yield serializers.serialize(
      object.cancelledBy,
      specifiedType: const FullType(WsEventRideCancelledCancelledByEnum),
    );
    if (object.reason != null) {
      yield r'reason';
      yield serializers.serialize(
        object.reason,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    WsEventRideCancelled object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required WsEventRideCancelledBuilder result,
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
        case r'cancelled_by':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(WsEventRideCancelledCancelledByEnum),
          ) as WsEventRideCancelledCancelledByEnum;
          result.cancelledBy = valueDes;
          break;
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.reason = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  WsEventRideCancelled deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WsEventRideCancelledBuilder();
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

class WsEventRideCancelledCancelledByEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'passenger')
  static const WsEventRideCancelledCancelledByEnum passenger = _$wsEventRideCancelledCancelledByEnum_passenger;
  @BuiltValueEnumConst(wireName: r'driver')
  static const WsEventRideCancelledCancelledByEnum driver = _$wsEventRideCancelledCancelledByEnum_driver;

  static Serializer<WsEventRideCancelledCancelledByEnum> get serializer => _$wsEventRideCancelledCancelledByEnumSerializer;

  const WsEventRideCancelledCancelledByEnum._(String name): super(name);

  static BuiltSet<WsEventRideCancelledCancelledByEnum> get values => _$wsEventRideCancelledCancelledByEnumValues;
  static WsEventRideCancelledCancelledByEnum valueOf(String name) => _$wsEventRideCancelledCancelledByEnumValueOf(name);
}


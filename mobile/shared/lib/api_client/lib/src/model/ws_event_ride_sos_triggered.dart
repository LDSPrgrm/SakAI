// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ws_event_ride_sos_triggered.g.dart';

/// **Event:** `ride.sos_triggered` **Direction:** server → both passenger and driver on the active ride Fired when either party invokes `POST /rides/{rideId}/sos`. Clients should display an emergency banner and surface the safety contact action. 
///
/// Properties:
/// * [rideId] 
/// * [incidentId] - ID of the incident row created by the trigger.
/// * [triggeredBy] 
/// * [reason] - Free-text reason the trigger user supplied.
@BuiltValue()
abstract class WsEventRideSOSTriggered implements Built<WsEventRideSOSTriggered, WsEventRideSOSTriggeredBuilder> {
  @BuiltValueField(wireName: r'ride_id')
  String get rideId;

  /// ID of the incident row created by the trigger.
  @BuiltValueField(wireName: r'incident_id')
  String get incidentId;

  @BuiltValueField(wireName: r'triggered_by')
  WsEventRideSOSTriggeredTriggeredByEnum get triggeredBy;
  // enum triggeredByEnum {  rider,  driver,  };

  /// Free-text reason the trigger user supplied.
  @BuiltValueField(wireName: r'reason')
  String? get reason;

  WsEventRideSOSTriggered._();

  factory WsEventRideSOSTriggered([void updates(WsEventRideSOSTriggeredBuilder b)]) = _$WsEventRideSOSTriggered;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WsEventRideSOSTriggeredBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WsEventRideSOSTriggered> get serializer => _$WsEventRideSOSTriggeredSerializer();
}

class _$WsEventRideSOSTriggeredSerializer implements PrimitiveSerializer<WsEventRideSOSTriggered> {
  @override
  final Iterable<Type> types = const [WsEventRideSOSTriggered, _$WsEventRideSOSTriggered];

  @override
  final String wireName = r'WsEventRideSOSTriggered';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    WsEventRideSOSTriggered object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'ride_id';
    yield serializers.serialize(
      object.rideId,
      specifiedType: const FullType(String),
    );
    yield r'incident_id';
    yield serializers.serialize(
      object.incidentId,
      specifiedType: const FullType(String),
    );
    yield r'triggered_by';
    yield serializers.serialize(
      object.triggeredBy,
      specifiedType: const FullType(WsEventRideSOSTriggeredTriggeredByEnum),
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
    WsEventRideSOSTriggered object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required WsEventRideSOSTriggeredBuilder result,
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
        case r'incident_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.incidentId = valueDes;
          break;
        case r'triggered_by':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(WsEventRideSOSTriggeredTriggeredByEnum),
          ) as WsEventRideSOSTriggeredTriggeredByEnum;
          result.triggeredBy = valueDes;
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
  WsEventRideSOSTriggered deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WsEventRideSOSTriggeredBuilder();
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

class WsEventRideSOSTriggeredTriggeredByEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'rider')
  static const WsEventRideSOSTriggeredTriggeredByEnum rider = _$wsEventRideSOSTriggeredTriggeredByEnum_rider;
  @BuiltValueEnumConst(wireName: r'driver')
  static const WsEventRideSOSTriggeredTriggeredByEnum driver = _$wsEventRideSOSTriggeredTriggeredByEnum_driver;

  static Serializer<WsEventRideSOSTriggeredTriggeredByEnum> get serializer => _$wsEventRideSOSTriggeredTriggeredByEnumSerializer;

  const WsEventRideSOSTriggeredTriggeredByEnum._(String name): super(name);

  static BuiltSet<WsEventRideSOSTriggeredTriggeredByEnum> get values => _$wsEventRideSOSTriggeredTriggeredByEnumValues;
  static WsEventRideSOSTriggeredTriggeredByEnum valueOf(String name) => _$wsEventRideSOSTriggeredTriggeredByEnumValueOf(name);
}


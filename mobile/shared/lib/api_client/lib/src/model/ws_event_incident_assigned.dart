// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ws_event_incident_assigned.g.dart';

/// **Event:** `incident.assigned` **Direction:** server → both passenger and driver on the SOS ride Fired when an admin/operator assigns themselves (or another operator) to the SOS incident. Clients should update the emergency banner with the assignee's name when present.  `assignee_id` is null when an admin clears the assignment. 
///
/// Properties:
/// * [rideId] 
/// * [incidentId] 
/// * [assigneeId] 
/// * [assigneeName] - Display name of the assignee. Optional — publishers populate it only when the value can be resolved cheaply. 
/// * [assignedAt] 
@BuiltValue()
abstract class WsEventIncidentAssigned implements Built<WsEventIncidentAssigned, WsEventIncidentAssignedBuilder> {
  @BuiltValueField(wireName: r'ride_id')
  String get rideId;

  @BuiltValueField(wireName: r'incident_id')
  String get incidentId;

  @BuiltValueField(wireName: r'assignee_id')
  String? get assigneeId;

  /// Display name of the assignee. Optional — publishers populate it only when the value can be resolved cheaply. 
  @BuiltValueField(wireName: r'assignee_name')
  String? get assigneeName;

  @BuiltValueField(wireName: r'assigned_at')
  DateTime get assignedAt;

  WsEventIncidentAssigned._();

  factory WsEventIncidentAssigned([void updates(WsEventIncidentAssignedBuilder b)]) = _$WsEventIncidentAssigned;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WsEventIncidentAssignedBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WsEventIncidentAssigned> get serializer => _$WsEventIncidentAssignedSerializer();
}

class _$WsEventIncidentAssignedSerializer implements PrimitiveSerializer<WsEventIncidentAssigned> {
  @override
  final Iterable<Type> types = const [WsEventIncidentAssigned, _$WsEventIncidentAssigned];

  @override
  final String wireName = r'WsEventIncidentAssigned';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    WsEventIncidentAssigned object, {
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
    if (object.assigneeId != null) {
      yield r'assignee_id';
      yield serializers.serialize(
        object.assigneeId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.assigneeName != null) {
      yield r'assignee_name';
      yield serializers.serialize(
        object.assigneeName,
        specifiedType: const FullType(String),
      );
    }
    yield r'assigned_at';
    yield serializers.serialize(
      object.assignedAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    WsEventIncidentAssigned object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required WsEventIncidentAssignedBuilder result,
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
        case r'assignee_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.assigneeId = valueDes;
          break;
        case r'assignee_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.assigneeName = valueDes;
          break;
        case r'assigned_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.assignedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  WsEventIncidentAssigned deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WsEventIncidentAssignedBuilder();
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


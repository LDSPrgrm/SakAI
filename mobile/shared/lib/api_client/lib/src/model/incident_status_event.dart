// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'incident_status_event.g.dart';

/// IncidentStatusEvent
///
/// Properties:
/// * [id] 
/// * [fromStatus] 
/// * [toStatus] 
/// * [fromAssignee] 
/// * [toAssignee] 
/// * [actorId] 
/// * [actorName] 
/// * [note] 
/// * [occurredAt] 
@BuiltValue()
abstract class IncidentStatusEvent implements Built<IncidentStatusEvent, IncidentStatusEventBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'from_status')
  String? get fromStatus;

  @BuiltValueField(wireName: r'to_status')
  String get toStatus;

  @BuiltValueField(wireName: r'from_assignee')
  String? get fromAssignee;

  @BuiltValueField(wireName: r'to_assignee')
  String? get toAssignee;

  @BuiltValueField(wireName: r'actor_id')
  String? get actorId;

  @BuiltValueField(wireName: r'actor_name')
  String? get actorName;

  @BuiltValueField(wireName: r'note')
  String? get note;

  @BuiltValueField(wireName: r'occurred_at')
  DateTime get occurredAt;

  IncidentStatusEvent._();

  factory IncidentStatusEvent([void updates(IncidentStatusEventBuilder b)]) = _$IncidentStatusEvent;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(IncidentStatusEventBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<IncidentStatusEvent> get serializer => _$IncidentStatusEventSerializer();
}

class _$IncidentStatusEventSerializer implements PrimitiveSerializer<IncidentStatusEvent> {
  @override
  final Iterable<Type> types = const [IncidentStatusEvent, _$IncidentStatusEvent];

  @override
  final String wireName = r'IncidentStatusEvent';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    IncidentStatusEvent object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    if (object.fromStatus != null) {
      yield r'from_status';
      yield serializers.serialize(
        object.fromStatus,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'to_status';
    yield serializers.serialize(
      object.toStatus,
      specifiedType: const FullType(String),
    );
    if (object.fromAssignee != null) {
      yield r'from_assignee';
      yield serializers.serialize(
        object.fromAssignee,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.toAssignee != null) {
      yield r'to_assignee';
      yield serializers.serialize(
        object.toAssignee,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.actorId != null) {
      yield r'actor_id';
      yield serializers.serialize(
        object.actorId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.actorName != null) {
      yield r'actor_name';
      yield serializers.serialize(
        object.actorName,
        specifiedType: const FullType(String),
      );
    }
    if (object.note != null) {
      yield r'note';
      yield serializers.serialize(
        object.note,
        specifiedType: const FullType(String),
      );
    }
    yield r'occurred_at';
    yield serializers.serialize(
      object.occurredAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    IncidentStatusEvent object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required IncidentStatusEventBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'from_status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.fromStatus = valueDes;
          break;
        case r'to_status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.toStatus = valueDes;
          break;
        case r'from_assignee':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.fromAssignee = valueDes;
          break;
        case r'to_assignee':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.toAssignee = valueDes;
          break;
        case r'actor_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.actorId = valueDes;
          break;
        case r'actor_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.actorName = valueDes;
          break;
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.note = valueDes;
          break;
        case r'occurred_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.occurredAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  IncidentStatusEvent deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = IncidentStatusEventBuilder();
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


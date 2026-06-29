// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'alert_event.g.dart';

/// AlertEvent
///
/// Properties:
/// * [id] 
/// * [ruleId] 
/// * [firedAt] 
/// * [subjectType] 
/// * [subjectId] 
/// * [payload] 
@BuiltValue()
abstract class AlertEvent implements Built<AlertEvent, AlertEventBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'rule_id')
  String? get ruleId;

  @BuiltValueField(wireName: r'fired_at')
  DateTime get firedAt;

  @BuiltValueField(wireName: r'subject_type')
  String? get subjectType;

  @BuiltValueField(wireName: r'subject_id')
  String? get subjectId;

  @BuiltValueField(wireName: r'payload')
  BuiltMap<String, JsonObject?> get payload;

  AlertEvent._();

  factory AlertEvent([void updates(AlertEventBuilder b)]) = _$AlertEvent;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AlertEventBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AlertEvent> get serializer => _$AlertEventSerializer();
}

class _$AlertEventSerializer implements PrimitiveSerializer<AlertEvent> {
  @override
  final Iterable<Type> types = const [AlertEvent, _$AlertEvent];

  @override
  final String wireName = r'AlertEvent';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AlertEvent object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    if (object.ruleId != null) {
      yield r'rule_id';
      yield serializers.serialize(
        object.ruleId,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'fired_at';
    yield serializers.serialize(
      object.firedAt,
      specifiedType: const FullType(DateTime),
    );
    if (object.subjectType != null) {
      yield r'subject_type';
      yield serializers.serialize(
        object.subjectType,
        specifiedType: const FullType(String),
      );
    }
    if (object.subjectId != null) {
      yield r'subject_id';
      yield serializers.serialize(
        object.subjectId,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'payload';
    yield serializers.serialize(
      object.payload,
      specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AlertEvent object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AlertEventBuilder result,
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
        case r'rule_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.ruleId = valueDes;
          break;
        case r'fired_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.firedAt = valueDes;
          break;
        case r'subject_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.subjectType = valueDes;
          break;
        case r'subject_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.subjectId = valueDes;
          break;
        case r'payload':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>;
          result.payload.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AlertEvent deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AlertEventBuilder();
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


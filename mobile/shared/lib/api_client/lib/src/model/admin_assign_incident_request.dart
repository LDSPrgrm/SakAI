// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_assign_incident_request.g.dart';

/// AdminAssignIncidentRequest
///
/// Properties:
/// * [assigneeId] 
@BuiltValue()
abstract class AdminAssignIncidentRequest implements Built<AdminAssignIncidentRequest, AdminAssignIncidentRequestBuilder> {
  @BuiltValueField(wireName: r'assignee_id')
  String? get assigneeId;

  AdminAssignIncidentRequest._();

  factory AdminAssignIncidentRequest([void updates(AdminAssignIncidentRequestBuilder b)]) = _$AdminAssignIncidentRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminAssignIncidentRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminAssignIncidentRequest> get serializer => _$AdminAssignIncidentRequestSerializer();
}

class _$AdminAssignIncidentRequestSerializer implements PrimitiveSerializer<AdminAssignIncidentRequest> {
  @override
  final Iterable<Type> types = const [AdminAssignIncidentRequest, _$AdminAssignIncidentRequest];

  @override
  final String wireName = r'AdminAssignIncidentRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminAssignIncidentRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.assigneeId != null) {
      yield r'assignee_id';
      yield serializers.serialize(
        object.assigneeId,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminAssignIncidentRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminAssignIncidentRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'assignee_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.assigneeId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminAssignIncidentRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminAssignIncidentRequestBuilder();
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


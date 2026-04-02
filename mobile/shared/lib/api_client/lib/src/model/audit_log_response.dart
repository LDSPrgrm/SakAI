//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sakai_api_client/src/model/audit_log.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'audit_log_response.g.dart';

/// AuditLogResponse
///
/// Properties:
/// * [logs] 
/// * [total] 
@BuiltValue()
abstract class AuditLogResponse implements Built<AuditLogResponse, AuditLogResponseBuilder> {
  @BuiltValueField(wireName: r'logs')
  BuiltList<AuditLog>? get logs;

  @BuiltValueField(wireName: r'total')
  int? get total;

  AuditLogResponse._();

  factory AuditLogResponse([void updates(AuditLogResponseBuilder b)]) = _$AuditLogResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuditLogResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuditLogResponse> get serializer => _$AuditLogResponseSerializer();
}

class _$AuditLogResponseSerializer implements PrimitiveSerializer<AuditLogResponse> {
  @override
  final Iterable<Type> types = const [AuditLogResponse, _$AuditLogResponse];

  @override
  final String wireName = r'AuditLogResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuditLogResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.logs != null) {
      yield r'logs';
      yield serializers.serialize(
        object.logs,
        specifiedType: const FullType(BuiltList, [FullType(AuditLog)]),
      );
    }
    if (object.total != null) {
      yield r'total';
      yield serializers.serialize(
        object.total,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AuditLogResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AuditLogResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'logs':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(AuditLog)]),
          ) as BuiltList<AuditLog>;
          result.logs.replace(valueDes);
          break;
        case r'total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.total = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AuditLogResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuditLogResponseBuilder();
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


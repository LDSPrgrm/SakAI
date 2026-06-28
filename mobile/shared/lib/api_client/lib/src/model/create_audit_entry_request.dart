// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_audit_entry_request.g.dart';

/// CreateAuditEntryRequest
///
/// Properties:
/// * [resourceType] 
/// * [resourceId] 
/// * [action] 
/// * [beforeState] 
/// * [afterState] 
/// * [reason] 
@BuiltValue()
abstract class CreateAuditEntryRequest implements Built<CreateAuditEntryRequest, CreateAuditEntryRequestBuilder> {
  @BuiltValueField(wireName: r'resource_type')
  String get resourceType;

  @BuiltValueField(wireName: r'resource_id')
  String get resourceId;

  @BuiltValueField(wireName: r'action')
  CreateAuditEntryRequestActionEnum get action;
  // enum actionEnum {  create,  update,  delete,  approve,  reject,  login,  logout,  };

  @BuiltValueField(wireName: r'before_state')
  BuiltMap<String, JsonObject?>? get beforeState;

  @BuiltValueField(wireName: r'after_state')
  BuiltMap<String, JsonObject?>? get afterState;

  @BuiltValueField(wireName: r'reason')
  String? get reason;

  CreateAuditEntryRequest._();

  factory CreateAuditEntryRequest([void updates(CreateAuditEntryRequestBuilder b)]) = _$CreateAuditEntryRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateAuditEntryRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreateAuditEntryRequest> get serializer => _$CreateAuditEntryRequestSerializer();
}

class _$CreateAuditEntryRequestSerializer implements PrimitiveSerializer<CreateAuditEntryRequest> {
  @override
  final Iterable<Type> types = const [CreateAuditEntryRequest, _$CreateAuditEntryRequest];

  @override
  final String wireName = r'CreateAuditEntryRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreateAuditEntryRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'resource_type';
    yield serializers.serialize(
      object.resourceType,
      specifiedType: const FullType(String),
    );
    yield r'resource_id';
    yield serializers.serialize(
      object.resourceId,
      specifiedType: const FullType(String),
    );
    yield r'action';
    yield serializers.serialize(
      object.action,
      specifiedType: const FullType(CreateAuditEntryRequestActionEnum),
    );
    if (object.beforeState != null) {
      yield r'before_state';
      yield serializers.serialize(
        object.beforeState,
        specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
      );
    }
    if (object.afterState != null) {
      yield r'after_state';
      yield serializers.serialize(
        object.afterState,
        specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
      );
    }
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
    CreateAuditEntryRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CreateAuditEntryRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'resource_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.resourceType = valueDes;
          break;
        case r'resource_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.resourceId = valueDes;
          break;
        case r'action':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CreateAuditEntryRequestActionEnum),
          ) as CreateAuditEntryRequestActionEnum;
          result.action = valueDes;
          break;
        case r'before_state':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>?;
          if (valueDes == null) continue;
          result.beforeState.replace(valueDes);
          break;
        case r'after_state':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>?;
          if (valueDes == null) continue;
          result.afterState.replace(valueDes);
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
  CreateAuditEntryRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreateAuditEntryRequestBuilder();
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

class CreateAuditEntryRequestActionEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'create')
  static const CreateAuditEntryRequestActionEnum create = _$createAuditEntryRequestActionEnum_create;
  @BuiltValueEnumConst(wireName: r'update')
  static const CreateAuditEntryRequestActionEnum update = _$createAuditEntryRequestActionEnum_update;
  @BuiltValueEnumConst(wireName: r'delete')
  static const CreateAuditEntryRequestActionEnum delete = _$createAuditEntryRequestActionEnum_delete;
  @BuiltValueEnumConst(wireName: r'approve')
  static const CreateAuditEntryRequestActionEnum approve = _$createAuditEntryRequestActionEnum_approve;
  @BuiltValueEnumConst(wireName: r'reject')
  static const CreateAuditEntryRequestActionEnum reject = _$createAuditEntryRequestActionEnum_reject;
  @BuiltValueEnumConst(wireName: r'login')
  static const CreateAuditEntryRequestActionEnum login = _$createAuditEntryRequestActionEnum_login;
  @BuiltValueEnumConst(wireName: r'logout')
  static const CreateAuditEntryRequestActionEnum logout = _$createAuditEntryRequestActionEnum_logout;

  static Serializer<CreateAuditEntryRequestActionEnum> get serializer => _$createAuditEntryRequestActionEnumSerializer;

  const CreateAuditEntryRequestActionEnum._(String name): super(name);

  static BuiltSet<CreateAuditEntryRequestActionEnum> get values => _$createAuditEntryRequestActionEnumValues;
  static CreateAuditEntryRequestActionEnum valueOf(String name) => _$createAuditEntryRequestActionEnumValueOf(name);
}


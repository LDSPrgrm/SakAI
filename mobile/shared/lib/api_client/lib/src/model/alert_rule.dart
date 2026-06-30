// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'alert_rule.g.dart';

/// AlertRule
///
/// Properties:
/// * [id] 
/// * [name] 
/// * [type] 
/// * [enabled] 
/// * [config] 
/// * [createdBy] 
/// * [createdAt] 
/// * [updatedAt] 
@BuiltValue()
abstract class AlertRule implements Built<AlertRule, AlertRuleBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'type')
  AlertRuleTypeEnum get type;
  // enum typeEnum {  low_rating,  high_cancellation,  fraud_velocity,  kyc_expiry,  };

  @BuiltValueField(wireName: r'enabled')
  bool get enabled;

  @BuiltValueField(wireName: r'config')
  BuiltMap<String, JsonObject?> get config;

  @BuiltValueField(wireName: r'created_by')
  String? get createdBy;

  @BuiltValueField(wireName: r'created_at')
  DateTime? get createdAt;

  @BuiltValueField(wireName: r'updated_at')
  DateTime? get updatedAt;

  AlertRule._();

  factory AlertRule([void updates(AlertRuleBuilder b)]) = _$AlertRule;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AlertRuleBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AlertRule> get serializer => _$AlertRuleSerializer();
}

class _$AlertRuleSerializer implements PrimitiveSerializer<AlertRule> {
  @override
  final Iterable<Type> types = const [AlertRule, _$AlertRule];

  @override
  final String wireName = r'AlertRule';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AlertRule object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(AlertRuleTypeEnum),
    );
    yield r'enabled';
    yield serializers.serialize(
      object.enabled,
      specifiedType: const FullType(bool),
    );
    yield r'config';
    yield serializers.serialize(
      object.config,
      specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
    );
    if (object.createdBy != null) {
      yield r'created_by';
      yield serializers.serialize(
        object.createdBy,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.createdAt != null) {
      yield r'created_at';
      yield serializers.serialize(
        object.createdAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.updatedAt != null) {
      yield r'updated_at';
      yield serializers.serialize(
        object.updatedAt,
        specifiedType: const FullType(DateTime),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AlertRule object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AlertRuleBuilder result,
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
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AlertRuleTypeEnum),
          ) as AlertRuleTypeEnum;
          result.type = valueDes;
          break;
        case r'enabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.enabled = valueDes;
          break;
        case r'config':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>;
          result.config.replace(valueDes);
          break;
        case r'created_by':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.createdBy = valueDes;
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'updated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.updatedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AlertRule deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AlertRuleBuilder();
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

class AlertRuleTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'low_rating')
  static const AlertRuleTypeEnum lowRating = _$alertRuleTypeEnum_lowRating;
  @BuiltValueEnumConst(wireName: r'high_cancellation')
  static const AlertRuleTypeEnum highCancellation = _$alertRuleTypeEnum_highCancellation;
  @BuiltValueEnumConst(wireName: r'fraud_velocity')
  static const AlertRuleTypeEnum fraudVelocity = _$alertRuleTypeEnum_fraudVelocity;
  @BuiltValueEnumConst(wireName: r'kyc_expiry')
  static const AlertRuleTypeEnum kycExpiry = _$alertRuleTypeEnum_kycExpiry;

  static Serializer<AlertRuleTypeEnum> get serializer => _$alertRuleTypeEnumSerializer;

  const AlertRuleTypeEnum._(String name): super(name);

  static BuiltSet<AlertRuleTypeEnum> get values => _$alertRuleTypeEnumValues;
  static AlertRuleTypeEnum valueOf(String name) => _$alertRuleTypeEnumValueOf(name);
}


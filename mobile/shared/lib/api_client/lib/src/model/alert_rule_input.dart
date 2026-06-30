// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'alert_rule_input.g.dart';

/// AlertRuleInput
///
/// Properties:
/// * [name] 
/// * [type] 
/// * [enabled] 
/// * [config] 
@BuiltValue()
abstract class AlertRuleInput implements Built<AlertRuleInput, AlertRuleInputBuilder> {
  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'type')
  AlertRuleInputTypeEnum get type;
  // enum typeEnum {  low_rating,  high_cancellation,  fraud_velocity,  kyc_expiry,  };

  @BuiltValueField(wireName: r'enabled')
  bool? get enabled;

  @BuiltValueField(wireName: r'config')
  BuiltMap<String, JsonObject?> get config;

  AlertRuleInput._();

  factory AlertRuleInput([void updates(AlertRuleInputBuilder b)]) = _$AlertRuleInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AlertRuleInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AlertRuleInput> get serializer => _$AlertRuleInputSerializer();
}

class _$AlertRuleInputSerializer implements PrimitiveSerializer<AlertRuleInput> {
  @override
  final Iterable<Type> types = const [AlertRuleInput, _$AlertRuleInput];

  @override
  final String wireName = r'AlertRuleInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AlertRuleInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(AlertRuleInputTypeEnum),
    );
    if (object.enabled != null) {
      yield r'enabled';
      yield serializers.serialize(
        object.enabled,
        specifiedType: const FullType(bool),
      );
    }
    yield r'config';
    yield serializers.serialize(
      object.config,
      specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AlertRuleInput object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AlertRuleInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
            specifiedType: const FullType(AlertRuleInputTypeEnum),
          ) as AlertRuleInputTypeEnum;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AlertRuleInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AlertRuleInputBuilder();
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

class AlertRuleInputTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'low_rating')
  static const AlertRuleInputTypeEnum lowRating = _$alertRuleInputTypeEnum_lowRating;
  @BuiltValueEnumConst(wireName: r'high_cancellation')
  static const AlertRuleInputTypeEnum highCancellation = _$alertRuleInputTypeEnum_highCancellation;
  @BuiltValueEnumConst(wireName: r'fraud_velocity')
  static const AlertRuleInputTypeEnum fraudVelocity = _$alertRuleInputTypeEnum_fraudVelocity;
  @BuiltValueEnumConst(wireName: r'kyc_expiry')
  static const AlertRuleInputTypeEnum kycExpiry = _$alertRuleInputTypeEnum_kycExpiry;

  static Serializer<AlertRuleInputTypeEnum> get serializer => _$alertRuleInputTypeEnumSerializer;

  const AlertRuleInputTypeEnum._(String name): super(name);

  static BuiltSet<AlertRuleInputTypeEnum> get values => _$alertRuleInputTypeEnumValues;
  static AlertRuleInputTypeEnum valueOf(String name) => _$alertRuleInputTypeEnumValueOf(name);
}


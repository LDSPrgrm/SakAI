// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'payment_gateway_config.g.dart';

/// Persisted credentials and toggle state for one payment gateway provider (gcash, paymaya, card, cash). config_fields is a string-keyed map; secret values are masked to \"****\" + last4 on read responses, so the UI must treat fields starting with \"****\" as unchanged when re-saving. 
///
/// Properties:
/// * [id] 
/// * [provider] 
/// * [configFields] 
/// * [isActive] 
/// * [updatedAt] 
/// * [updatedBy] 
@BuiltValue()
abstract class PaymentGatewayConfig implements Built<PaymentGatewayConfig, PaymentGatewayConfigBuilder> {
  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'provider')
  PaymentGatewayConfigProviderEnum? get provider;
  // enum providerEnum {  gcash,  paymaya,  card,  cash,  };

  @BuiltValueField(wireName: r'config_fields')
  BuiltMap<String, String>? get configFields;

  @BuiltValueField(wireName: r'is_active')
  bool? get isActive;

  @BuiltValueField(wireName: r'updated_at')
  DateTime? get updatedAt;

  @BuiltValueField(wireName: r'updated_by')
  String? get updatedBy;

  PaymentGatewayConfig._();

  factory PaymentGatewayConfig([void updates(PaymentGatewayConfigBuilder b)]) = _$PaymentGatewayConfig;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PaymentGatewayConfigBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PaymentGatewayConfig> get serializer => _$PaymentGatewayConfigSerializer();
}

class _$PaymentGatewayConfigSerializer implements PrimitiveSerializer<PaymentGatewayConfig> {
  @override
  final Iterable<Type> types = const [PaymentGatewayConfig, _$PaymentGatewayConfig];

  @override
  final String wireName = r'PaymentGatewayConfig';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PaymentGatewayConfig object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
    if (object.provider != null) {
      yield r'provider';
      yield serializers.serialize(
        object.provider,
        specifiedType: const FullType(PaymentGatewayConfigProviderEnum),
      );
    }
    if (object.configFields != null) {
      yield r'config_fields';
      yield serializers.serialize(
        object.configFields,
        specifiedType: const FullType(BuiltMap, [FullType(String), FullType(String)]),
      );
    }
    if (object.isActive != null) {
      yield r'is_active';
      yield serializers.serialize(
        object.isActive,
        specifiedType: const FullType(bool),
      );
    }
    if (object.updatedAt != null) {
      yield r'updated_at';
      yield serializers.serialize(
        object.updatedAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.updatedBy != null) {
      yield r'updated_by';
      yield serializers.serialize(
        object.updatedBy,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PaymentGatewayConfig object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PaymentGatewayConfigBuilder result,
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
        case r'provider':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PaymentGatewayConfigProviderEnum),
          ) as PaymentGatewayConfigProviderEnum;
          result.provider = valueDes;
          break;
        case r'config_fields':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType(String)]),
          ) as BuiltMap<String, String>;
          result.configFields.replace(valueDes);
          break;
        case r'is_active':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isActive = valueDes;
          break;
        case r'updated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.updatedAt = valueDes;
          break;
        case r'updated_by':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.updatedBy = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PaymentGatewayConfig deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PaymentGatewayConfigBuilder();
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

class PaymentGatewayConfigProviderEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'gcash')
  static const PaymentGatewayConfigProviderEnum gcash = _$paymentGatewayConfigProviderEnum_gcash;
  @BuiltValueEnumConst(wireName: r'paymaya')
  static const PaymentGatewayConfigProviderEnum paymaya = _$paymentGatewayConfigProviderEnum_paymaya;
  @BuiltValueEnumConst(wireName: r'card')
  static const PaymentGatewayConfigProviderEnum card = _$paymentGatewayConfigProviderEnum_card;
  @BuiltValueEnumConst(wireName: r'cash')
  static const PaymentGatewayConfigProviderEnum cash = _$paymentGatewayConfigProviderEnum_cash;

  static Serializer<PaymentGatewayConfigProviderEnum> get serializer => _$paymentGatewayConfigProviderEnumSerializer;

  const PaymentGatewayConfigProviderEnum._(String name): super(name);

  static BuiltSet<PaymentGatewayConfigProviderEnum> get values => _$paymentGatewayConfigProviderEnumValues;
  static PaymentGatewayConfigProviderEnum valueOf(String name) => _$paymentGatewayConfigProviderEnumValueOf(name);
}


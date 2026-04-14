// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sakai_api_client/src/model/payment_method_type.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'add_payment_method_request.g.dart';

/// AddPaymentMethodRequest
///
/// Properties:
/// * [type] 
/// * [cardToken] - Payment gateway token for card (required if type == \"card\")
/// * [provider] - E-wallet provider name (required if type == \"e_wallet\")
/// * [accountId] - E-wallet account ID (required if type == \"e_wallet\")
/// * [setAsDefault] - Set as default payment method
@BuiltValue()
abstract class AddPaymentMethodRequest implements Built<AddPaymentMethodRequest, AddPaymentMethodRequestBuilder> {
  @BuiltValueField(wireName: r'type')
  PaymentMethodType get type;
  // enum typeEnum {  card,  e_wallet,  cash,  };

  /// Payment gateway token for card (required if type == \"card\")
  @BuiltValueField(wireName: r'card_token')
  String? get cardToken;

  /// E-wallet provider name (required if type == \"e_wallet\")
  @BuiltValueField(wireName: r'provider')
  String? get provider;

  /// E-wallet account ID (required if type == \"e_wallet\")
  @BuiltValueField(wireName: r'account_id')
  String? get accountId;

  /// Set as default payment method
  @BuiltValueField(wireName: r'set_as_default')
  bool? get setAsDefault;

  AddPaymentMethodRequest._();

  factory AddPaymentMethodRequest([void updates(AddPaymentMethodRequestBuilder b)]) = _$AddPaymentMethodRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AddPaymentMethodRequestBuilder b) => b
      ..setAsDefault = false;

  @BuiltValueSerializer(custom: true)
  static Serializer<AddPaymentMethodRequest> get serializer => _$AddPaymentMethodRequestSerializer();
}

class _$AddPaymentMethodRequestSerializer implements PrimitiveSerializer<AddPaymentMethodRequest> {
  @override
  final Iterable<Type> types = const [AddPaymentMethodRequest, _$AddPaymentMethodRequest];

  @override
  final String wireName = r'AddPaymentMethodRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AddPaymentMethodRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(PaymentMethodType),
    );
    if (object.cardToken != null) {
      yield r'card_token';
      yield serializers.serialize(
        object.cardToken,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.provider != null) {
      yield r'provider';
      yield serializers.serialize(
        object.provider,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.accountId != null) {
      yield r'account_id';
      yield serializers.serialize(
        object.accountId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.setAsDefault != null) {
      yield r'set_as_default';
      yield serializers.serialize(
        object.setAsDefault,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AddPaymentMethodRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AddPaymentMethodRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PaymentMethodType),
          ) as PaymentMethodType;
          result.type = valueDes;
          break;
        case r'card_token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.cardToken = valueDes;
          break;
        case r'provider':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.provider = valueDes;
          break;
        case r'account_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.accountId = valueDes;
          break;
        case r'set_as_default':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.setAsDefault = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AddPaymentMethodRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AddPaymentMethodRequestBuilder();
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


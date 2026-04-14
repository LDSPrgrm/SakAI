// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sakai_api_client/src/model/card_details.dart';
import 'package:sakai_api_client/src/model/payment_method_type.dart';
import 'package:sakai_api_client/src/model/e_wallet_details.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'payment_method_details.g.dart';

/// PaymentMethodDetails
///
/// Properties:
/// * [id] 
/// * [type] 
/// * [isDefault] - Whether this is the default payment method
/// * [createdAt] 
/// * [card] - Present only if type == \"card\"
/// * [eWallet] - Present only if type == \"e_wallet\"
@BuiltValue()
abstract class PaymentMethodDetails implements Built<PaymentMethodDetails, PaymentMethodDetailsBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'type')
  PaymentMethodType get type;
  // enum typeEnum {  card,  e_wallet,  cash,  };

  /// Whether this is the default payment method
  @BuiltValueField(wireName: r'is_default')
  bool get isDefault;

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  /// Present only if type == \"card\"
  @BuiltValueField(wireName: r'card')
  CardDetails? get card;

  /// Present only if type == \"e_wallet\"
  @BuiltValueField(wireName: r'e_wallet')
  EWalletDetails? get eWallet;

  PaymentMethodDetails._();

  factory PaymentMethodDetails([void updates(PaymentMethodDetailsBuilder b)]) = _$PaymentMethodDetails;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PaymentMethodDetailsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PaymentMethodDetails> get serializer => _$PaymentMethodDetailsSerializer();
}

class _$PaymentMethodDetailsSerializer implements PrimitiveSerializer<PaymentMethodDetails> {
  @override
  final Iterable<Type> types = const [PaymentMethodDetails, _$PaymentMethodDetails];

  @override
  final String wireName = r'PaymentMethodDetails';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PaymentMethodDetails object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(PaymentMethodType),
    );
    yield r'is_default';
    yield serializers.serialize(
      object.isDefault,
      specifiedType: const FullType(bool),
    );
    yield r'created_at';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    if (object.card != null) {
      yield r'card';
      yield serializers.serialize(
        object.card,
        specifiedType: const FullType.nullable(CardDetails),
      );
    }
    if (object.eWallet != null) {
      yield r'e_wallet';
      yield serializers.serialize(
        object.eWallet,
        specifiedType: const FullType.nullable(EWalletDetails),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PaymentMethodDetails object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PaymentMethodDetailsBuilder result,
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
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PaymentMethodType),
          ) as PaymentMethodType;
          result.type = valueDes;
          break;
        case r'is_default':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isDefault = valueDes;
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'card':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(CardDetails),
          ) as CardDetails?;
          if (valueDes == null) continue;
          result.card.replace(valueDes);
          break;
        case r'e_wallet':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(EWalletDetails),
          ) as EWalletDetails?;
          if (valueDes == null) continue;
          result.eWallet.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PaymentMethodDetails deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PaymentMethodDetailsBuilder();
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


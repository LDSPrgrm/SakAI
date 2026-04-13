//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'e_wallet_details.g.dart';

/// EWalletDetails
///
/// Properties:
/// * [provider] - E-wallet provider name
/// * [accountId] - Account identifier (phone or account ID)
@BuiltValue()
abstract class EWalletDetails implements Built<EWalletDetails, EWalletDetailsBuilder> {
  /// E-wallet provider name
  @BuiltValueField(wireName: r'provider')
  String get provider;

  /// Account identifier (phone or account ID)
  @BuiltValueField(wireName: r'account_id')
  String get accountId;

  EWalletDetails._();

  factory EWalletDetails([void updates(EWalletDetailsBuilder b)]) = _$EWalletDetails;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(EWalletDetailsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<EWalletDetails> get serializer => _$EWalletDetailsSerializer();
}

class _$EWalletDetailsSerializer implements PrimitiveSerializer<EWalletDetails> {
  @override
  final Iterable<Type> types = const [EWalletDetails, _$EWalletDetails];

  @override
  final String wireName = r'EWalletDetails';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    EWalletDetails object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'provider';
    yield serializers.serialize(
      object.provider,
      specifiedType: const FullType(String),
    );
    yield r'account_id';
    yield serializers.serialize(
      object.accountId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    EWalletDetails object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required EWalletDetailsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'provider':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.provider = valueDes;
          break;
        case r'account_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.accountId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  EWalletDetails deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = EWalletDetailsBuilder();
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


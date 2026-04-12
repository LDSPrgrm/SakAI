//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'card_details.g.dart';

/// CardDetails
///
/// Properties:
/// * [last4] - Last 4 digits of card
/// * [expiryMonth] 
/// * [expiryYear] 
/// * [brand] - Card brand name
@BuiltValue()
abstract class CardDetails implements Built<CardDetails, CardDetailsBuilder> {
  /// Last 4 digits of card
  @BuiltValueField(wireName: r'last4')
  String get last4;

  @BuiltValueField(wireName: r'expiry_month')
  int get expiryMonth;

  @BuiltValueField(wireName: r'expiry_year')
  int get expiryYear;

  /// Card brand name
  @BuiltValueField(wireName: r'brand')
  String get brand;

  CardDetails._();

  factory CardDetails([void updates(CardDetailsBuilder b)]) = _$CardDetails;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CardDetailsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CardDetails> get serializer => _$CardDetailsSerializer();
}

class _$CardDetailsSerializer implements PrimitiveSerializer<CardDetails> {
  @override
  final Iterable<Type> types = const [CardDetails, _$CardDetails];

  @override
  final String wireName = r'CardDetails';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CardDetails object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'last4';
    yield serializers.serialize(
      object.last4,
      specifiedType: const FullType(String),
    );
    yield r'expiry_month';
    yield serializers.serialize(
      object.expiryMonth,
      specifiedType: const FullType(int),
    );
    yield r'expiry_year';
    yield serializers.serialize(
      object.expiryYear,
      specifiedType: const FullType(int),
    );
    yield r'brand';
    yield serializers.serialize(
      object.brand,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CardDetails object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CardDetailsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'last4':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.last4 = valueDes;
          break;
        case r'expiry_month':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.expiryMonth = valueDes;
          break;
        case r'expiry_year':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.expiryYear = valueDes;
          break;
        case r'brand':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.brand = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CardDetails deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CardDetailsBuilder();
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


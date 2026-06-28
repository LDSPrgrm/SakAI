// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'promotion.g.dart';

/// Promotion
///
/// Properties:
/// * [id] 
/// * [code] 
/// * [title] 
/// * [description] 
/// * [discountValue] 
/// * [discountType] 
/// * [maxDiscount] - Maximum discount amount for percentage types
/// * [minRideAmount] - Minimum ride fare required to apply this promo
/// * [expiresAt] 
/// * [terms] 
@BuiltValue()
abstract class Promotion implements Built<Promotion, PromotionBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'code')
  String get code;

  @BuiltValueField(wireName: r'title')
  String? get title;

  @BuiltValueField(wireName: r'description')
  String get description;

  @BuiltValueField(wireName: r'discountValue')
  double get discountValue;

  @BuiltValueField(wireName: r'discountType')
  PromotionDiscountTypeEnum get discountType;
  // enum discountTypeEnum {  percentage,  fixed,  };

  /// Maximum discount amount for percentage types
  @BuiltValueField(wireName: r'maxDiscount')
  double? get maxDiscount;

  /// Minimum ride fare required to apply this promo
  @BuiltValueField(wireName: r'minRideAmount')
  double? get minRideAmount;

  @BuiltValueField(wireName: r'expiresAt')
  DateTime get expiresAt;

  @BuiltValueField(wireName: r'terms')
  String? get terms;

  Promotion._();

  factory Promotion([void updates(PromotionBuilder b)]) = _$Promotion;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PromotionBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Promotion> get serializer => _$PromotionSerializer();
}

class _$PromotionSerializer implements PrimitiveSerializer<Promotion> {
  @override
  final Iterable<Type> types = const [Promotion, _$Promotion];

  @override
  final String wireName = r'Promotion';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Promotion object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(String),
    );
    if (object.title != null) {
      yield r'title';
      yield serializers.serialize(
        object.title,
        specifiedType: const FullType(String),
      );
    }
    yield r'description';
    yield serializers.serialize(
      object.description,
      specifiedType: const FullType(String),
    );
    yield r'discountValue';
    yield serializers.serialize(
      object.discountValue,
      specifiedType: const FullType(double),
    );
    yield r'discountType';
    yield serializers.serialize(
      object.discountType,
      specifiedType: const FullType(PromotionDiscountTypeEnum),
    );
    if (object.maxDiscount != null) {
      yield r'maxDiscount';
      yield serializers.serialize(
        object.maxDiscount,
        specifiedType: const FullType.nullable(double),
      );
    }
    if (object.minRideAmount != null) {
      yield r'minRideAmount';
      yield serializers.serialize(
        object.minRideAmount,
        specifiedType: const FullType.nullable(double),
      );
    }
    yield r'expiresAt';
    yield serializers.serialize(
      object.expiresAt,
      specifiedType: const FullType(DateTime),
    );
    if (object.terms != null) {
      yield r'terms';
      yield serializers.serialize(
        object.terms,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    Promotion object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PromotionBuilder result,
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
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.code = valueDes;
          break;
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.title = valueDes;
          break;
        case r'description':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.description = valueDes;
          break;
        case r'discountValue':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(double),
          ) as double;
          result.discountValue = valueDes;
          break;
        case r'discountType':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PromotionDiscountTypeEnum),
          ) as PromotionDiscountTypeEnum;
          result.discountType = valueDes;
          break;
        case r'maxDiscount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(double),
          ) as double?;
          if (valueDes == null) continue;
          result.maxDiscount = valueDes;
          break;
        case r'minRideAmount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(double),
          ) as double?;
          if (valueDes == null) continue;
          result.minRideAmount = valueDes;
          break;
        case r'expiresAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.expiresAt = valueDes;
          break;
        case r'terms':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.terms = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Promotion deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PromotionBuilder();
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

class PromotionDiscountTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'percentage')
  static const PromotionDiscountTypeEnum percentage = _$promotionDiscountTypeEnum_percentage;
  @BuiltValueEnumConst(wireName: r'fixed')
  static const PromotionDiscountTypeEnum fixed = _$promotionDiscountTypeEnum_fixed;

  static Serializer<PromotionDiscountTypeEnum> get serializer => _$promotionDiscountTypeEnumSerializer;

  const PromotionDiscountTypeEnum._(String name): super(name);

  static BuiltSet<PromotionDiscountTypeEnum> get values => _$promotionDiscountTypeEnumValues;
  static PromotionDiscountTypeEnum valueOf(String name) => _$promotionDiscountTypeEnumValueOf(name);
}


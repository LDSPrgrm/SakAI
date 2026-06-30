// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'promotion.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PromotionDiscountTypeEnum _$promotionDiscountTypeEnum_percentage =
    const PromotionDiscountTypeEnum._('percentage');
const PromotionDiscountTypeEnum _$promotionDiscountTypeEnum_fixed =
    const PromotionDiscountTypeEnum._('fixed');

PromotionDiscountTypeEnum _$promotionDiscountTypeEnumValueOf(String name) {
  switch (name) {
    case 'percentage':
      return _$promotionDiscountTypeEnum_percentage;
    case 'fixed':
      return _$promotionDiscountTypeEnum_fixed;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PromotionDiscountTypeEnum> _$promotionDiscountTypeEnumValues =
    BuiltSet<PromotionDiscountTypeEnum>(const <PromotionDiscountTypeEnum>[
      _$promotionDiscountTypeEnum_percentage,
      _$promotionDiscountTypeEnum_fixed,
    ]);

Serializer<PromotionDiscountTypeEnum> _$promotionDiscountTypeEnumSerializer =
    _$PromotionDiscountTypeEnumSerializer();

class _$PromotionDiscountTypeEnumSerializer
    implements PrimitiveSerializer<PromotionDiscountTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'percentage': 'percentage',
    'fixed': 'fixed',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'percentage': 'percentage',
    'fixed': 'fixed',
  };

  @override
  final Iterable<Type> types = const <Type>[PromotionDiscountTypeEnum];
  @override
  final String wireName = 'PromotionDiscountTypeEnum';

  @override
  Object serialize(
    Serializers serializers,
    PromotionDiscountTypeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  PromotionDiscountTypeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => PromotionDiscountTypeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$Promotion extends Promotion {
  @override
  final String id;
  @override
  final String code;
  @override
  final String? title;
  @override
  final String description;
  @override
  final double discountValue;
  @override
  final PromotionDiscountTypeEnum discountType;
  @override
  final double? maxDiscount;
  @override
  final double? minRideAmount;
  @override
  final DateTime expiresAt;
  @override
  final String? terms;

  factory _$Promotion([void Function(PromotionBuilder)? updates]) =>
      (PromotionBuilder()..update(updates))._build();

  _$Promotion._({
    required this.id,
    required this.code,
    this.title,
    required this.description,
    required this.discountValue,
    required this.discountType,
    this.maxDiscount,
    this.minRideAmount,
    required this.expiresAt,
    this.terms,
  }) : super._();
  @override
  Promotion rebuild(void Function(PromotionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PromotionBuilder toBuilder() => PromotionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Promotion &&
        id == other.id &&
        code == other.code &&
        title == other.title &&
        description == other.description &&
        discountValue == other.discountValue &&
        discountType == other.discountType &&
        maxDiscount == other.maxDiscount &&
        minRideAmount == other.minRideAmount &&
        expiresAt == other.expiresAt &&
        terms == other.terms;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, discountValue.hashCode);
    _$hash = $jc(_$hash, discountType.hashCode);
    _$hash = $jc(_$hash, maxDiscount.hashCode);
    _$hash = $jc(_$hash, minRideAmount.hashCode);
    _$hash = $jc(_$hash, expiresAt.hashCode);
    _$hash = $jc(_$hash, terms.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Promotion')
          ..add('id', id)
          ..add('code', code)
          ..add('title', title)
          ..add('description', description)
          ..add('discountValue', discountValue)
          ..add('discountType', discountType)
          ..add('maxDiscount', maxDiscount)
          ..add('minRideAmount', minRideAmount)
          ..add('expiresAt', expiresAt)
          ..add('terms', terms))
        .toString();
  }
}

class PromotionBuilder implements Builder<Promotion, PromotionBuilder> {
  _$Promotion? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  double? _discountValue;
  double? get discountValue => _$this._discountValue;
  set discountValue(double? discountValue) =>
      _$this._discountValue = discountValue;

  PromotionDiscountTypeEnum? _discountType;
  PromotionDiscountTypeEnum? get discountType => _$this._discountType;
  set discountType(PromotionDiscountTypeEnum? discountType) =>
      _$this._discountType = discountType;

  double? _maxDiscount;
  double? get maxDiscount => _$this._maxDiscount;
  set maxDiscount(double? maxDiscount) => _$this._maxDiscount = maxDiscount;

  double? _minRideAmount;
  double? get minRideAmount => _$this._minRideAmount;
  set minRideAmount(double? minRideAmount) =>
      _$this._minRideAmount = minRideAmount;

  DateTime? _expiresAt;
  DateTime? get expiresAt => _$this._expiresAt;
  set expiresAt(DateTime? expiresAt) => _$this._expiresAt = expiresAt;

  String? _terms;
  String? get terms => _$this._terms;
  set terms(String? terms) => _$this._terms = terms;

  PromotionBuilder() {
    Promotion._defaults(this);
  }

  PromotionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _code = $v.code;
      _title = $v.title;
      _description = $v.description;
      _discountValue = $v.discountValue;
      _discountType = $v.discountType;
      _maxDiscount = $v.maxDiscount;
      _minRideAmount = $v.minRideAmount;
      _expiresAt = $v.expiresAt;
      _terms = $v.terms;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Promotion other) {
    _$v = other as _$Promotion;
  }

  @override
  void update(void Function(PromotionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Promotion build() => _build();

  _$Promotion _build() {
    final _$result =
        _$v ??
        _$Promotion._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'Promotion', 'id'),
          code: BuiltValueNullFieldError.checkNotNull(
            code,
            r'Promotion',
            'code',
          ),
          title: title,
          description: BuiltValueNullFieldError.checkNotNull(
            description,
            r'Promotion',
            'description',
          ),
          discountValue: BuiltValueNullFieldError.checkNotNull(
            discountValue,
            r'Promotion',
            'discountValue',
          ),
          discountType: BuiltValueNullFieldError.checkNotNull(
            discountType,
            r'Promotion',
            'discountType',
          ),
          maxDiscount: maxDiscount,
          minRideAmount: minRideAmount,
          expiresAt: BuiltValueNullFieldError.checkNotNull(
            expiresAt,
            r'Promotion',
            'expiresAt',
          ),
          terms: terms,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

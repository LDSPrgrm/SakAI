// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_details.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CardDetails extends CardDetails {
  @override
  final String last4;
  @override
  final int expiryMonth;
  @override
  final int expiryYear;
  @override
  final String brand;

  factory _$CardDetails([void Function(CardDetailsBuilder)? updates]) =>
      (CardDetailsBuilder()..update(updates))._build();

  _$CardDetails._(
      {required this.last4,
      required this.expiryMonth,
      required this.expiryYear,
      required this.brand})
      : super._();
  @override
  CardDetails rebuild(void Function(CardDetailsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CardDetailsBuilder toBuilder() => CardDetailsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CardDetails &&
        last4 == other.last4 &&
        expiryMonth == other.expiryMonth &&
        expiryYear == other.expiryYear &&
        brand == other.brand;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, last4.hashCode);
    _$hash = $jc(_$hash, expiryMonth.hashCode);
    _$hash = $jc(_$hash, expiryYear.hashCode);
    _$hash = $jc(_$hash, brand.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CardDetails')
          ..add('last4', last4)
          ..add('expiryMonth', expiryMonth)
          ..add('expiryYear', expiryYear)
          ..add('brand', brand))
        .toString();
  }
}

class CardDetailsBuilder implements Builder<CardDetails, CardDetailsBuilder> {
  _$CardDetails? _$v;

  String? _last4;
  String? get last4 => _$this._last4;
  set last4(String? last4) => _$this._last4 = last4;

  int? _expiryMonth;
  int? get expiryMonth => _$this._expiryMonth;
  set expiryMonth(int? expiryMonth) => _$this._expiryMonth = expiryMonth;

  int? _expiryYear;
  int? get expiryYear => _$this._expiryYear;
  set expiryYear(int? expiryYear) => _$this._expiryYear = expiryYear;

  String? _brand;
  String? get brand => _$this._brand;
  set brand(String? brand) => _$this._brand = brand;

  CardDetailsBuilder() {
    CardDetails._defaults(this);
  }

  CardDetailsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _last4 = $v.last4;
      _expiryMonth = $v.expiryMonth;
      _expiryYear = $v.expiryYear;
      _brand = $v.brand;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CardDetails other) {
    _$v = other as _$CardDetails;
  }

  @override
  void update(void Function(CardDetailsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CardDetails build() => _build();

  _$CardDetails _build() {
    final _$result = _$v ??
        _$CardDetails._(
          last4: BuiltValueNullFieldError.checkNotNull(
              last4, r'CardDetails', 'last4'),
          expiryMonth: BuiltValueNullFieldError.checkNotNull(
              expiryMonth, r'CardDetails', 'expiryMonth'),
          expiryYear: BuiltValueNullFieldError.checkNotNull(
              expiryYear, r'CardDetails', 'expiryYear'),
          brand: BuiltValueNullFieldError.checkNotNull(
              brand, r'CardDetails', 'brand'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

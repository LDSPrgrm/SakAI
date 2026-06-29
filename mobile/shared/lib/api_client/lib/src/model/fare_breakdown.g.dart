// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fare_breakdown.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$FareBreakdown extends FareBreakdown {
  @override
  final double baseFare;
  @override
  final double distanceCharge;
  @override
  final double timeCharge;
  @override
  final double bookingFee;
  @override
  final double? surgeMultiplier;
  @override
  final double? discount;

  factory _$FareBreakdown([void Function(FareBreakdownBuilder)? updates]) =>
      (FareBreakdownBuilder()..update(updates))._build();

  _$FareBreakdown._({
    required this.baseFare,
    required this.distanceCharge,
    required this.timeCharge,
    required this.bookingFee,
    this.surgeMultiplier,
    this.discount,
  }) : super._();
  @override
  FareBreakdown rebuild(void Function(FareBreakdownBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FareBreakdownBuilder toBuilder() => FareBreakdownBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FareBreakdown &&
        baseFare == other.baseFare &&
        distanceCharge == other.distanceCharge &&
        timeCharge == other.timeCharge &&
        bookingFee == other.bookingFee &&
        surgeMultiplier == other.surgeMultiplier &&
        discount == other.discount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, baseFare.hashCode);
    _$hash = $jc(_$hash, distanceCharge.hashCode);
    _$hash = $jc(_$hash, timeCharge.hashCode);
    _$hash = $jc(_$hash, bookingFee.hashCode);
    _$hash = $jc(_$hash, surgeMultiplier.hashCode);
    _$hash = $jc(_$hash, discount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FareBreakdown')
          ..add('baseFare', baseFare)
          ..add('distanceCharge', distanceCharge)
          ..add('timeCharge', timeCharge)
          ..add('bookingFee', bookingFee)
          ..add('surgeMultiplier', surgeMultiplier)
          ..add('discount', discount))
        .toString();
  }
}

class FareBreakdownBuilder
    implements Builder<FareBreakdown, FareBreakdownBuilder> {
  _$FareBreakdown? _$v;

  double? _baseFare;
  double? get baseFare => _$this._baseFare;
  set baseFare(double? baseFare) => _$this._baseFare = baseFare;

  double? _distanceCharge;
  double? get distanceCharge => _$this._distanceCharge;
  set distanceCharge(double? distanceCharge) =>
      _$this._distanceCharge = distanceCharge;

  double? _timeCharge;
  double? get timeCharge => _$this._timeCharge;
  set timeCharge(double? timeCharge) => _$this._timeCharge = timeCharge;

  double? _bookingFee;
  double? get bookingFee => _$this._bookingFee;
  set bookingFee(double? bookingFee) => _$this._bookingFee = bookingFee;

  double? _surgeMultiplier;
  double? get surgeMultiplier => _$this._surgeMultiplier;
  set surgeMultiplier(double? surgeMultiplier) =>
      _$this._surgeMultiplier = surgeMultiplier;

  double? _discount;
  double? get discount => _$this._discount;
  set discount(double? discount) => _$this._discount = discount;

  FareBreakdownBuilder() {
    FareBreakdown._defaults(this);
  }

  FareBreakdownBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _baseFare = $v.baseFare;
      _distanceCharge = $v.distanceCharge;
      _timeCharge = $v.timeCharge;
      _bookingFee = $v.bookingFee;
      _surgeMultiplier = $v.surgeMultiplier;
      _discount = $v.discount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FareBreakdown other) {
    _$v = other as _$FareBreakdown;
  }

  @override
  void update(void Function(FareBreakdownBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FareBreakdown build() => _build();

  _$FareBreakdown _build() {
    final _$result =
        _$v ??
        _$FareBreakdown._(
          baseFare: BuiltValueNullFieldError.checkNotNull(
            baseFare,
            r'FareBreakdown',
            'baseFare',
          ),
          distanceCharge: BuiltValueNullFieldError.checkNotNull(
            distanceCharge,
            r'FareBreakdown',
            'distanceCharge',
          ),
          timeCharge: BuiltValueNullFieldError.checkNotNull(
            timeCharge,
            r'FareBreakdown',
            'timeCharge',
          ),
          bookingFee: BuiltValueNullFieldError.checkNotNull(
            bookingFee,
            r'FareBreakdown',
            'bookingFee',
          ),
          surgeMultiplier: surgeMultiplier,
          discount: discount,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

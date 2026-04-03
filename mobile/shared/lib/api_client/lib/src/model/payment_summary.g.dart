// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_summary.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PaymentSummary extends PaymentSummary {
  @override
  final num? totalRevenue;
  @override
  final num? payouts;
  @override
  final num? commission;
  @override
  final num? pendingSettlements;

  factory _$PaymentSummary([void Function(PaymentSummaryBuilder)? updates]) =>
      (PaymentSummaryBuilder()..update(updates))._build();

  _$PaymentSummary._({
    this.totalRevenue,
    this.payouts,
    this.commission,
    this.pendingSettlements,
  }) : super._();
  @override
  PaymentSummary rebuild(void Function(PaymentSummaryBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PaymentSummaryBuilder toBuilder() => PaymentSummaryBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PaymentSummary &&
        totalRevenue == other.totalRevenue &&
        payouts == other.payouts &&
        commission == other.commission &&
        pendingSettlements == other.pendingSettlements;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, totalRevenue.hashCode);
    _$hash = $jc(_$hash, payouts.hashCode);
    _$hash = $jc(_$hash, commission.hashCode);
    _$hash = $jc(_$hash, pendingSettlements.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PaymentSummary')
          ..add('totalRevenue', totalRevenue)
          ..add('payouts', payouts)
          ..add('commission', commission)
          ..add('pendingSettlements', pendingSettlements))
        .toString();
  }
}

class PaymentSummaryBuilder
    implements Builder<PaymentSummary, PaymentSummaryBuilder> {
  _$PaymentSummary? _$v;

  num? _totalRevenue;
  num? get totalRevenue => _$this._totalRevenue;
  set totalRevenue(num? totalRevenue) => _$this._totalRevenue = totalRevenue;

  num? _payouts;
  num? get payouts => _$this._payouts;
  set payouts(num? payouts) => _$this._payouts = payouts;

  num? _commission;
  num? get commission => _$this._commission;
  set commission(num? commission) => _$this._commission = commission;

  num? _pendingSettlements;
  num? get pendingSettlements => _$this._pendingSettlements;
  set pendingSettlements(num? pendingSettlements) =>
      _$this._pendingSettlements = pendingSettlements;

  PaymentSummaryBuilder() {
    PaymentSummary._defaults(this);
  }

  PaymentSummaryBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _totalRevenue = $v.totalRevenue;
      _payouts = $v.payouts;
      _commission = $v.commission;
      _pendingSettlements = $v.pendingSettlements;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PaymentSummary other) {
    _$v = other as _$PaymentSummary;
  }

  @override
  void update(void Function(PaymentSummaryBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PaymentSummary build() => _build();

  _$PaymentSummary _build() {
    final _$result =
        _$v ??
        _$PaymentSummary._(
          totalRevenue: totalRevenue,
          payouts: payouts,
          commission: commission,
          pendingSettlements: pendingSettlements,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

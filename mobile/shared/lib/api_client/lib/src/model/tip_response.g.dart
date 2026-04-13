// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tip_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TipResponse extends TipResponse {
  @override
  final String rideId;
  @override
  final double baseFare;
  @override
  final double tipAmount;
  @override
  final double finalTotal;
  @override
  final String currency;
  @override
  final PaymentMethod paymentMethod;
  @override
  final String transactionId;
  @override
  final DateTime? processedAt;

  factory _$TipResponse([void Function(TipResponseBuilder)? updates]) =>
      (TipResponseBuilder()..update(updates))._build();

  _$TipResponse._(
      {required this.rideId,
      required this.baseFare,
      required this.tipAmount,
      required this.finalTotal,
      required this.currency,
      required this.paymentMethod,
      required this.transactionId,
      this.processedAt})
      : super._();
  @override
  TipResponse rebuild(void Function(TipResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TipResponseBuilder toBuilder() => TipResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TipResponse &&
        rideId == other.rideId &&
        baseFare == other.baseFare &&
        tipAmount == other.tipAmount &&
        finalTotal == other.finalTotal &&
        currency == other.currency &&
        paymentMethod == other.paymentMethod &&
        transactionId == other.transactionId &&
        processedAt == other.processedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, rideId.hashCode);
    _$hash = $jc(_$hash, baseFare.hashCode);
    _$hash = $jc(_$hash, tipAmount.hashCode);
    _$hash = $jc(_$hash, finalTotal.hashCode);
    _$hash = $jc(_$hash, currency.hashCode);
    _$hash = $jc(_$hash, paymentMethod.hashCode);
    _$hash = $jc(_$hash, transactionId.hashCode);
    _$hash = $jc(_$hash, processedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TipResponse')
          ..add('rideId', rideId)
          ..add('baseFare', baseFare)
          ..add('tipAmount', tipAmount)
          ..add('finalTotal', finalTotal)
          ..add('currency', currency)
          ..add('paymentMethod', paymentMethod)
          ..add('transactionId', transactionId)
          ..add('processedAt', processedAt))
        .toString();
  }
}

class TipResponseBuilder implements Builder<TipResponse, TipResponseBuilder> {
  _$TipResponse? _$v;

  String? _rideId;
  String? get rideId => _$this._rideId;
  set rideId(String? rideId) => _$this._rideId = rideId;

  double? _baseFare;
  double? get baseFare => _$this._baseFare;
  set baseFare(double? baseFare) => _$this._baseFare = baseFare;

  double? _tipAmount;
  double? get tipAmount => _$this._tipAmount;
  set tipAmount(double? tipAmount) => _$this._tipAmount = tipAmount;

  double? _finalTotal;
  double? get finalTotal => _$this._finalTotal;
  set finalTotal(double? finalTotal) => _$this._finalTotal = finalTotal;

  String? _currency;
  String? get currency => _$this._currency;
  set currency(String? currency) => _$this._currency = currency;

  PaymentMethod? _paymentMethod;
  PaymentMethod? get paymentMethod => _$this._paymentMethod;
  set paymentMethod(PaymentMethod? paymentMethod) =>
      _$this._paymentMethod = paymentMethod;

  String? _transactionId;
  String? get transactionId => _$this._transactionId;
  set transactionId(String? transactionId) =>
      _$this._transactionId = transactionId;

  DateTime? _processedAt;
  DateTime? get processedAt => _$this._processedAt;
  set processedAt(DateTime? processedAt) => _$this._processedAt = processedAt;

  TipResponseBuilder() {
    TipResponse._defaults(this);
  }

  TipResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _rideId = $v.rideId;
      _baseFare = $v.baseFare;
      _tipAmount = $v.tipAmount;
      _finalTotal = $v.finalTotal;
      _currency = $v.currency;
      _paymentMethod = $v.paymentMethod;
      _transactionId = $v.transactionId;
      _processedAt = $v.processedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TipResponse other) {
    _$v = other as _$TipResponse;
  }

  @override
  void update(void Function(TipResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TipResponse build() => _build();

  _$TipResponse _build() {
    final _$result = _$v ??
        _$TipResponse._(
          rideId: BuiltValueNullFieldError.checkNotNull(
              rideId, r'TipResponse', 'rideId'),
          baseFare: BuiltValueNullFieldError.checkNotNull(
              baseFare, r'TipResponse', 'baseFare'),
          tipAmount: BuiltValueNullFieldError.checkNotNull(
              tipAmount, r'TipResponse', 'tipAmount'),
          finalTotal: BuiltValueNullFieldError.checkNotNull(
              finalTotal, r'TipResponse', 'finalTotal'),
          currency: BuiltValueNullFieldError.checkNotNull(
              currency, r'TipResponse', 'currency'),
          paymentMethod: BuiltValueNullFieldError.checkNotNull(
              paymentMethod, r'TipResponse', 'paymentMethod'),
          transactionId: BuiltValueNullFieldError.checkNotNull(
              transactionId, r'TipResponse', 'transactionId'),
          processedAt: processedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

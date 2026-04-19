// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PaymentResponse extends PaymentResponse {
  @override
  final String id;
  @override
  final String rideId;
  @override
  final double amount;
  @override
  final String currency;
  @override
  final PaymentMethod method;
  @override
  final PaymentStatus status;
  @override
  final String? gatewayTransactionId;
  @override
  final String? failureReason;
  @override
  final DateTime processedAt;

  factory _$PaymentResponse([void Function(PaymentResponseBuilder)? updates]) =>
      (PaymentResponseBuilder()..update(updates))._build();

  _$PaymentResponse._({
    required this.id,
    required this.rideId,
    required this.amount,
    required this.currency,
    required this.method,
    required this.status,
    this.gatewayTransactionId,
    this.failureReason,
    required this.processedAt,
  }) : super._();
  @override
  PaymentResponse rebuild(void Function(PaymentResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PaymentResponseBuilder toBuilder() => PaymentResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PaymentResponse &&
        id == other.id &&
        rideId == other.rideId &&
        amount == other.amount &&
        currency == other.currency &&
        method == other.method &&
        status == other.status &&
        gatewayTransactionId == other.gatewayTransactionId &&
        failureReason == other.failureReason &&
        processedAt == other.processedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, rideId.hashCode);
    _$hash = $jc(_$hash, amount.hashCode);
    _$hash = $jc(_$hash, currency.hashCode);
    _$hash = $jc(_$hash, method.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, gatewayTransactionId.hashCode);
    _$hash = $jc(_$hash, failureReason.hashCode);
    _$hash = $jc(_$hash, processedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PaymentResponse')
          ..add('id', id)
          ..add('rideId', rideId)
          ..add('amount', amount)
          ..add('currency', currency)
          ..add('method', method)
          ..add('status', status)
          ..add('gatewayTransactionId', gatewayTransactionId)
          ..add('failureReason', failureReason)
          ..add('processedAt', processedAt))
        .toString();
  }
}

class PaymentResponseBuilder
    implements Builder<PaymentResponse, PaymentResponseBuilder> {
  _$PaymentResponse? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _rideId;
  String? get rideId => _$this._rideId;
  set rideId(String? rideId) => _$this._rideId = rideId;

  double? _amount;
  double? get amount => _$this._amount;
  set amount(double? amount) => _$this._amount = amount;

  String? _currency;
  String? get currency => _$this._currency;
  set currency(String? currency) => _$this._currency = currency;

  PaymentMethod? _method;
  PaymentMethod? get method => _$this._method;
  set method(PaymentMethod? method) => _$this._method = method;

  PaymentStatus? _status;
  PaymentStatus? get status => _$this._status;
  set status(PaymentStatus? status) => _$this._status = status;

  String? _gatewayTransactionId;
  String? get gatewayTransactionId => _$this._gatewayTransactionId;
  set gatewayTransactionId(String? gatewayTransactionId) =>
      _$this._gatewayTransactionId = gatewayTransactionId;

  String? _failureReason;
  String? get failureReason => _$this._failureReason;
  set failureReason(String? failureReason) =>
      _$this._failureReason = failureReason;

  DateTime? _processedAt;
  DateTime? get processedAt => _$this._processedAt;
  set processedAt(DateTime? processedAt) => _$this._processedAt = processedAt;

  PaymentResponseBuilder() {
    PaymentResponse._defaults(this);
  }

  PaymentResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _rideId = $v.rideId;
      _amount = $v.amount;
      _currency = $v.currency;
      _method = $v.method;
      _status = $v.status;
      _gatewayTransactionId = $v.gatewayTransactionId;
      _failureReason = $v.failureReason;
      _processedAt = $v.processedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PaymentResponse other) {
    _$v = other as _$PaymentResponse;
  }

  @override
  void update(void Function(PaymentResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PaymentResponse build() => _build();

  _$PaymentResponse _build() {
    final _$result =
        _$v ??
        _$PaymentResponse._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'PaymentResponse',
            'id',
          ),
          rideId: BuiltValueNullFieldError.checkNotNull(
            rideId,
            r'PaymentResponse',
            'rideId',
          ),
          amount: BuiltValueNullFieldError.checkNotNull(
            amount,
            r'PaymentResponse',
            'amount',
          ),
          currency: BuiltValueNullFieldError.checkNotNull(
            currency,
            r'PaymentResponse',
            'currency',
          ),
          method: BuiltValueNullFieldError.checkNotNull(
            method,
            r'PaymentResponse',
            'method',
          ),
          status: BuiltValueNullFieldError.checkNotNull(
            status,
            r'PaymentResponse',
            'status',
          ),
          gatewayTransactionId: gatewayTransactionId,
          failureReason: failureReason,
          processedAt: BuiltValueNullFieldError.checkNotNull(
            processedAt,
            r'PaymentResponse',
            'processedAt',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

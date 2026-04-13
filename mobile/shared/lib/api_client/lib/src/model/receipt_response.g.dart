// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ReceiptResponse extends ReceiptResponse {
  @override
  final String rideId;
  @override
  final String passengerName;
  @override
  final String driverName;
  @override
  final String? pickupAddress;
  @override
  final String? destinationAddress;
  @override
  final double amount;
  @override
  final String currency;
  @override
  final PaymentMethod paymentMethod;
  @override
  final PaymentStatus paymentStatus;
  @override
  final DateTime? completedAt;
  @override
  final DateTime? processedAt;

  factory _$ReceiptResponse([void Function(ReceiptResponseBuilder)? updates]) =>
      (ReceiptResponseBuilder()..update(updates))._build();

  _$ReceiptResponse._(
      {required this.rideId,
      required this.passengerName,
      required this.driverName,
      this.pickupAddress,
      this.destinationAddress,
      required this.amount,
      required this.currency,
      required this.paymentMethod,
      required this.paymentStatus,
      this.completedAt,
      this.processedAt})
      : super._();
  @override
  ReceiptResponse rebuild(void Function(ReceiptResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReceiptResponseBuilder toBuilder() => ReceiptResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReceiptResponse &&
        rideId == other.rideId &&
        passengerName == other.passengerName &&
        driverName == other.driverName &&
        pickupAddress == other.pickupAddress &&
        destinationAddress == other.destinationAddress &&
        amount == other.amount &&
        currency == other.currency &&
        paymentMethod == other.paymentMethod &&
        paymentStatus == other.paymentStatus &&
        completedAt == other.completedAt &&
        processedAt == other.processedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, rideId.hashCode);
    _$hash = $jc(_$hash, passengerName.hashCode);
    _$hash = $jc(_$hash, driverName.hashCode);
    _$hash = $jc(_$hash, pickupAddress.hashCode);
    _$hash = $jc(_$hash, destinationAddress.hashCode);
    _$hash = $jc(_$hash, amount.hashCode);
    _$hash = $jc(_$hash, currency.hashCode);
    _$hash = $jc(_$hash, paymentMethod.hashCode);
    _$hash = $jc(_$hash, paymentStatus.hashCode);
    _$hash = $jc(_$hash, completedAt.hashCode);
    _$hash = $jc(_$hash, processedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ReceiptResponse')
          ..add('rideId', rideId)
          ..add('passengerName', passengerName)
          ..add('driverName', driverName)
          ..add('pickupAddress', pickupAddress)
          ..add('destinationAddress', destinationAddress)
          ..add('amount', amount)
          ..add('currency', currency)
          ..add('paymentMethod', paymentMethod)
          ..add('paymentStatus', paymentStatus)
          ..add('completedAt', completedAt)
          ..add('processedAt', processedAt))
        .toString();
  }
}

class ReceiptResponseBuilder
    implements Builder<ReceiptResponse, ReceiptResponseBuilder> {
  _$ReceiptResponse? _$v;

  String? _rideId;
  String? get rideId => _$this._rideId;
  set rideId(String? rideId) => _$this._rideId = rideId;

  String? _passengerName;
  String? get passengerName => _$this._passengerName;
  set passengerName(String? passengerName) =>
      _$this._passengerName = passengerName;

  String? _driverName;
  String? get driverName => _$this._driverName;
  set driverName(String? driverName) => _$this._driverName = driverName;

  String? _pickupAddress;
  String? get pickupAddress => _$this._pickupAddress;
  set pickupAddress(String? pickupAddress) =>
      _$this._pickupAddress = pickupAddress;

  String? _destinationAddress;
  String? get destinationAddress => _$this._destinationAddress;
  set destinationAddress(String? destinationAddress) =>
      _$this._destinationAddress = destinationAddress;

  double? _amount;
  double? get amount => _$this._amount;
  set amount(double? amount) => _$this._amount = amount;

  String? _currency;
  String? get currency => _$this._currency;
  set currency(String? currency) => _$this._currency = currency;

  PaymentMethod? _paymentMethod;
  PaymentMethod? get paymentMethod => _$this._paymentMethod;
  set paymentMethod(PaymentMethod? paymentMethod) =>
      _$this._paymentMethod = paymentMethod;

  PaymentStatus? _paymentStatus;
  PaymentStatus? get paymentStatus => _$this._paymentStatus;
  set paymentStatus(PaymentStatus? paymentStatus) =>
      _$this._paymentStatus = paymentStatus;

  DateTime? _completedAt;
  DateTime? get completedAt => _$this._completedAt;
  set completedAt(DateTime? completedAt) => _$this._completedAt = completedAt;

  DateTime? _processedAt;
  DateTime? get processedAt => _$this._processedAt;
  set processedAt(DateTime? processedAt) => _$this._processedAt = processedAt;

  ReceiptResponseBuilder() {
    ReceiptResponse._defaults(this);
  }

  ReceiptResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _rideId = $v.rideId;
      _passengerName = $v.passengerName;
      _driverName = $v.driverName;
      _pickupAddress = $v.pickupAddress;
      _destinationAddress = $v.destinationAddress;
      _amount = $v.amount;
      _currency = $v.currency;
      _paymentMethod = $v.paymentMethod;
      _paymentStatus = $v.paymentStatus;
      _completedAt = $v.completedAt;
      _processedAt = $v.processedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReceiptResponse other) {
    _$v = other as _$ReceiptResponse;
  }

  @override
  void update(void Function(ReceiptResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReceiptResponse build() => _build();

  _$ReceiptResponse _build() {
    final _$result = _$v ??
        _$ReceiptResponse._(
          rideId: BuiltValueNullFieldError.checkNotNull(
              rideId, r'ReceiptResponse', 'rideId'),
          passengerName: BuiltValueNullFieldError.checkNotNull(
              passengerName, r'ReceiptResponse', 'passengerName'),
          driverName: BuiltValueNullFieldError.checkNotNull(
              driverName, r'ReceiptResponse', 'driverName'),
          pickupAddress: pickupAddress,
          destinationAddress: destinationAddress,
          amount: BuiltValueNullFieldError.checkNotNull(
              amount, r'ReceiptResponse', 'amount'),
          currency: BuiltValueNullFieldError.checkNotNull(
              currency, r'ReceiptResponse', 'currency'),
          paymentMethod: BuiltValueNullFieldError.checkNotNull(
              paymentMethod, r'ReceiptResponse', 'paymentMethod'),
          paymentStatus: BuiltValueNullFieldError.checkNotNull(
              paymentStatus, r'ReceiptResponse', 'paymentStatus'),
          completedAt: completedAt,
          processedAt: processedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

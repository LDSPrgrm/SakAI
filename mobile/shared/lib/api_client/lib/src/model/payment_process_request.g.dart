// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_process_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PaymentProcessRequest extends PaymentProcessRequest {
  @override
  final String rideId;
  @override
  final String paymentMethodToken;

  factory _$PaymentProcessRequest([
    void Function(PaymentProcessRequestBuilder)? updates,
  ]) => (PaymentProcessRequestBuilder()..update(updates))._build();

  _$PaymentProcessRequest._({
    required this.rideId,
    required this.paymentMethodToken,
  }) : super._();
  @override
  PaymentProcessRequest rebuild(
    void Function(PaymentProcessRequestBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  PaymentProcessRequestBuilder toBuilder() =>
      PaymentProcessRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PaymentProcessRequest &&
        rideId == other.rideId &&
        paymentMethodToken == other.paymentMethodToken;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, rideId.hashCode);
    _$hash = $jc(_$hash, paymentMethodToken.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PaymentProcessRequest')
          ..add('rideId', rideId)
          ..add('paymentMethodToken', paymentMethodToken))
        .toString();
  }
}

class PaymentProcessRequestBuilder
    implements Builder<PaymentProcessRequest, PaymentProcessRequestBuilder> {
  _$PaymentProcessRequest? _$v;

  String? _rideId;
  String? get rideId => _$this._rideId;
  set rideId(String? rideId) => _$this._rideId = rideId;

  String? _paymentMethodToken;
  String? get paymentMethodToken => _$this._paymentMethodToken;
  set paymentMethodToken(String? paymentMethodToken) =>
      _$this._paymentMethodToken = paymentMethodToken;

  PaymentProcessRequestBuilder() {
    PaymentProcessRequest._defaults(this);
  }

  PaymentProcessRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _rideId = $v.rideId;
      _paymentMethodToken = $v.paymentMethodToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PaymentProcessRequest other) {
    _$v = other as _$PaymentProcessRequest;
  }

  @override
  void update(void Function(PaymentProcessRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PaymentProcessRequest build() => _build();

  _$PaymentProcessRequest _build() {
    final _$result =
        _$v ??
        _$PaymentProcessRequest._(
          rideId: BuiltValueNullFieldError.checkNotNull(
            rideId,
            r'PaymentProcessRequest',
            'rideId',
          ),
          paymentMethodToken: BuiltValueNullFieldError.checkNotNull(
            paymentMethodToken,
            r'PaymentProcessRequest',
            'paymentMethodToken',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_payment_method_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AddPaymentMethodRequest extends AddPaymentMethodRequest {
  @override
  final PaymentMethodType type;
  @override
  final String? cardToken;
  @override
  final String? provider;
  @override
  final String? accountId;
  @override
  final bool? setAsDefault;

  factory _$AddPaymentMethodRequest([
    void Function(AddPaymentMethodRequestBuilder)? updates,
  ]) => (AddPaymentMethodRequestBuilder()..update(updates))._build();

  _$AddPaymentMethodRequest._({
    required this.type,
    this.cardToken,
    this.provider,
    this.accountId,
    this.setAsDefault,
  }) : super._();
  @override
  AddPaymentMethodRequest rebuild(
    void Function(AddPaymentMethodRequestBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AddPaymentMethodRequestBuilder toBuilder() =>
      AddPaymentMethodRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AddPaymentMethodRequest &&
        type == other.type &&
        cardToken == other.cardToken &&
        provider == other.provider &&
        accountId == other.accountId &&
        setAsDefault == other.setAsDefault;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, cardToken.hashCode);
    _$hash = $jc(_$hash, provider.hashCode);
    _$hash = $jc(_$hash, accountId.hashCode);
    _$hash = $jc(_$hash, setAsDefault.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AddPaymentMethodRequest')
          ..add('type', type)
          ..add('cardToken', cardToken)
          ..add('provider', provider)
          ..add('accountId', accountId)
          ..add('setAsDefault', setAsDefault))
        .toString();
  }
}

class AddPaymentMethodRequestBuilder
    implements
        Builder<AddPaymentMethodRequest, AddPaymentMethodRequestBuilder> {
  _$AddPaymentMethodRequest? _$v;

  PaymentMethodType? _type;
  PaymentMethodType? get type => _$this._type;
  set type(PaymentMethodType? type) => _$this._type = type;

  String? _cardToken;
  String? get cardToken => _$this._cardToken;
  set cardToken(String? cardToken) => _$this._cardToken = cardToken;

  String? _provider;
  String? get provider => _$this._provider;
  set provider(String? provider) => _$this._provider = provider;

  String? _accountId;
  String? get accountId => _$this._accountId;
  set accountId(String? accountId) => _$this._accountId = accountId;

  bool? _setAsDefault;
  bool? get setAsDefault => _$this._setAsDefault;
  set setAsDefault(bool? setAsDefault) => _$this._setAsDefault = setAsDefault;

  AddPaymentMethodRequestBuilder() {
    AddPaymentMethodRequest._defaults(this);
  }

  AddPaymentMethodRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _type = $v.type;
      _cardToken = $v.cardToken;
      _provider = $v.provider;
      _accountId = $v.accountId;
      _setAsDefault = $v.setAsDefault;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AddPaymentMethodRequest other) {
    _$v = other as _$AddPaymentMethodRequest;
  }

  @override
  void update(void Function(AddPaymentMethodRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AddPaymentMethodRequest build() => _build();

  _$AddPaymentMethodRequest _build() {
    final _$result =
        _$v ??
        _$AddPaymentMethodRequest._(
          type: BuiltValueNullFieldError.checkNotNull(
            type,
            r'AddPaymentMethodRequest',
            'type',
          ),
          cardToken: cardToken,
          provider: provider,
          accountId: accountId,
          setAsDefault: setAsDefault,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

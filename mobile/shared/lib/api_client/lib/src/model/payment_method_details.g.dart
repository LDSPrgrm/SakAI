// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_method_details.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PaymentMethodDetails extends PaymentMethodDetails {
  @override
  final String id;
  @override
  final PaymentMethodType type;
  @override
  final bool isDefault;
  @override
  final DateTime createdAt;
  @override
  final CardDetails? card;
  @override
  final EWalletDetails? eWallet;

  factory _$PaymentMethodDetails(
          [void Function(PaymentMethodDetailsBuilder)? updates]) =>
      (PaymentMethodDetailsBuilder()..update(updates))._build();

  _$PaymentMethodDetails._(
      {required this.id,
      required this.type,
      required this.isDefault,
      required this.createdAt,
      this.card,
      this.eWallet})
      : super._();
  @override
  PaymentMethodDetails rebuild(
          void Function(PaymentMethodDetailsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PaymentMethodDetailsBuilder toBuilder() =>
      PaymentMethodDetailsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PaymentMethodDetails &&
        id == other.id &&
        type == other.type &&
        isDefault == other.isDefault &&
        createdAt == other.createdAt &&
        card == other.card &&
        eWallet == other.eWallet;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, isDefault.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, card.hashCode);
    _$hash = $jc(_$hash, eWallet.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PaymentMethodDetails')
          ..add('id', id)
          ..add('type', type)
          ..add('isDefault', isDefault)
          ..add('createdAt', createdAt)
          ..add('card', card)
          ..add('eWallet', eWallet))
        .toString();
  }
}

class PaymentMethodDetailsBuilder
    implements Builder<PaymentMethodDetails, PaymentMethodDetailsBuilder> {
  _$PaymentMethodDetails? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  PaymentMethodType? _type;
  PaymentMethodType? get type => _$this._type;
  set type(PaymentMethodType? type) => _$this._type = type;

  bool? _isDefault;
  bool? get isDefault => _$this._isDefault;
  set isDefault(bool? isDefault) => _$this._isDefault = isDefault;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  CardDetailsBuilder? _card;
  CardDetailsBuilder get card => _$this._card ??= CardDetailsBuilder();
  set card(CardDetailsBuilder? card) => _$this._card = card;

  EWalletDetailsBuilder? _eWallet;
  EWalletDetailsBuilder get eWallet =>
      _$this._eWallet ??= EWalletDetailsBuilder();
  set eWallet(EWalletDetailsBuilder? eWallet) => _$this._eWallet = eWallet;

  PaymentMethodDetailsBuilder() {
    PaymentMethodDetails._defaults(this);
  }

  PaymentMethodDetailsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _type = $v.type;
      _isDefault = $v.isDefault;
      _createdAt = $v.createdAt;
      _card = $v.card?.toBuilder();
      _eWallet = $v.eWallet?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PaymentMethodDetails other) {
    _$v = other as _$PaymentMethodDetails;
  }

  @override
  void update(void Function(PaymentMethodDetailsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PaymentMethodDetails build() => _build();

  _$PaymentMethodDetails _build() {
    _$PaymentMethodDetails _$result;
    try {
      _$result = _$v ??
          _$PaymentMethodDetails._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'PaymentMethodDetails', 'id'),
            type: BuiltValueNullFieldError.checkNotNull(
                type, r'PaymentMethodDetails', 'type'),
            isDefault: BuiltValueNullFieldError.checkNotNull(
                isDefault, r'PaymentMethodDetails', 'isDefault'),
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'PaymentMethodDetails', 'createdAt'),
            card: _card?.build(),
            eWallet: _eWallet?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'card';
        _card?.build();
        _$failedField = 'eWallet';
        _eWallet?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PaymentMethodDetails', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

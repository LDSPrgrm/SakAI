// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'e_wallet_details.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$EWalletDetails extends EWalletDetails {
  @override
  final String provider;
  @override
  final String accountId;

  factory _$EWalletDetails([void Function(EWalletDetailsBuilder)? updates]) =>
      (EWalletDetailsBuilder()..update(updates))._build();

  _$EWalletDetails._({required this.provider, required this.accountId})
      : super._();
  @override
  EWalletDetails rebuild(void Function(EWalletDetailsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EWalletDetailsBuilder toBuilder() => EWalletDetailsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EWalletDetails &&
        provider == other.provider &&
        accountId == other.accountId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, provider.hashCode);
    _$hash = $jc(_$hash, accountId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'EWalletDetails')
          ..add('provider', provider)
          ..add('accountId', accountId))
        .toString();
  }
}

class EWalletDetailsBuilder
    implements Builder<EWalletDetails, EWalletDetailsBuilder> {
  _$EWalletDetails? _$v;

  String? _provider;
  String? get provider => _$this._provider;
  set provider(String? provider) => _$this._provider = provider;

  String? _accountId;
  String? get accountId => _$this._accountId;
  set accountId(String? accountId) => _$this._accountId = accountId;

  EWalletDetailsBuilder() {
    EWalletDetails._defaults(this);
  }

  EWalletDetailsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _provider = $v.provider;
      _accountId = $v.accountId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(EWalletDetails other) {
    _$v = other as _$EWalletDetails;
  }

  @override
  void update(void Function(EWalletDetailsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  EWalletDetails build() => _build();

  _$EWalletDetails _build() {
    final _$result = _$v ??
        _$EWalletDetails._(
          provider: BuiltValueNullFieldError.checkNotNull(
              provider, r'EWalletDetails', 'provider'),
          accountId: BuiltValueNullFieldError.checkNotNull(
              accountId, r'EWalletDetails', 'accountId'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

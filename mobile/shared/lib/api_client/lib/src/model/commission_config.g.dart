// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commission_config.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CommissionConfig extends CommissionConfig {
  @override
  final CommissionConfigRates? rates;
  @override
  final num? minimumCommission;
  @override
  final num? promotionalOverride;

  factory _$CommissionConfig([
    void Function(CommissionConfigBuilder)? updates,
  ]) => (CommissionConfigBuilder()..update(updates))._build();

  _$CommissionConfig._({
    this.rates,
    this.minimumCommission,
    this.promotionalOverride,
  }) : super._();
  @override
  CommissionConfig rebuild(void Function(CommissionConfigBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CommissionConfigBuilder toBuilder() =>
      CommissionConfigBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CommissionConfig &&
        rates == other.rates &&
        minimumCommission == other.minimumCommission &&
        promotionalOverride == other.promotionalOverride;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, rates.hashCode);
    _$hash = $jc(_$hash, minimumCommission.hashCode);
    _$hash = $jc(_$hash, promotionalOverride.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CommissionConfig')
          ..add('rates', rates)
          ..add('minimumCommission', minimumCommission)
          ..add('promotionalOverride', promotionalOverride))
        .toString();
  }
}

class CommissionConfigBuilder
    implements Builder<CommissionConfig, CommissionConfigBuilder> {
  _$CommissionConfig? _$v;

  CommissionConfigRatesBuilder? _rates;
  CommissionConfigRatesBuilder get rates =>
      _$this._rates ??= CommissionConfigRatesBuilder();
  set rates(CommissionConfigRatesBuilder? rates) => _$this._rates = rates;

  num? _minimumCommission;
  num? get minimumCommission => _$this._minimumCommission;
  set minimumCommission(num? minimumCommission) =>
      _$this._minimumCommission = minimumCommission;

  num? _promotionalOverride;
  num? get promotionalOverride => _$this._promotionalOverride;
  set promotionalOverride(num? promotionalOverride) =>
      _$this._promotionalOverride = promotionalOverride;

  CommissionConfigBuilder() {
    CommissionConfig._defaults(this);
  }

  CommissionConfigBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _rates = $v.rates?.toBuilder();
      _minimumCommission = $v.minimumCommission;
      _promotionalOverride = $v.promotionalOverride;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CommissionConfig other) {
    _$v = other as _$CommissionConfig;
  }

  @override
  void update(void Function(CommissionConfigBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CommissionConfig build() => _build();

  _$CommissionConfig _build() {
    _$CommissionConfig _$result;
    try {
      _$result =
          _$v ??
          _$CommissionConfig._(
            rates: _rates?.build(),
            minimumCommission: minimumCommission,
            promotionalOverride: promotionalOverride,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'rates';
        _rates?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'CommissionConfig',
          _$failedField,
          e.toString(),
        );
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

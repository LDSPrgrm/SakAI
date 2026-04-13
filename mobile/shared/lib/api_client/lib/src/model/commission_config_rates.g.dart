// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commission_config_rates.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CommissionConfigRates extends CommissionConfigRates {
  @override
  final num? motorcycle;
  @override
  final num? tricycle;
  @override
  final num? car;
  @override
  final num? other;

  factory _$CommissionConfigRates(
          [void Function(CommissionConfigRatesBuilder)? updates]) =>
      (CommissionConfigRatesBuilder()..update(updates))._build();

  _$CommissionConfigRates._(
      {this.motorcycle, this.tricycle, this.car, this.other})
      : super._();
  @override
  CommissionConfigRates rebuild(
          void Function(CommissionConfigRatesBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CommissionConfigRatesBuilder toBuilder() =>
      CommissionConfigRatesBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CommissionConfigRates &&
        motorcycle == other.motorcycle &&
        tricycle == other.tricycle &&
        car == other.car &&
        this.other == other.other;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, motorcycle.hashCode);
    _$hash = $jc(_$hash, tricycle.hashCode);
    _$hash = $jc(_$hash, car.hashCode);
    _$hash = $jc(_$hash, other.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CommissionConfigRates')
          ..add('motorcycle', motorcycle)
          ..add('tricycle', tricycle)
          ..add('car', car)
          ..add('other', other))
        .toString();
  }
}

class CommissionConfigRatesBuilder
    implements Builder<CommissionConfigRates, CommissionConfigRatesBuilder> {
  _$CommissionConfigRates? _$v;

  num? _motorcycle;
  num? get motorcycle => _$this._motorcycle;
  set motorcycle(num? motorcycle) => _$this._motorcycle = motorcycle;

  num? _tricycle;
  num? get tricycle => _$this._tricycle;
  set tricycle(num? tricycle) => _$this._tricycle = tricycle;

  num? _car;
  num? get car => _$this._car;
  set car(num? car) => _$this._car = car;

  num? _other;
  num? get other => _$this._other;
  set other(num? other) => _$this._other = other;

  CommissionConfigRatesBuilder() {
    CommissionConfigRates._defaults(this);
  }

  CommissionConfigRatesBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _motorcycle = $v.motorcycle;
      _tricycle = $v.tricycle;
      _car = $v.car;
      _other = $v.other;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CommissionConfigRates other) {
    _$v = other as _$CommissionConfigRates;
  }

  @override
  void update(void Function(CommissionConfigRatesBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CommissionConfigRates build() => _build();

  _$CommissionConfigRates _build() {
    final _$result = _$v ??
        _$CommissionConfigRates._(
          motorcycle: motorcycle,
          tricycle: tricycle,
          car: car,
          other: other,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

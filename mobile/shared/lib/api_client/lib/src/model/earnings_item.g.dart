// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'earnings_item.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$EarningsItem extends EarningsItem {
  @override
  final String id;
  @override
  final String rideId;
  @override
  final double fareAmount;
  @override
  final double tipAmount;
  @override
  final double totalAmount;
  @override
  final String? currency;
  @override
  final DateTime completedAt;

  factory _$EarningsItem([void Function(EarningsItemBuilder)? updates]) =>
      (EarningsItemBuilder()..update(updates))._build();

  _$EarningsItem._({
    required this.id,
    required this.rideId,
    required this.fareAmount,
    required this.tipAmount,
    required this.totalAmount,
    this.currency,
    required this.completedAt,
  }) : super._();
  @override
  EarningsItem rebuild(void Function(EarningsItemBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EarningsItemBuilder toBuilder() => EarningsItemBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EarningsItem &&
        id == other.id &&
        rideId == other.rideId &&
        fareAmount == other.fareAmount &&
        tipAmount == other.tipAmount &&
        totalAmount == other.totalAmount &&
        currency == other.currency &&
        completedAt == other.completedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, rideId.hashCode);
    _$hash = $jc(_$hash, fareAmount.hashCode);
    _$hash = $jc(_$hash, tipAmount.hashCode);
    _$hash = $jc(_$hash, totalAmount.hashCode);
    _$hash = $jc(_$hash, currency.hashCode);
    _$hash = $jc(_$hash, completedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'EarningsItem')
          ..add('id', id)
          ..add('rideId', rideId)
          ..add('fareAmount', fareAmount)
          ..add('tipAmount', tipAmount)
          ..add('totalAmount', totalAmount)
          ..add('currency', currency)
          ..add('completedAt', completedAt))
        .toString();
  }
}

class EarningsItemBuilder
    implements Builder<EarningsItem, EarningsItemBuilder> {
  _$EarningsItem? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _rideId;
  String? get rideId => _$this._rideId;
  set rideId(String? rideId) => _$this._rideId = rideId;

  double? _fareAmount;
  double? get fareAmount => _$this._fareAmount;
  set fareAmount(double? fareAmount) => _$this._fareAmount = fareAmount;

  double? _tipAmount;
  double? get tipAmount => _$this._tipAmount;
  set tipAmount(double? tipAmount) => _$this._tipAmount = tipAmount;

  double? _totalAmount;
  double? get totalAmount => _$this._totalAmount;
  set totalAmount(double? totalAmount) => _$this._totalAmount = totalAmount;

  String? _currency;
  String? get currency => _$this._currency;
  set currency(String? currency) => _$this._currency = currency;

  DateTime? _completedAt;
  DateTime? get completedAt => _$this._completedAt;
  set completedAt(DateTime? completedAt) => _$this._completedAt = completedAt;

  EarningsItemBuilder() {
    EarningsItem._defaults(this);
  }

  EarningsItemBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _rideId = $v.rideId;
      _fareAmount = $v.fareAmount;
      _tipAmount = $v.tipAmount;
      _totalAmount = $v.totalAmount;
      _currency = $v.currency;
      _completedAt = $v.completedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(EarningsItem other) {
    _$v = other as _$EarningsItem;
  }

  @override
  void update(void Function(EarningsItemBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  EarningsItem build() => _build();

  _$EarningsItem _build() {
    final _$result =
        _$v ??
        _$EarningsItem._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'EarningsItem', 'id'),
          rideId: BuiltValueNullFieldError.checkNotNull(
            rideId,
            r'EarningsItem',
            'rideId',
          ),
          fareAmount: BuiltValueNullFieldError.checkNotNull(
            fareAmount,
            r'EarningsItem',
            'fareAmount',
          ),
          tipAmount: BuiltValueNullFieldError.checkNotNull(
            tipAmount,
            r'EarningsItem',
            'tipAmount',
          ),
          totalAmount: BuiltValueNullFieldError.checkNotNull(
            totalAmount,
            r'EarningsItem',
            'totalAmount',
          ),
          currency: currency,
          completedAt: BuiltValueNullFieldError.checkNotNull(
            completedAt,
            r'EarningsItem',
            'completedAt',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

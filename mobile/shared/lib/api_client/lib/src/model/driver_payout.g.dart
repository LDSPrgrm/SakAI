// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_payout.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const DriverPayoutStatusEnum _$driverPayoutStatusEnum_pending =
    const DriverPayoutStatusEnum._('pending');
const DriverPayoutStatusEnum _$driverPayoutStatusEnum_approved =
    const DriverPayoutStatusEnum._('approved');
const DriverPayoutStatusEnum _$driverPayoutStatusEnum_processing =
    const DriverPayoutStatusEnum._('processing');
const DriverPayoutStatusEnum _$driverPayoutStatusEnum_done =
    const DriverPayoutStatusEnum._('done');

DriverPayoutStatusEnum _$driverPayoutStatusEnumValueOf(String name) {
  switch (name) {
    case 'pending':
      return _$driverPayoutStatusEnum_pending;
    case 'approved':
      return _$driverPayoutStatusEnum_approved;
    case 'processing':
      return _$driverPayoutStatusEnum_processing;
    case 'done':
      return _$driverPayoutStatusEnum_done;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<DriverPayoutStatusEnum> _$driverPayoutStatusEnumValues =
    BuiltSet<DriverPayoutStatusEnum>(const <DriverPayoutStatusEnum>[
  _$driverPayoutStatusEnum_pending,
  _$driverPayoutStatusEnum_approved,
  _$driverPayoutStatusEnum_processing,
  _$driverPayoutStatusEnum_done,
]);

Serializer<DriverPayoutStatusEnum> _$driverPayoutStatusEnumSerializer =
    _$DriverPayoutStatusEnumSerializer();

class _$DriverPayoutStatusEnumSerializer
    implements PrimitiveSerializer<DriverPayoutStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'pending': 'pending',
    'approved': 'approved',
    'processing': 'processing',
    'done': 'done',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'pending': 'pending',
    'approved': 'approved',
    'processing': 'processing',
    'done': 'done',
  };

  @override
  final Iterable<Type> types = const <Type>[DriverPayoutStatusEnum];
  @override
  final String wireName = 'DriverPayoutStatusEnum';

  @override
  Object serialize(Serializers serializers, DriverPayoutStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  DriverPayoutStatusEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      DriverPayoutStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$DriverPayout extends DriverPayout {
  @override
  final String? id;
  @override
  final String? batch;
  @override
  final int? driverCount;
  @override
  final num? totalAmount;
  @override
  final String? period;
  @override
  final DriverPayoutStatusEnum? status;

  factory _$DriverPayout([void Function(DriverPayoutBuilder)? updates]) =>
      (DriverPayoutBuilder()..update(updates))._build();

  _$DriverPayout._(
      {this.id,
      this.batch,
      this.driverCount,
      this.totalAmount,
      this.period,
      this.status})
      : super._();
  @override
  DriverPayout rebuild(void Function(DriverPayoutBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DriverPayoutBuilder toBuilder() => DriverPayoutBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DriverPayout &&
        id == other.id &&
        batch == other.batch &&
        driverCount == other.driverCount &&
        totalAmount == other.totalAmount &&
        period == other.period &&
        status == other.status;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, batch.hashCode);
    _$hash = $jc(_$hash, driverCount.hashCode);
    _$hash = $jc(_$hash, totalAmount.hashCode);
    _$hash = $jc(_$hash, period.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DriverPayout')
          ..add('id', id)
          ..add('batch', batch)
          ..add('driverCount', driverCount)
          ..add('totalAmount', totalAmount)
          ..add('period', period)
          ..add('status', status))
        .toString();
  }
}

class DriverPayoutBuilder
    implements Builder<DriverPayout, DriverPayoutBuilder> {
  _$DriverPayout? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _batch;
  String? get batch => _$this._batch;
  set batch(String? batch) => _$this._batch = batch;

  int? _driverCount;
  int? get driverCount => _$this._driverCount;
  set driverCount(int? driverCount) => _$this._driverCount = driverCount;

  num? _totalAmount;
  num? get totalAmount => _$this._totalAmount;
  set totalAmount(num? totalAmount) => _$this._totalAmount = totalAmount;

  String? _period;
  String? get period => _$this._period;
  set period(String? period) => _$this._period = period;

  DriverPayoutStatusEnum? _status;
  DriverPayoutStatusEnum? get status => _$this._status;
  set status(DriverPayoutStatusEnum? status) => _$this._status = status;

  DriverPayoutBuilder() {
    DriverPayout._defaults(this);
  }

  DriverPayoutBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _batch = $v.batch;
      _driverCount = $v.driverCount;
      _totalAmount = $v.totalAmount;
      _period = $v.period;
      _status = $v.status;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DriverPayout other) {
    _$v = other as _$DriverPayout;
  }

  @override
  void update(void Function(DriverPayoutBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DriverPayout build() => _build();

  _$DriverPayout _build() {
    final _$result = _$v ??
        _$DriverPayout._(
          id: id,
          batch: batch,
          driverCount: driverCount,
          totalAmount: totalAmount,
          period: period,
          status: status,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

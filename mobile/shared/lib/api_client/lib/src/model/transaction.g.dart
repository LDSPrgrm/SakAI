// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const TransactionPaymentMethodEnum _$transactionPaymentMethodEnum_cash =
    const TransactionPaymentMethodEnum._('cash');
const TransactionPaymentMethodEnum _$transactionPaymentMethodEnum_gcash =
    const TransactionPaymentMethodEnum._('gcash');
const TransactionPaymentMethodEnum _$transactionPaymentMethodEnum_paymaya =
    const TransactionPaymentMethodEnum._('paymaya');
const TransactionPaymentMethodEnum _$transactionPaymentMethodEnum_card =
    const TransactionPaymentMethodEnum._('card');

TransactionPaymentMethodEnum _$transactionPaymentMethodEnumValueOf(
  String name,
) {
  switch (name) {
    case 'cash':
      return _$transactionPaymentMethodEnum_cash;
    case 'gcash':
      return _$transactionPaymentMethodEnum_gcash;
    case 'paymaya':
      return _$transactionPaymentMethodEnum_paymaya;
    case 'card':
      return _$transactionPaymentMethodEnum_card;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<TransactionPaymentMethodEnum>
_$transactionPaymentMethodEnumValues =
    BuiltSet<TransactionPaymentMethodEnum>(const <TransactionPaymentMethodEnum>[
      _$transactionPaymentMethodEnum_cash,
      _$transactionPaymentMethodEnum_gcash,
      _$transactionPaymentMethodEnum_paymaya,
      _$transactionPaymentMethodEnum_card,
    ]);

const TransactionStatusEnum _$transactionStatusEnum_settled =
    const TransactionStatusEnum._('settled');
const TransactionStatusEnum _$transactionStatusEnum_pending =
    const TransactionStatusEnum._('pending');
const TransactionStatusEnum _$transactionStatusEnum_failed =
    const TransactionStatusEnum._('failed');
const TransactionStatusEnum _$transactionStatusEnum_refunded =
    const TransactionStatusEnum._('refunded');

TransactionStatusEnum _$transactionStatusEnumValueOf(String name) {
  switch (name) {
    case 'settled':
      return _$transactionStatusEnum_settled;
    case 'pending':
      return _$transactionStatusEnum_pending;
    case 'failed':
      return _$transactionStatusEnum_failed;
    case 'refunded':
      return _$transactionStatusEnum_refunded;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<TransactionStatusEnum> _$transactionStatusEnumValues =
    BuiltSet<TransactionStatusEnum>(const <TransactionStatusEnum>[
      _$transactionStatusEnum_settled,
      _$transactionStatusEnum_pending,
      _$transactionStatusEnum_failed,
      _$transactionStatusEnum_refunded,
    ]);

Serializer<TransactionPaymentMethodEnum>
_$transactionPaymentMethodEnumSerializer =
    _$TransactionPaymentMethodEnumSerializer();
Serializer<TransactionStatusEnum> _$transactionStatusEnumSerializer =
    _$TransactionStatusEnumSerializer();

class _$TransactionPaymentMethodEnumSerializer
    implements PrimitiveSerializer<TransactionPaymentMethodEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'cash': 'cash',
    'gcash': 'gcash',
    'paymaya': 'paymaya',
    'card': 'card',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'cash': 'cash',
    'gcash': 'gcash',
    'paymaya': 'paymaya',
    'card': 'card',
  };

  @override
  final Iterable<Type> types = const <Type>[TransactionPaymentMethodEnum];
  @override
  final String wireName = 'TransactionPaymentMethodEnum';

  @override
  Object serialize(
    Serializers serializers,
    TransactionPaymentMethodEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  TransactionPaymentMethodEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => TransactionPaymentMethodEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$TransactionStatusEnumSerializer
    implements PrimitiveSerializer<TransactionStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'settled': 'settled',
    'pending': 'pending',
    'failed': 'failed',
    'refunded': 'refunded',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'settled': 'settled',
    'pending': 'pending',
    'failed': 'failed',
    'refunded': 'refunded',
  };

  @override
  final Iterable<Type> types = const <Type>[TransactionStatusEnum];
  @override
  final String wireName = 'TransactionStatusEnum';

  @override
  Object serialize(
    Serializers serializers,
    TransactionStatusEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  TransactionStatusEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => TransactionStatusEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$Transaction extends Transaction {
  @override
  final String? id;
  @override
  final int? seq;
  @override
  final String? displayId;
  @override
  final String? rideId;
  @override
  final String? rideDisplayId;
  @override
  final String? riderName;
  @override
  final String? driverName;
  @override
  final num? amount;
  @override
  final TransactionPaymentMethodEnum? paymentMethod;
  @override
  final TransactionStatusEnum? status;
  @override
  final num? commission;
  @override
  final DateTime? createdAt;

  factory _$Transaction([void Function(TransactionBuilder)? updates]) =>
      (TransactionBuilder()..update(updates))._build();

  _$Transaction._({
    this.id,
    this.seq,
    this.displayId,
    this.rideId,
    this.rideDisplayId,
    this.riderName,
    this.driverName,
    this.amount,
    this.paymentMethod,
    this.status,
    this.commission,
    this.createdAt,
  }) : super._();
  @override
  Transaction rebuild(void Function(TransactionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TransactionBuilder toBuilder() => TransactionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Transaction &&
        id == other.id &&
        seq == other.seq &&
        displayId == other.displayId &&
        rideId == other.rideId &&
        rideDisplayId == other.rideDisplayId &&
        riderName == other.riderName &&
        driverName == other.driverName &&
        amount == other.amount &&
        paymentMethod == other.paymentMethod &&
        status == other.status &&
        commission == other.commission &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, seq.hashCode);
    _$hash = $jc(_$hash, displayId.hashCode);
    _$hash = $jc(_$hash, rideId.hashCode);
    _$hash = $jc(_$hash, rideDisplayId.hashCode);
    _$hash = $jc(_$hash, riderName.hashCode);
    _$hash = $jc(_$hash, driverName.hashCode);
    _$hash = $jc(_$hash, amount.hashCode);
    _$hash = $jc(_$hash, paymentMethod.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, commission.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Transaction')
          ..add('id', id)
          ..add('seq', seq)
          ..add('displayId', displayId)
          ..add('rideId', rideId)
          ..add('rideDisplayId', rideDisplayId)
          ..add('riderName', riderName)
          ..add('driverName', driverName)
          ..add('amount', amount)
          ..add('paymentMethod', paymentMethod)
          ..add('status', status)
          ..add('commission', commission)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class TransactionBuilder implements Builder<Transaction, TransactionBuilder> {
  _$Transaction? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  int? _seq;
  int? get seq => _$this._seq;
  set seq(int? seq) => _$this._seq = seq;

  String? _displayId;
  String? get displayId => _$this._displayId;
  set displayId(String? displayId) => _$this._displayId = displayId;

  String? _rideId;
  String? get rideId => _$this._rideId;
  set rideId(String? rideId) => _$this._rideId = rideId;

  String? _rideDisplayId;
  String? get rideDisplayId => _$this._rideDisplayId;
  set rideDisplayId(String? rideDisplayId) =>
      _$this._rideDisplayId = rideDisplayId;

  String? _riderName;
  String? get riderName => _$this._riderName;
  set riderName(String? riderName) => _$this._riderName = riderName;

  String? _driverName;
  String? get driverName => _$this._driverName;
  set driverName(String? driverName) => _$this._driverName = driverName;

  num? _amount;
  num? get amount => _$this._amount;
  set amount(num? amount) => _$this._amount = amount;

  TransactionPaymentMethodEnum? _paymentMethod;
  TransactionPaymentMethodEnum? get paymentMethod => _$this._paymentMethod;
  set paymentMethod(TransactionPaymentMethodEnum? paymentMethod) =>
      _$this._paymentMethod = paymentMethod;

  TransactionStatusEnum? _status;
  TransactionStatusEnum? get status => _$this._status;
  set status(TransactionStatusEnum? status) => _$this._status = status;

  num? _commission;
  num? get commission => _$this._commission;
  set commission(num? commission) => _$this._commission = commission;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  TransactionBuilder() {
    Transaction._defaults(this);
  }

  TransactionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _seq = $v.seq;
      _displayId = $v.displayId;
      _rideId = $v.rideId;
      _rideDisplayId = $v.rideDisplayId;
      _riderName = $v.riderName;
      _driverName = $v.driverName;
      _amount = $v.amount;
      _paymentMethod = $v.paymentMethod;
      _status = $v.status;
      _commission = $v.commission;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Transaction other) {
    _$v = other as _$Transaction;
  }

  @override
  void update(void Function(TransactionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Transaction build() => _build();

  _$Transaction _build() {
    final _$result =
        _$v ??
        _$Transaction._(
          id: id,
          seq: seq,
          displayId: displayId,
          rideId: rideId,
          rideDisplayId: rideDisplayId,
          riderName: riderName,
          driverName: driverName,
          amount: amount,
          paymentMethod: paymentMethod,
          status: status,
          commission: commission,
          createdAt: createdAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

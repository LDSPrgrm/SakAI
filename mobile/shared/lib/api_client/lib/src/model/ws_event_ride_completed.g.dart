// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ws_event_ride_completed.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const WsEventRideCompletedPaymentMethodEnum
_$wsEventRideCompletedPaymentMethodEnum_cash =
    const WsEventRideCompletedPaymentMethodEnum._('cash');
const WsEventRideCompletedPaymentMethodEnum
_$wsEventRideCompletedPaymentMethodEnum_gcash =
    const WsEventRideCompletedPaymentMethodEnum._('gcash');
const WsEventRideCompletedPaymentMethodEnum
_$wsEventRideCompletedPaymentMethodEnum_paymaya =
    const WsEventRideCompletedPaymentMethodEnum._('paymaya');
const WsEventRideCompletedPaymentMethodEnum
_$wsEventRideCompletedPaymentMethodEnum_card =
    const WsEventRideCompletedPaymentMethodEnum._('card');

WsEventRideCompletedPaymentMethodEnum
_$wsEventRideCompletedPaymentMethodEnumValueOf(String name) {
  switch (name) {
    case 'cash':
      return _$wsEventRideCompletedPaymentMethodEnum_cash;
    case 'gcash':
      return _$wsEventRideCompletedPaymentMethodEnum_gcash;
    case 'paymaya':
      return _$wsEventRideCompletedPaymentMethodEnum_paymaya;
    case 'card':
      return _$wsEventRideCompletedPaymentMethodEnum_card;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<WsEventRideCompletedPaymentMethodEnum>
_$wsEventRideCompletedPaymentMethodEnumValues =
    BuiltSet<WsEventRideCompletedPaymentMethodEnum>(
      const <WsEventRideCompletedPaymentMethodEnum>[
        _$wsEventRideCompletedPaymentMethodEnum_cash,
        _$wsEventRideCompletedPaymentMethodEnum_gcash,
        _$wsEventRideCompletedPaymentMethodEnum_paymaya,
        _$wsEventRideCompletedPaymentMethodEnum_card,
      ],
    );

Serializer<WsEventRideCompletedPaymentMethodEnum>
_$wsEventRideCompletedPaymentMethodEnumSerializer =
    _$WsEventRideCompletedPaymentMethodEnumSerializer();

class _$WsEventRideCompletedPaymentMethodEnumSerializer
    implements PrimitiveSerializer<WsEventRideCompletedPaymentMethodEnum> {
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
  final Iterable<Type> types = const <Type>[
    WsEventRideCompletedPaymentMethodEnum,
  ];
  @override
  final String wireName = 'WsEventRideCompletedPaymentMethodEnum';

  @override
  Object serialize(
    Serializers serializers,
    WsEventRideCompletedPaymentMethodEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  WsEventRideCompletedPaymentMethodEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => WsEventRideCompletedPaymentMethodEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$WsEventRideCompleted extends WsEventRideCompleted {
  @override
  final String rideId;
  @override
  final double fare;
  @override
  final FareBreakdown? fareBreakdown;
  @override
  final WsEventRideCompletedPaymentMethodEnum paymentMethod;
  @override
  final double? tipAmount;
  @override
  final DateTime completedAt;

  factory _$WsEventRideCompleted([
    void Function(WsEventRideCompletedBuilder)? updates,
  ]) => (WsEventRideCompletedBuilder()..update(updates))._build();

  _$WsEventRideCompleted._({
    required this.rideId,
    required this.fare,
    this.fareBreakdown,
    required this.paymentMethod,
    this.tipAmount,
    required this.completedAt,
  }) : super._();
  @override
  WsEventRideCompleted rebuild(
    void Function(WsEventRideCompletedBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  WsEventRideCompletedBuilder toBuilder() =>
      WsEventRideCompletedBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WsEventRideCompleted &&
        rideId == other.rideId &&
        fare == other.fare &&
        fareBreakdown == other.fareBreakdown &&
        paymentMethod == other.paymentMethod &&
        tipAmount == other.tipAmount &&
        completedAt == other.completedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, rideId.hashCode);
    _$hash = $jc(_$hash, fare.hashCode);
    _$hash = $jc(_$hash, fareBreakdown.hashCode);
    _$hash = $jc(_$hash, paymentMethod.hashCode);
    _$hash = $jc(_$hash, tipAmount.hashCode);
    _$hash = $jc(_$hash, completedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'WsEventRideCompleted')
          ..add('rideId', rideId)
          ..add('fare', fare)
          ..add('fareBreakdown', fareBreakdown)
          ..add('paymentMethod', paymentMethod)
          ..add('tipAmount', tipAmount)
          ..add('completedAt', completedAt))
        .toString();
  }
}

class WsEventRideCompletedBuilder
    implements Builder<WsEventRideCompleted, WsEventRideCompletedBuilder> {
  _$WsEventRideCompleted? _$v;

  String? _rideId;
  String? get rideId => _$this._rideId;
  set rideId(String? rideId) => _$this._rideId = rideId;

  double? _fare;
  double? get fare => _$this._fare;
  set fare(double? fare) => _$this._fare = fare;

  FareBreakdownBuilder? _fareBreakdown;
  FareBreakdownBuilder get fareBreakdown =>
      _$this._fareBreakdown ??= FareBreakdownBuilder();
  set fareBreakdown(FareBreakdownBuilder? fareBreakdown) =>
      _$this._fareBreakdown = fareBreakdown;

  WsEventRideCompletedPaymentMethodEnum? _paymentMethod;
  WsEventRideCompletedPaymentMethodEnum? get paymentMethod =>
      _$this._paymentMethod;
  set paymentMethod(WsEventRideCompletedPaymentMethodEnum? paymentMethod) =>
      _$this._paymentMethod = paymentMethod;

  double? _tipAmount;
  double? get tipAmount => _$this._tipAmount;
  set tipAmount(double? tipAmount) => _$this._tipAmount = tipAmount;

  DateTime? _completedAt;
  DateTime? get completedAt => _$this._completedAt;
  set completedAt(DateTime? completedAt) => _$this._completedAt = completedAt;

  WsEventRideCompletedBuilder() {
    WsEventRideCompleted._defaults(this);
  }

  WsEventRideCompletedBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _rideId = $v.rideId;
      _fare = $v.fare;
      _fareBreakdown = $v.fareBreakdown?.toBuilder();
      _paymentMethod = $v.paymentMethod;
      _tipAmount = $v.tipAmount;
      _completedAt = $v.completedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WsEventRideCompleted other) {
    _$v = other as _$WsEventRideCompleted;
  }

  @override
  void update(void Function(WsEventRideCompletedBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WsEventRideCompleted build() => _build();

  _$WsEventRideCompleted _build() {
    _$WsEventRideCompleted _$result;
    try {
      _$result =
          _$v ??
          _$WsEventRideCompleted._(
            rideId: BuiltValueNullFieldError.checkNotNull(
              rideId,
              r'WsEventRideCompleted',
              'rideId',
            ),
            fare: BuiltValueNullFieldError.checkNotNull(
              fare,
              r'WsEventRideCompleted',
              'fare',
            ),
            fareBreakdown: _fareBreakdown?.build(),
            paymentMethod: BuiltValueNullFieldError.checkNotNull(
              paymentMethod,
              r'WsEventRideCompleted',
              'paymentMethod',
            ),
            tipAmount: tipAmount,
            completedAt: BuiltValueNullFieldError.checkNotNull(
              completedAt,
              r'WsEventRideCompleted',
              'completedAt',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'fareBreakdown';
        _fareBreakdown?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'WsEventRideCompleted',
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

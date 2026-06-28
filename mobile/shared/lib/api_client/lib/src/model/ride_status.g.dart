// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_status.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const RideStatus _$created = const RideStatus._('created');
const RideStatus _$requested = const RideStatus._('requested');
const RideStatus _$accepted = const RideStatus._('accepted');
const RideStatus _$arrived = const RideStatus._('arrived');
const RideStatus _$inProgress = const RideStatus._('inProgress');
const RideStatus _$paymentPending = const RideStatus._('paymentPending');
const RideStatus _$completed = const RideStatus._('completed');
const RideStatus _$cancelled = const RideStatus._('cancelled');

RideStatus _$valueOf(String name) {
  switch (name) {
    case 'created':
      return _$created;
    case 'requested':
      return _$requested;
    case 'accepted':
      return _$accepted;
    case 'arrived':
      return _$arrived;
    case 'inProgress':
      return _$inProgress;
    case 'paymentPending':
      return _$paymentPending;
    case 'completed':
      return _$completed;
    case 'cancelled':
      return _$cancelled;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<RideStatus> _$values = BuiltSet<RideStatus>(const <RideStatus>[
  _$created,
  _$requested,
  _$accepted,
  _$arrived,
  _$inProgress,
  _$paymentPending,
  _$completed,
  _$cancelled,
]);

class _$RideStatusMeta {
  const _$RideStatusMeta();
  RideStatus get created => _$created;
  RideStatus get requested => _$requested;
  RideStatus get accepted => _$accepted;
  RideStatus get arrived => _$arrived;
  RideStatus get inProgress => _$inProgress;
  RideStatus get paymentPending => _$paymentPending;
  RideStatus get completed => _$completed;
  RideStatus get cancelled => _$cancelled;
  RideStatus valueOf(String name) => _$valueOf(name);
  BuiltSet<RideStatus> get values => _$values;
}

mixin _$RideStatusMixin {
  // ignore: non_constant_identifier_names
  _$RideStatusMeta get RideStatus => const _$RideStatusMeta();
}

Serializer<RideStatus> _$rideStatusSerializer = _$RideStatusSerializer();

class _$RideStatusSerializer implements PrimitiveSerializer<RideStatus> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'created': 'created',
    'requested': 'requested',
    'accepted': 'accepted',
    'arrived': 'arrived',
    'inProgress': 'in_progress',
    'paymentPending': 'payment_pending',
    'completed': 'completed',
    'cancelled': 'cancelled',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'created': 'created',
    'requested': 'requested',
    'accepted': 'accepted',
    'arrived': 'arrived',
    'in_progress': 'inProgress',
    'payment_pending': 'paymentPending',
    'completed': 'completed',
    'cancelled': 'cancelled',
  };

  @override
  final Iterable<Type> types = const <Type>[RideStatus];
  @override
  final String wireName = 'RideStatus';

  @override
  Object serialize(
    Serializers serializers,
    RideStatus object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  RideStatus deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => RideStatus.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

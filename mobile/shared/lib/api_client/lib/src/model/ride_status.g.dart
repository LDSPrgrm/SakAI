// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_status.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const RideStatus _$requested = const RideStatus._('requested');
const RideStatus _$accepted = const RideStatus._('accepted');
const RideStatus _$arrived = const RideStatus._('arrived');
const RideStatus _$inProgress = const RideStatus._('inProgress');
const RideStatus _$completed = const RideStatus._('completed');
const RideStatus _$cancelled = const RideStatus._('cancelled');

RideStatus _$valueOf(String name) {
  switch (name) {
    case 'requested':
      return _$requested;
    case 'accepted':
      return _$accepted;
    case 'arrived':
      return _$arrived;
    case 'inProgress':
      return _$inProgress;
    case 'completed':
      return _$completed;
    case 'cancelled':
      return _$cancelled;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<RideStatus> _$values = BuiltSet<RideStatus>(const <RideStatus>[
  _$requested,
  _$accepted,
  _$arrived,
  _$inProgress,
  _$completed,
  _$cancelled,
]);

Serializer<RideStatus> _$rideStatusSerializer = _$RideStatusSerializer();

class _$RideStatusSerializer implements PrimitiveSerializer<RideStatus> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'requested': 'requested',
    'accepted': 'accepted',
    'arrived': 'arrived',
    'inProgress': 'in_progress',
    'completed': 'completed',
    'cancelled': 'cancelled',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'requested': 'requested',
    'accepted': 'accepted',
    'arrived': 'arrived',
    'in_progress': 'inProgress',
    'completed': 'completed',
    'cancelled': 'cancelled',
  };

  @override
  final Iterable<Type> types = const <Type>[RideStatus];
  @override
  final String wireName = 'RideStatus';

  @override
  Object serialize(Serializers serializers, RideStatus object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  RideStatus deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      RideStatus.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

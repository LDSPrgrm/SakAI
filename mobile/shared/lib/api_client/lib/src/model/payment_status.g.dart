// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_status.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PaymentStatus _$pending = const PaymentStatus._('pending');
const PaymentStatus _$completed = const PaymentStatus._('completed');
const PaymentStatus _$failed = const PaymentStatus._('failed');
const PaymentStatus _$refunded = const PaymentStatus._('refunded');

PaymentStatus _$valueOf(String name) {
  switch (name) {
    case 'pending':
      return _$pending;
    case 'completed':
      return _$completed;
    case 'failed':
      return _$failed;
    case 'refunded':
      return _$refunded;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PaymentStatus> _$values = BuiltSet<PaymentStatus>(
  const <PaymentStatus>[_$pending, _$completed, _$failed, _$refunded],
);

Serializer<PaymentStatus> _$paymentStatusSerializer =
    _$PaymentStatusSerializer();

class _$PaymentStatusSerializer implements PrimitiveSerializer<PaymentStatus> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'pending': 'pending',
    'completed': 'completed',
    'failed': 'failed',
    'refunded': 'refunded',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'pending': 'pending',
    'completed': 'completed',
    'failed': 'failed',
    'refunded': 'refunded',
  };

  @override
  final Iterable<Type> types = const <Type>[PaymentStatus];
  @override
  final String wireName = 'PaymentStatus';

  @override
  Object serialize(
    Serializers serializers,
    PaymentStatus object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  PaymentStatus deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => PaymentStatus.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

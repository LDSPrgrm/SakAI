// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_method.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PaymentMethod _$cash = const PaymentMethod._('cash');
const PaymentMethod _$card = const PaymentMethod._('card');
const PaymentMethod _$gcash = const PaymentMethod._('gcash');
const PaymentMethod _$paymaya = const PaymentMethod._('paymaya');

PaymentMethod _$valueOf(String name) {
  switch (name) {
    case 'cash':
      return _$cash;
    case 'card':
      return _$card;
    case 'gcash':
      return _$gcash;
    case 'paymaya':
      return _$paymaya;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PaymentMethod> _$values = BuiltSet<PaymentMethod>(
  const <PaymentMethod>[_$cash, _$card, _$gcash, _$paymaya],
);

class _$PaymentMethodMeta {
  const _$PaymentMethodMeta();
  PaymentMethod get cash => _$cash;
  PaymentMethod get card => _$card;
  PaymentMethod get gcash => _$gcash;
  PaymentMethod get paymaya => _$paymaya;
  PaymentMethod valueOf(String name) => _$valueOf(name);
  BuiltSet<PaymentMethod> get values => _$values;
}

mixin _$PaymentMethodMixin {
  // ignore: non_constant_identifier_names
  _$PaymentMethodMeta get PaymentMethod => const _$PaymentMethodMeta();
}

Serializer<PaymentMethod> _$paymentMethodSerializer =
    _$PaymentMethodSerializer();

class _$PaymentMethodSerializer implements PrimitiveSerializer<PaymentMethod> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'cash': 'cash',
    'card': 'card',
    'gcash': 'gcash',
    'paymaya': 'paymaya',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'cash': 'cash',
    'card': 'card',
    'gcash': 'gcash',
    'paymaya': 'paymaya',
  };

  @override
  final Iterable<Type> types = const <Type>[PaymentMethod];
  @override
  final String wireName = 'PaymentMethod';

  @override
  Object serialize(
    Serializers serializers,
    PaymentMethod object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  PaymentMethod deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => PaymentMethod.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

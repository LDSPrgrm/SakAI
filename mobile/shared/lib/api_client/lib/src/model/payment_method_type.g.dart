// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_method_type.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PaymentMethodType _$card = const PaymentMethodType._('card');
const PaymentMethodType _$eWallet = const PaymentMethodType._('eWallet');
const PaymentMethodType _$cash = const PaymentMethodType._('cash');

PaymentMethodType _$valueOf(String name) {
  switch (name) {
    case 'card':
      return _$card;
    case 'eWallet':
      return _$eWallet;
    case 'cash':
      return _$cash;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PaymentMethodType> _$values = BuiltSet<PaymentMethodType>(
  const <PaymentMethodType>[_$card, _$eWallet, _$cash],
);

class _$PaymentMethodTypeMeta {
  const _$PaymentMethodTypeMeta();
  PaymentMethodType get card => _$card;
  PaymentMethodType get eWallet => _$eWallet;
  PaymentMethodType get cash => _$cash;
  PaymentMethodType valueOf(String name) => _$valueOf(name);
  BuiltSet<PaymentMethodType> get values => _$values;
}

mixin _$PaymentMethodTypeMixin {
  // ignore: non_constant_identifier_names
  _$PaymentMethodTypeMeta get PaymentMethodType =>
      const _$PaymentMethodTypeMeta();
}

Serializer<PaymentMethodType> _$paymentMethodTypeSerializer =
    _$PaymentMethodTypeSerializer();

class _$PaymentMethodTypeSerializer
    implements PrimitiveSerializer<PaymentMethodType> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'card': 'card',
    'eWallet': 'e_wallet',
    'cash': 'cash',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'card': 'card',
    'e_wallet': 'eWallet',
    'cash': 'cash',
  };

  @override
  final Iterable<Type> types = const <Type>[PaymentMethodType];
  @override
  final String wireName = 'PaymentMethodType';

  @override
  Object serialize(
    Serializers serializers,
    PaymentMethodType object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  PaymentMethodType deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => PaymentMethodType.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

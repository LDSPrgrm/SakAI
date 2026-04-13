//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'payment_method_type.g.dart';

class PaymentMethodType extends EnumClass {
  /// Type of payment method
  @BuiltValueEnumConst(wireName: r'card')
  static const PaymentMethodType card = _$card;

  /// Type of payment method
  @BuiltValueEnumConst(wireName: r'e_wallet')
  static const PaymentMethodType eWallet = _$eWallet;

  /// Type of payment method
  @BuiltValueEnumConst(wireName: r'cash')
  static const PaymentMethodType cash = _$cash;

  static Serializer<PaymentMethodType> get serializer =>
      _$paymentMethodTypeSerializer;

  const PaymentMethodType._(String name) : super(name);

  static BuiltSet<PaymentMethodType> get values => _$values;
  static PaymentMethodType valueOf(String name) => _$valueOf(name);
}

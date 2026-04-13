//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'payment_method.g.dart';

class PaymentMethod extends EnumClass {
  @BuiltValueEnumConst(wireName: r'cash')
  static const PaymentMethod cash = _$cash;
  @BuiltValueEnumConst(wireName: r'card')
  static const PaymentMethod card = _$card;

  static Serializer<PaymentMethod> get serializer => _$paymentMethodSerializer;

  const PaymentMethod._(String name) : super(name);

  static BuiltSet<PaymentMethod> get values => _$values;
  static PaymentMethod valueOf(String name) => _$valueOf(name);
}

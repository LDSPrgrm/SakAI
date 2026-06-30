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
  @BuiltValueEnumConst(wireName: r'gcash')
  static const PaymentMethod gcash = _$gcash;
  @BuiltValueEnumConst(wireName: r'paymaya')
  static const PaymentMethod paymaya = _$paymaya;

  static Serializer<PaymentMethod> get serializer => _$paymentMethodSerializer;

  const PaymentMethod._(String name): super(name);

  static BuiltSet<PaymentMethod> get values => _$values;
  static PaymentMethod valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class PaymentMethodMixin = Object with _$PaymentMethodMixin;


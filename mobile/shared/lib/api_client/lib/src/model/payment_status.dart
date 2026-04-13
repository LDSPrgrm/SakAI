//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'payment_status.g.dart';

class PaymentStatus extends EnumClass {
  @BuiltValueEnumConst(wireName: r'pending')
  static const PaymentStatus pending = _$pending;
  @BuiltValueEnumConst(wireName: r'completed')
  static const PaymentStatus completed = _$completed;
  @BuiltValueEnumConst(wireName: r'failed')
  static const PaymentStatus failed = _$failed;
  @BuiltValueEnumConst(wireName: r'refunded')
  static const PaymentStatus refunded = _$refunded;

  static Serializer<PaymentStatus> get serializer => _$paymentStatusSerializer;

  const PaymentStatus._(String name) : super(name);

  static BuiltSet<PaymentStatus> get values => _$values;
  static PaymentStatus valueOf(String name) => _$valueOf(name);
}

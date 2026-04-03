//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'transaction.g.dart';

/// Transaction
///
/// Properties:
/// * [id] 
/// * [rideId] 
/// * [riderName] 
/// * [driverName] 
/// * [amount] 
/// * [paymentMethod] 
/// * [status] 
/// * [commission] 
/// * [createdAt] 
@BuiltValue()
abstract class Transaction implements Built<Transaction, TransactionBuilder> {
  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'ride_id')
  String? get rideId;

  @BuiltValueField(wireName: r'rider_name')
  String? get riderName;

  @BuiltValueField(wireName: r'driver_name')
  String? get driverName;

  @BuiltValueField(wireName: r'amount')
  num? get amount;

  @BuiltValueField(wireName: r'payment_method')
  TransactionPaymentMethodEnum? get paymentMethod;
  // enum paymentMethodEnum {  cash,  gcash,  paymaya,  card,  };

  @BuiltValueField(wireName: r'status')
  TransactionStatusEnum? get status;
  // enum statusEnum {  settled,  pending,  failed,  refunded,  };

  @BuiltValueField(wireName: r'commission')
  num? get commission;

  @BuiltValueField(wireName: r'created_at')
  DateTime? get createdAt;

  Transaction._();

  factory Transaction([void updates(TransactionBuilder b)]) = _$Transaction;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TransactionBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Transaction> get serializer => _$TransactionSerializer();
}

class _$TransactionSerializer implements PrimitiveSerializer<Transaction> {
  @override
  final Iterable<Type> types = const [Transaction, _$Transaction];

  @override
  final String wireName = r'Transaction';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Transaction object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
    if (object.rideId != null) {
      yield r'ride_id';
      yield serializers.serialize(
        object.rideId,
        specifiedType: const FullType(String),
      );
    }
    if (object.riderName != null) {
      yield r'rider_name';
      yield serializers.serialize(
        object.riderName,
        specifiedType: const FullType(String),
      );
    }
    if (object.driverName != null) {
      yield r'driver_name';
      yield serializers.serialize(
        object.driverName,
        specifiedType: const FullType(String),
      );
    }
    if (object.amount != null) {
      yield r'amount';
      yield serializers.serialize(
        object.amount,
        specifiedType: const FullType(num),
      );
    }
    if (object.paymentMethod != null) {
      yield r'payment_method';
      yield serializers.serialize(
        object.paymentMethod,
        specifiedType: const FullType(TransactionPaymentMethodEnum),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(TransactionStatusEnum),
      );
    }
    if (object.commission != null) {
      yield r'commission';
      yield serializers.serialize(
        object.commission,
        specifiedType: const FullType(num),
      );
    }
    if (object.createdAt != null) {
      yield r'created_at';
      yield serializers.serialize(
        object.createdAt,
        specifiedType: const FullType(DateTime),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    Transaction object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TransactionBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'ride_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.rideId = valueDes;
          break;
        case r'rider_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.riderName = valueDes;
          break;
        case r'driver_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.driverName = valueDes;
          break;
        case r'amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.amount = valueDes;
          break;
        case r'payment_method':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TransactionPaymentMethodEnum),
          ) as TransactionPaymentMethodEnum;
          result.paymentMethod = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TransactionStatusEnum),
          ) as TransactionStatusEnum;
          result.status = valueDes;
          break;
        case r'commission':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.commission = valueDes;
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Transaction deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TransactionBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}

class TransactionPaymentMethodEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'cash')
  static const TransactionPaymentMethodEnum cash = _$transactionPaymentMethodEnum_cash;
  @BuiltValueEnumConst(wireName: r'gcash')
  static const TransactionPaymentMethodEnum gcash = _$transactionPaymentMethodEnum_gcash;
  @BuiltValueEnumConst(wireName: r'paymaya')
  static const TransactionPaymentMethodEnum paymaya = _$transactionPaymentMethodEnum_paymaya;
  @BuiltValueEnumConst(wireName: r'card')
  static const TransactionPaymentMethodEnum card = _$transactionPaymentMethodEnum_card;

  static Serializer<TransactionPaymentMethodEnum> get serializer => _$transactionPaymentMethodEnumSerializer;

  const TransactionPaymentMethodEnum._(String name): super(name);

  static BuiltSet<TransactionPaymentMethodEnum> get values => _$transactionPaymentMethodEnumValues;
  static TransactionPaymentMethodEnum valueOf(String name) => _$transactionPaymentMethodEnumValueOf(name);
}

class TransactionStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'settled')
  static const TransactionStatusEnum settled = _$transactionStatusEnum_settled;
  @BuiltValueEnumConst(wireName: r'pending')
  static const TransactionStatusEnum pending = _$transactionStatusEnum_pending;
  @BuiltValueEnumConst(wireName: r'failed')
  static const TransactionStatusEnum failed = _$transactionStatusEnum_failed;
  @BuiltValueEnumConst(wireName: r'refunded')
  static const TransactionStatusEnum refunded = _$transactionStatusEnum_refunded;

  static Serializer<TransactionStatusEnum> get serializer => _$transactionStatusEnumSerializer;

  const TransactionStatusEnum._(String name): super(name);

  static BuiltSet<TransactionStatusEnum> get values => _$transactionStatusEnumValues;
  static TransactionStatusEnum valueOf(String name) => _$transactionStatusEnumValueOf(name);
}


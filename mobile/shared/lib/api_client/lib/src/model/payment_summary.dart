//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'payment_summary.g.dart';

/// PaymentSummary
///
/// Properties:
/// * [totalRevenue] 
/// * [payouts] 
/// * [commission] 
/// * [pendingSettlements] 
@BuiltValue()
abstract class PaymentSummary implements Built<PaymentSummary, PaymentSummaryBuilder> {
  @BuiltValueField(wireName: r'total_revenue')
  num? get totalRevenue;

  @BuiltValueField(wireName: r'payouts')
  num? get payouts;

  @BuiltValueField(wireName: r'commission')
  num? get commission;

  @BuiltValueField(wireName: r'pending_settlements')
  num? get pendingSettlements;

  PaymentSummary._();

  factory PaymentSummary([void updates(PaymentSummaryBuilder b)]) = _$PaymentSummary;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PaymentSummaryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PaymentSummary> get serializer => _$PaymentSummarySerializer();
}

class _$PaymentSummarySerializer implements PrimitiveSerializer<PaymentSummary> {
  @override
  final Iterable<Type> types = const [PaymentSummary, _$PaymentSummary];

  @override
  final String wireName = r'PaymentSummary';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PaymentSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.totalRevenue != null) {
      yield r'total_revenue';
      yield serializers.serialize(
        object.totalRevenue,
        specifiedType: const FullType(num),
      );
    }
    if (object.payouts != null) {
      yield r'payouts';
      yield serializers.serialize(
        object.payouts,
        specifiedType: const FullType(num),
      );
    }
    if (object.commission != null) {
      yield r'commission';
      yield serializers.serialize(
        object.commission,
        specifiedType: const FullType(num),
      );
    }
    if (object.pendingSettlements != null) {
      yield r'pending_settlements';
      yield serializers.serialize(
        object.pendingSettlements,
        specifiedType: const FullType(num),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PaymentSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PaymentSummaryBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'total_revenue':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.totalRevenue = valueDes;
          break;
        case r'payouts':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.payouts = valueDes;
          break;
        case r'commission':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.commission = valueDes;
          break;
        case r'pending_settlements':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.pendingSettlements = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PaymentSummary deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PaymentSummaryBuilder();
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


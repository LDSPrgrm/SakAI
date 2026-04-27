// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'earnings_item.g.dart';

/// A single ride's earnings contribution for a driver.
///
/// Properties:
/// * [id] 
/// * [rideId] 
/// * [fareAmount] - Driver's share of the fare (before commission)
/// * [tipAmount] - Tip amount (0 if no tip)
/// * [totalAmount] - Total earnings for this ride (fare + tip)
/// * [currency] - ISO 4217 currency code
/// * [completedAt] - When the ride was completed
@BuiltValue()
abstract class EarningsItem implements Built<EarningsItem, EarningsItemBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'ride_id')
  String get rideId;

  /// Driver's share of the fare (before commission)
  @BuiltValueField(wireName: r'fare_amount')
  double get fareAmount;

  /// Tip amount (0 if no tip)
  @BuiltValueField(wireName: r'tip_amount')
  double get tipAmount;

  /// Total earnings for this ride (fare + tip)
  @BuiltValueField(wireName: r'total_amount')
  double get totalAmount;

  /// ISO 4217 currency code
  @BuiltValueField(wireName: r'currency')
  String? get currency;

  /// When the ride was completed
  @BuiltValueField(wireName: r'completed_at')
  DateTime get completedAt;

  EarningsItem._();

  factory EarningsItem([void updates(EarningsItemBuilder b)]) = _$EarningsItem;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(EarningsItemBuilder b) => b
      ..currency = 'USD';

  @BuiltValueSerializer(custom: true)
  static Serializer<EarningsItem> get serializer => _$EarningsItemSerializer();
}

class _$EarningsItemSerializer implements PrimitiveSerializer<EarningsItem> {
  @override
  final Iterable<Type> types = const [EarningsItem, _$EarningsItem];

  @override
  final String wireName = r'EarningsItem';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    EarningsItem object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'ride_id';
    yield serializers.serialize(
      object.rideId,
      specifiedType: const FullType(String),
    );
    yield r'fare_amount';
    yield serializers.serialize(
      object.fareAmount,
      specifiedType: const FullType(double),
    );
    yield r'tip_amount';
    yield serializers.serialize(
      object.tipAmount,
      specifiedType: const FullType(double),
    );
    yield r'total_amount';
    yield serializers.serialize(
      object.totalAmount,
      specifiedType: const FullType(double),
    );
    if (object.currency != null) {
      yield r'currency';
      yield serializers.serialize(
        object.currency,
        specifiedType: const FullType(String),
      );
    }
    yield r'completed_at';
    yield serializers.serialize(
      object.completedAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    EarningsItem object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required EarningsItemBuilder result,
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
        case r'fare_amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(double),
          ) as double;
          result.fareAmount = valueDes;
          break;
        case r'tip_amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(double),
          ) as double;
          result.tipAmount = valueDes;
          break;
        case r'total_amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(double),
          ) as double;
          result.totalAmount = valueDes;
          break;
        case r'currency':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.currency = valueDes;
          break;
        case r'completed_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.completedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  EarningsItem deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = EarningsItemBuilder();
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


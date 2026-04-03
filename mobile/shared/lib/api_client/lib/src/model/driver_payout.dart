//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'driver_payout.g.dart';

/// DriverPayout
///
/// Properties:
/// * [id] 
/// * [batch] 
/// * [driverCount] 
/// * [totalAmount] 
/// * [period] 
/// * [status] 
@BuiltValue()
abstract class DriverPayout implements Built<DriverPayout, DriverPayoutBuilder> {
  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'batch')
  String? get batch;

  @BuiltValueField(wireName: r'driver_count')
  int? get driverCount;

  @BuiltValueField(wireName: r'total_amount')
  num? get totalAmount;

  @BuiltValueField(wireName: r'period')
  String? get period;

  @BuiltValueField(wireName: r'status')
  DriverPayoutStatusEnum? get status;
  // enum statusEnum {  pending,  approved,  processing,  done,  };

  DriverPayout._();

  factory DriverPayout([void updates(DriverPayoutBuilder b)]) = _$DriverPayout;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DriverPayoutBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DriverPayout> get serializer => _$DriverPayoutSerializer();
}

class _$DriverPayoutSerializer implements PrimitiveSerializer<DriverPayout> {
  @override
  final Iterable<Type> types = const [DriverPayout, _$DriverPayout];

  @override
  final String wireName = r'DriverPayout';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DriverPayout object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
    if (object.batch != null) {
      yield r'batch';
      yield serializers.serialize(
        object.batch,
        specifiedType: const FullType(String),
      );
    }
    if (object.driverCount != null) {
      yield r'driver_count';
      yield serializers.serialize(
        object.driverCount,
        specifiedType: const FullType(int),
      );
    }
    if (object.totalAmount != null) {
      yield r'total_amount';
      yield serializers.serialize(
        object.totalAmount,
        specifiedType: const FullType(num),
      );
    }
    if (object.period != null) {
      yield r'period';
      yield serializers.serialize(
        object.period,
        specifiedType: const FullType(String),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(DriverPayoutStatusEnum),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    DriverPayout object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DriverPayoutBuilder result,
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
        case r'batch':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.batch = valueDes;
          break;
        case r'driver_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.driverCount = valueDes;
          break;
        case r'total_amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.totalAmount = valueDes;
          break;
        case r'period':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.period = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DriverPayoutStatusEnum),
          ) as DriverPayoutStatusEnum;
          result.status = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DriverPayout deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DriverPayoutBuilder();
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

class DriverPayoutStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'pending')
  static const DriverPayoutStatusEnum pending = _$driverPayoutStatusEnum_pending;
  @BuiltValueEnumConst(wireName: r'approved')
  static const DriverPayoutStatusEnum approved = _$driverPayoutStatusEnum_approved;
  @BuiltValueEnumConst(wireName: r'processing')
  static const DriverPayoutStatusEnum processing = _$driverPayoutStatusEnum_processing;
  @BuiltValueEnumConst(wireName: r'done')
  static const DriverPayoutStatusEnum done = _$driverPayoutStatusEnum_done;

  static Serializer<DriverPayoutStatusEnum> get serializer => _$driverPayoutStatusEnumSerializer;

  const DriverPayoutStatusEnum._(String name): super(name);

  static BuiltSet<DriverPayoutStatusEnum> get values => _$driverPayoutStatusEnumValues;
  static DriverPayoutStatusEnum valueOf(String name) => _$driverPayoutStatusEnumValueOf(name);
}


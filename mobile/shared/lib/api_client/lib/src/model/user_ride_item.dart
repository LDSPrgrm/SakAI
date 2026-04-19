// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sakai_api_client/src/model/ride_status.dart';
import 'package:built_collection/built_collection.dart';
import 'package:sakai_api_client/src/model/driver_summary.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'user_ride_item.g.dart';

/// UserRideItem
///
/// Properties:
/// * [id] 
/// * [status] 
/// * [originAddress] 
/// * [destinationAddress] 
/// * [fare] - Final fare (null if not completed)
/// * [estimatedFare] 
/// * [driver] 
/// * [paymentMethod] 
/// * [createdAt] 
/// * [updatedAt] 
@BuiltValue()
abstract class UserRideItem implements Built<UserRideItem, UserRideItemBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'status')
  RideStatus get status;
  // enum statusEnum {  requested,  accepted,  arrived,  in_progress,  completed,  cancelled,  };

  @BuiltValueField(wireName: r'origin_address')
  String get originAddress;

  @BuiltValueField(wireName: r'destination_address')
  String get destinationAddress;

  /// Final fare (null if not completed)
  @BuiltValueField(wireName: r'fare')
  double? get fare;

  @BuiltValueField(wireName: r'estimated_fare')
  double get estimatedFare;

  @BuiltValueField(wireName: r'driver')
  DriverSummary? get driver;

  @BuiltValueField(wireName: r'payment_method')
  UserRideItemPaymentMethodEnum get paymentMethod;
  // enum paymentMethodEnum {  cash,  card,  };

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updated_at')
  DateTime get updatedAt;

  UserRideItem._();

  factory UserRideItem([void updates(UserRideItemBuilder b)]) = _$UserRideItem;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UserRideItemBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UserRideItem> get serializer => _$UserRideItemSerializer();
}

class _$UserRideItemSerializer implements PrimitiveSerializer<UserRideItem> {
  @override
  final Iterable<Type> types = const [UserRideItem, _$UserRideItem];

  @override
  final String wireName = r'UserRideItem';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UserRideItem object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(RideStatus),
    );
    yield r'origin_address';
    yield serializers.serialize(
      object.originAddress,
      specifiedType: const FullType(String),
    );
    yield r'destination_address';
    yield serializers.serialize(
      object.destinationAddress,
      specifiedType: const FullType(String),
    );
    if (object.fare != null) {
      yield r'fare';
      yield serializers.serialize(
        object.fare,
        specifiedType: const FullType.nullable(double),
      );
    }
    yield r'estimated_fare';
    yield serializers.serialize(
      object.estimatedFare,
      specifiedType: const FullType(double),
    );
    if (object.driver != null) {
      yield r'driver';
      yield serializers.serialize(
        object.driver,
        specifiedType: const FullType.nullable(DriverSummary),
      );
    }
    yield r'payment_method';
    yield serializers.serialize(
      object.paymentMethod,
      specifiedType: const FullType(UserRideItemPaymentMethodEnum),
    );
    yield r'created_at';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'updated_at';
    yield serializers.serialize(
      object.updatedAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    UserRideItem object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UserRideItemBuilder result,
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
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(RideStatus),
          ) as RideStatus;
          result.status = valueDes;
          break;
        case r'origin_address':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.originAddress = valueDes;
          break;
        case r'destination_address':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.destinationAddress = valueDes;
          break;
        case r'fare':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(double),
          ) as double?;
          if (valueDes == null) continue;
          result.fare = valueDes;
          break;
        case r'estimated_fare':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(double),
          ) as double;
          result.estimatedFare = valueDes;
          break;
        case r'driver':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DriverSummary),
          ) as DriverSummary?;
          if (valueDes == null) continue;
          result.driver.replace(valueDes);
          break;
        case r'payment_method':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(UserRideItemPaymentMethodEnum),
          ) as UserRideItemPaymentMethodEnum;
          result.paymentMethod = valueDes;
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'updated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.updatedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UserRideItem deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UserRideItemBuilder();
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

class UserRideItemPaymentMethodEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'cash')
  static const UserRideItemPaymentMethodEnum cash = _$userRideItemPaymentMethodEnum_cash;
  @BuiltValueEnumConst(wireName: r'card')
  static const UserRideItemPaymentMethodEnum card = _$userRideItemPaymentMethodEnum_card;

  static Serializer<UserRideItemPaymentMethodEnum> get serializer => _$userRideItemPaymentMethodEnumSerializer;

  const UserRideItemPaymentMethodEnum._(String name): super(name);

  static BuiltSet<UserRideItemPaymentMethodEnum> get values => _$userRideItemPaymentMethodEnumValues;
  static UserRideItemPaymentMethodEnum valueOf(String name) => _$userRideItemPaymentMethodEnumValueOf(name);
}


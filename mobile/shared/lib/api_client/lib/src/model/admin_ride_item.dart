// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sakai_api_client/src/model/ride_status.dart';
import 'package:sakai_api_client/src/model/user_profile.dart';
import 'package:built_collection/built_collection.dart';
import 'package:sakai_api_client/src/model/driver_summary.dart';
import 'package:sakai_api_client/src/model/lat_lng.dart';
import 'package:sakai_api_client/src/model/ride_response.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_ride_item.g.dart';

/// AdminRideItem
///
/// Properties:
/// * [id] 
/// * [status] 
/// * [passenger] 
/// * [driver] - Null until a driver is matched and accepts.
/// * [origin] 
/// * [destination] 
/// * [originAddress] 
/// * [destinationAddress] 
/// * [notes] 
/// * [fare] - Final fare amount (null if ride not completed)
/// * [estimatedFare] - Estimated fare at request time
/// * [actualFare] - Actual fare after completion
/// * [fareBreakdown] - JSONB breakdown of fare components
/// * [rideType] - Vehicle type for this ride
/// * [paymentMethod] - Payment method used; populated once the ride is completed
/// * [cancelledBy] - Set only when status is `cancelled`
/// * [cancellationReason] - Predefined cancellation reason code
/// * [cancellationReasonText] - Free-text cancellation reason
/// * [declineCount] - Number of times this ride was declined by drivers
/// * [createdAt] 
/// * [updatedAt] 
/// * [passengerName] 
/// * [driverName] 
/// * [totalFare] - Final fare charged for the ride (null for non-completed rides)
@BuiltValue()
abstract class AdminRideItem implements RideResponse, Built<AdminRideItem, AdminRideItemBuilder> {
  @BuiltValueField(wireName: r'passenger_name')
  String? get passengerName;

  /// Final fare charged for the ride (null for non-completed rides)
  @BuiltValueField(wireName: r'total_fare')
  num? get totalFare;

  @BuiltValueField(wireName: r'driver_name')
  String? get driverName;

  AdminRideItem._();

  factory AdminRideItem([void updates(AdminRideItemBuilder b)]) = _$AdminRideItem;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminRideItemBuilder b) => b
      ..declineCount = 0;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminRideItem> get serializer => _$AdminRideItemSerializer();
}

class _$AdminRideItemSerializer implements PrimitiveSerializer<AdminRideItem> {
  @override
  final Iterable<Type> types = const [AdminRideItem, _$AdminRideItem];

  @override
  final String wireName = r'AdminRideItem';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminRideItem object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.passengerName != null) {
      yield r'passenger_name';
      yield serializers.serialize(
        object.passengerName,
        specifiedType: const FullType(String),
      );
    }
    if (object.fare != null) {
      yield r'fare';
      yield serializers.serialize(
        object.fare,
        specifiedType: const FullType.nullable(double),
      );
    }
    if (object.totalFare != null) {
      yield r'total_fare';
      yield serializers.serialize(
        object.totalFare,
        specifiedType: const FullType.nullable(num),
      );
    }
    if (object.rideType != null) {
      yield r'ride_type';
      yield serializers.serialize(
        object.rideType,
        specifiedType: const FullType(RideResponseRideTypeEnum),
      );
    }
    if (object.destinationAddress != null) {
      yield r'destination_address';
      yield serializers.serialize(
        object.destinationAddress,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.notes != null) {
      yield r'notes';
      yield serializers.serialize(
        object.notes,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.cancellationReason != null) {
      yield r'cancellation_reason';
      yield serializers.serialize(
        object.cancellationReason,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.originAddress != null) {
      yield r'origin_address';
      yield serializers.serialize(
        object.originAddress,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'origin';
    yield serializers.serialize(
      object.origin,
      specifiedType: const FullType(LatLng),
    );
    yield r'destination';
    yield serializers.serialize(
      object.destination,
      specifiedType: const FullType(LatLng),
    );
    if (object.estimatedFare != null) {
      yield r'estimated_fare';
      yield serializers.serialize(
        object.estimatedFare,
        specifiedType: const FullType(double),
      );
    }
    if (object.cancelledBy != null) {
      yield r'cancelled_by';
      yield serializers.serialize(
        object.cancelledBy,
        specifiedType: const FullType.nullable(RideResponseCancelledByEnum),
      );
    }
    yield r'created_at';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    if (object.declineCount != null) {
      yield r'decline_count';
      yield serializers.serialize(
        object.declineCount,
        specifiedType: const FullType(int),
      );
    }
    if (object.driver != null) {
      yield r'driver';
      yield serializers.serialize(
        object.driver,
        specifiedType: const FullType.nullable(DriverSummary),
      );
    }
    yield r'passenger';
    yield serializers.serialize(
      object.passenger,
      specifiedType: const FullType(UserProfile),
    );
    if (object.actualFare != null) {
      yield r'actual_fare';
      yield serializers.serialize(
        object.actualFare,
        specifiedType: const FullType.nullable(double),
      );
    }
    if (object.paymentMethod != null) {
      yield r'payment_method';
      yield serializers.serialize(
        object.paymentMethod,
        specifiedType: const FullType(RideResponsePaymentMethodEnum),
      );
    }
    if (object.driverName != null) {
      yield r'driver_name';
      yield serializers.serialize(
        object.driverName,
        specifiedType: const FullType(String),
      );
    }
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    if (object.fareBreakdown != null) {
      yield r'fare_breakdown';
      yield serializers.serialize(
        object.fareBreakdown,
        specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
      );
    }
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(RideStatus),
    );
    if (object.cancellationReasonText != null) {
      yield r'cancellation_reason_text';
      yield serializers.serialize(
        object.cancellationReasonText,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'updated_at';
    yield serializers.serialize(
      object.updatedAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminRideItem object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminRideItemBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'passenger_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.passengerName = valueDes;
          break;
        case r'fare':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(double),
          ) as double?;
          if (valueDes == null) continue;
          result.fare = valueDes;
          break;
        case r'total_fare':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.totalFare = valueDes;
          break;
        case r'ride_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(RideResponseRideTypeEnum),
          ) as RideResponseRideTypeEnum;
          result.rideType = valueDes;
          break;
        case r'destination_address':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.destinationAddress = valueDes;
          break;
        case r'notes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.notes = valueDes;
          break;
        case r'cancellation_reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.cancellationReason = valueDes;
          break;
        case r'origin_address':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.originAddress = valueDes;
          break;
        case r'origin':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(LatLng),
          ) as LatLng;
          result.origin.replace(valueDes);
          break;
        case r'destination':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(LatLng),
          ) as LatLng;
          result.destination.replace(valueDes);
          break;
        case r'estimated_fare':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(double),
          ) as double;
          result.estimatedFare = valueDes;
          break;
        case r'cancelled_by':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(RideResponseCancelledByEnum),
          ) as RideResponseCancelledByEnum?;
          if (valueDes == null) continue;
          result.cancelledBy = valueDes;
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'decline_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.declineCount = valueDes;
          break;
        case r'driver':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DriverSummary),
          ) as DriverSummary?;
          if (valueDes == null) continue;
          result.driver.replace(valueDes);
          break;
        case r'passenger':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(UserProfile),
          ) as UserProfile;
          result.passenger = valueDes;
          break;
        case r'actual_fare':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(double),
          ) as double?;
          if (valueDes == null) continue;
          result.actualFare = valueDes;
          break;
        case r'payment_method':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(RideResponsePaymentMethodEnum),
          ) as RideResponsePaymentMethodEnum;
          result.paymentMethod = valueDes;
          break;
        case r'driver_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.driverName = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'fare_breakdown':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>?;
          if (valueDes == null) continue;
          result.fareBreakdown.replace(valueDes);
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(RideStatus),
          ) as RideStatus;
          result.status = valueDes;
          break;
        case r'cancellation_reason_text':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.cancellationReasonText = valueDes;
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
  AdminRideItem deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminRideItemBuilder();
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

class AdminRideItemRideTypeEnum extends EnumClass {

  /// Vehicle type for this ride
  @BuiltValueEnumConst(wireName: r'motorcycle')
  static const AdminRideItemRideTypeEnum motorcycle = _$adminRideItemRideTypeEnum_motorcycle;
  /// Vehicle type for this ride
  @BuiltValueEnumConst(wireName: r'car')
  static const AdminRideItemRideTypeEnum car = _$adminRideItemRideTypeEnum_car;
  /// Vehicle type for this ride
  @BuiltValueEnumConst(wireName: r'tricycle')
  static const AdminRideItemRideTypeEnum tricycle = _$adminRideItemRideTypeEnum_tricycle;

  static Serializer<AdminRideItemRideTypeEnum> get serializer => _$adminRideItemRideTypeEnumSerializer;

  const AdminRideItemRideTypeEnum._(String name): super(name);

  static BuiltSet<AdminRideItemRideTypeEnum> get values => _$adminRideItemRideTypeEnumValues;
  static AdminRideItemRideTypeEnum valueOf(String name) => _$adminRideItemRideTypeEnumValueOf(name);
}

class AdminRideItemPaymentMethodEnum extends EnumClass {

  /// Payment method used; populated once the ride is completed
  @BuiltValueEnumConst(wireName: r'cash')
  static const AdminRideItemPaymentMethodEnum cash = _$adminRideItemPaymentMethodEnum_cash;
  /// Payment method used; populated once the ride is completed
  @BuiltValueEnumConst(wireName: r'gcash')
  static const AdminRideItemPaymentMethodEnum gcash = _$adminRideItemPaymentMethodEnum_gcash;
  /// Payment method used; populated once the ride is completed
  @BuiltValueEnumConst(wireName: r'paymaya')
  static const AdminRideItemPaymentMethodEnum paymaya = _$adminRideItemPaymentMethodEnum_paymaya;
  /// Payment method used; populated once the ride is completed
  @BuiltValueEnumConst(wireName: r'card')
  static const AdminRideItemPaymentMethodEnum card = _$adminRideItemPaymentMethodEnum_card;

  static Serializer<AdminRideItemPaymentMethodEnum> get serializer => _$adminRideItemPaymentMethodEnumSerializer;

  const AdminRideItemPaymentMethodEnum._(String name): super(name);

  static BuiltSet<AdminRideItemPaymentMethodEnum> get values => _$adminRideItemPaymentMethodEnumValues;
  static AdminRideItemPaymentMethodEnum valueOf(String name) => _$adminRideItemPaymentMethodEnumValueOf(name);
}

class AdminRideItemCancelledByEnum extends EnumClass {

  /// Set only when status is `cancelled`
  @BuiltValueEnumConst(wireName: r'passenger')
  static const AdminRideItemCancelledByEnum passenger = _$adminRideItemCancelledByEnum_passenger;
  /// Set only when status is `cancelled`
  @BuiltValueEnumConst(wireName: r'driver')
  static const AdminRideItemCancelledByEnum driver = _$adminRideItemCancelledByEnum_driver;

  static Serializer<AdminRideItemCancelledByEnum> get serializer => _$adminRideItemCancelledByEnumSerializer;

  const AdminRideItemCancelledByEnum._(String name): super(name);

  static BuiltSet<AdminRideItemCancelledByEnum> get values => _$adminRideItemCancelledByEnumValues;
  static AdminRideItemCancelledByEnum valueOf(String name) => _$adminRideItemCancelledByEnumValueOf(name);
}


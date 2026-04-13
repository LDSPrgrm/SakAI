// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sakai_api_client/src/model/ride_status.dart';
import 'package:sakai_api_client/src/model/user_profile.dart';
import 'package:built_collection/built_collection.dart';
import 'package:sakai_api_client/src/model/driver_summary.dart';
import 'package:sakai_api_client/src/model/lat_lng.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ride_response.g.dart';

/// RideResponse
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
/// * [paymentMethod] - Payment method used for ride
/// * [cancelledBy] - Set only when status is `cancelled`
/// * [cancellationReason] - Predefined cancellation reason code
/// * [cancellationReasonText] - Free-text cancellation reason
/// * [createdAt] 
/// * [updatedAt] 
@BuiltValue(instantiable: false)
abstract class RideResponse  {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'status')
  RideStatus get status;
  // enum statusEnum {  requested,  accepted,  arrived,  in_progress,  completed,  cancelled,  };

  @BuiltValueField(wireName: r'passenger')
  UserProfile get passenger;

  /// Null until a driver is matched and accepts.
  @BuiltValueField(wireName: r'driver')
  DriverSummary? get driver;

  @BuiltValueField(wireName: r'origin')
  LatLng get origin;

  @BuiltValueField(wireName: r'destination')
  LatLng get destination;

  @BuiltValueField(wireName: r'origin_address')
  String? get originAddress;

  @BuiltValueField(wireName: r'destination_address')
  String? get destinationAddress;

  @BuiltValueField(wireName: r'notes')
  String? get notes;

  /// Final fare amount (null if ride not completed)
  @BuiltValueField(wireName: r'fare')
  double? get fare;

  /// Estimated fare at request time
  @BuiltValueField(wireName: r'estimated_fare')
  double? get estimatedFare;

  /// Actual fare after completion
  @BuiltValueField(wireName: r'actual_fare')
  double? get actualFare;

  /// JSONB breakdown of fare components
  @BuiltValueField(wireName: r'fare_breakdown')
  BuiltMap<String, JsonObject?>? get fareBreakdown;

  /// Vehicle type for this ride
  @BuiltValueField(wireName: r'ride_type')
  RideResponseRideTypeEnum? get rideType;
  // enum rideTypeEnum {  motorcycle,  car,  tricycle,  };

  /// Payment method used for ride
  @BuiltValueField(wireName: r'payment_method')
  RideResponsePaymentMethodEnum? get paymentMethod;
  // enum paymentMethodEnum {  cash,  card,  };

  /// Set only when status is `cancelled`
  @BuiltValueField(wireName: r'cancelled_by')
  RideResponseCancelledByEnum? get cancelledBy;
  // enum cancelledByEnum {  passenger,  driver,  };

  /// Predefined cancellation reason code
  @BuiltValueField(wireName: r'cancellation_reason')
  String? get cancellationReason;

  /// Free-text cancellation reason
  @BuiltValueField(wireName: r'cancellation_reason_text')
  String? get cancellationReasonText;

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updated_at')
  DateTime get updatedAt;

  @BuiltValueSerializer(custom: true)
  static Serializer<RideResponse> get serializer => _$RideResponseSerializer();
}

class _$RideResponseSerializer implements PrimitiveSerializer<RideResponse> {
  @override
  final Iterable<Type> types = const [RideResponse];

  @override
  final String wireName = r'RideResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RideResponse object, {
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
    yield r'passenger';
    yield serializers.serialize(
      object.passenger,
      specifiedType: const FullType(UserProfile),
    );
    if (object.driver != null) {
      yield r'driver';
      yield serializers.serialize(
        object.driver,
        specifiedType: const FullType.nullable(DriverSummary),
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
    if (object.originAddress != null) {
      yield r'origin_address';
      yield serializers.serialize(
        object.originAddress,
        specifiedType: const FullType.nullable(String),
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
    if (object.fare != null) {
      yield r'fare';
      yield serializers.serialize(
        object.fare,
        specifiedType: const FullType.nullable(double),
      );
    }
    if (object.estimatedFare != null) {
      yield r'estimated_fare';
      yield serializers.serialize(
        object.estimatedFare,
        specifiedType: const FullType(double),
      );
    }
    if (object.actualFare != null) {
      yield r'actual_fare';
      yield serializers.serialize(
        object.actualFare,
        specifiedType: const FullType.nullable(double),
      );
    }
    if (object.fareBreakdown != null) {
      yield r'fare_breakdown';
      yield serializers.serialize(
        object.fareBreakdown,
        specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
      );
    }
    if (object.rideType != null) {
      yield r'ride_type';
      yield serializers.serialize(
        object.rideType,
        specifiedType: const FullType(RideResponseRideTypeEnum),
      );
    }
    if (object.paymentMethod != null) {
      yield r'payment_method';
      yield serializers.serialize(
        object.paymentMethod,
        specifiedType: const FullType(RideResponsePaymentMethodEnum),
      );
    }
    if (object.cancelledBy != null) {
      yield r'cancelled_by';
      yield serializers.serialize(
        object.cancelledBy,
        specifiedType: const FullType.nullable(RideResponseCancelledByEnum),
      );
    }
    if (object.cancellationReason != null) {
      yield r'cancellation_reason';
      yield serializers.serialize(
        object.cancellationReason,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.cancellationReasonText != null) {
      yield r'cancellation_reason_text';
      yield serializers.serialize(
        object.cancellationReasonText,
        specifiedType: const FullType.nullable(String),
      );
    }
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
    RideResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  @override
  RideResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return serializers.deserialize(serialized, specifiedType: FullType($RideResponse)) as $RideResponse;
  }
}

/// a concrete implementation of [RideResponse], since [RideResponse] is not instantiable
@BuiltValue(instantiable: true)
abstract class $RideResponse implements RideResponse, Built<$RideResponse, $RideResponseBuilder> {
  $RideResponse._();

  factory $RideResponse([void Function($RideResponseBuilder)? updates]) = _$$RideResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults($RideResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<$RideResponse> get serializer => _$$RideResponseSerializer();
}

class _$$RideResponseSerializer implements PrimitiveSerializer<$RideResponse> {
  @override
  final Iterable<Type> types = const [$RideResponse, _$$RideResponse];

  @override
  final String wireName = r'$RideResponse';

  @override
  Object serialize(
    Serializers serializers,
    $RideResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return serializers.serialize(object, specifiedType: FullType(RideResponse))!;
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RideResponseBuilder result,
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
        case r'passenger':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(UserProfile),
          ) as UserProfile;
          result.passenger = valueDes;
          break;
        case r'driver':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DriverSummary),
          ) as DriverSummary?;
          if (valueDes == null) continue;
          result.driver.replace(valueDes);
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
        case r'origin_address':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.originAddress = valueDes;
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
        case r'actual_fare':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(double),
          ) as double?;
          if (valueDes == null) continue;
          result.actualFare = valueDes;
          break;
        case r'fare_breakdown':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>?;
          if (valueDes == null) continue;
          result.fareBreakdown.replace(valueDes);
          break;
        case r'ride_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(RideResponseRideTypeEnum),
          ) as RideResponseRideTypeEnum;
          result.rideType = valueDes;
          break;
        case r'payment_method':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(RideResponsePaymentMethodEnum),
          ) as RideResponsePaymentMethodEnum;
          result.paymentMethod = valueDes;
          break;
        case r'cancelled_by':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(RideResponseCancelledByEnum),
          ) as RideResponseCancelledByEnum?;
          if (valueDes == null) continue;
          result.cancelledBy = valueDes;
          break;
        case r'cancellation_reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.cancellationReason = valueDes;
          break;
        case r'cancellation_reason_text':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.cancellationReasonText = valueDes;
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
  $RideResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = $RideResponseBuilder();
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

class RideResponseRideTypeEnum extends EnumClass {

  /// Vehicle type for this ride
  @BuiltValueEnumConst(wireName: r'motorcycle')
  static const RideResponseRideTypeEnum motorcycle = _$rideResponseRideTypeEnum_motorcycle;
  /// Vehicle type for this ride
  @BuiltValueEnumConst(wireName: r'car')
  static const RideResponseRideTypeEnum car = _$rideResponseRideTypeEnum_car;
  /// Vehicle type for this ride
  @BuiltValueEnumConst(wireName: r'tricycle')
  static const RideResponseRideTypeEnum tricycle = _$rideResponseRideTypeEnum_tricycle;

  static Serializer<RideResponseRideTypeEnum> get serializer => _$rideResponseRideTypeEnumSerializer;

  const RideResponseRideTypeEnum._(String name): super(name);

  static BuiltSet<RideResponseRideTypeEnum> get values => _$rideResponseRideTypeEnumValues;
  static RideResponseRideTypeEnum valueOf(String name) => _$rideResponseRideTypeEnumValueOf(name);
}

class RideResponsePaymentMethodEnum extends EnumClass {

  /// Payment method used for ride
  @BuiltValueEnumConst(wireName: r'cash')
  static const RideResponsePaymentMethodEnum cash = _$rideResponsePaymentMethodEnum_cash;
  /// Payment method used for ride
  @BuiltValueEnumConst(wireName: r'card')
  static const RideResponsePaymentMethodEnum card = _$rideResponsePaymentMethodEnum_card;

  static Serializer<RideResponsePaymentMethodEnum> get serializer => _$rideResponsePaymentMethodEnumSerializer;

  const RideResponsePaymentMethodEnum._(String name): super(name);

  static BuiltSet<RideResponsePaymentMethodEnum> get values => _$rideResponsePaymentMethodEnumValues;
  static RideResponsePaymentMethodEnum valueOf(String name) => _$rideResponsePaymentMethodEnumValueOf(name);
}

class RideResponseCancelledByEnum extends EnumClass {

  /// Set only when status is `cancelled`
  @BuiltValueEnumConst(wireName: r'passenger')
  static const RideResponseCancelledByEnum passenger = _$rideResponseCancelledByEnum_passenger;
  /// Set only when status is `cancelled`
  @BuiltValueEnumConst(wireName: r'driver')
  static const RideResponseCancelledByEnum driver = _$rideResponseCancelledByEnum_driver;

  static Serializer<RideResponseCancelledByEnum> get serializer => _$rideResponseCancelledByEnumSerializer;

  const RideResponseCancelledByEnum._(String name): super(name);

  static BuiltSet<RideResponseCancelledByEnum> get values => _$rideResponseCancelledByEnumValues;
  static RideResponseCancelledByEnum valueOf(String name) => _$rideResponseCancelledByEnumValueOf(name);
}


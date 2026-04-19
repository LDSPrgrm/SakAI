// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sakai_api_client/src/model/lat_lng.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ride_request_body.g.dart';

/// RideRequestBody
///
/// Properties:
/// * [origin] 
/// * [destination] 
/// * [originAddress] - Human-readable pickup address (for display only)
/// * [destinationAddress] - Human-readable dropoff address (for display only)
/// * [notes] - Optional instructions for the driver
/// * [rideType] - Passenger's selected vehicle type
/// * [paymentMethod] - Payment method for this ride
@BuiltValue()
abstract class RideRequestBody implements Built<RideRequestBody, RideRequestBodyBuilder> {
  @BuiltValueField(wireName: r'origin')
  LatLng get origin;

  @BuiltValueField(wireName: r'destination')
  LatLng get destination;

  /// Human-readable pickup address (for display only)
  @BuiltValueField(wireName: r'origin_address')
  String? get originAddress;

  /// Human-readable dropoff address (for display only)
  @BuiltValueField(wireName: r'destination_address')
  String? get destinationAddress;

  /// Optional instructions for the driver
  @BuiltValueField(wireName: r'notes')
  String? get notes;

  /// Passenger's selected vehicle type
  @BuiltValueField(wireName: r'ride_type')
  RideRequestBodyRideTypeEnum get rideType;
  // enum rideTypeEnum {  motorcycle,  car,  tricycle,  };

  /// Payment method for this ride
  @BuiltValueField(wireName: r'payment_method')
  RideRequestBodyPaymentMethodEnum? get paymentMethod;
  // enum paymentMethodEnum {  cash,  card,  };

  RideRequestBody._();

  factory RideRequestBody([void updates(RideRequestBodyBuilder b)]) = _$RideRequestBody;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RideRequestBodyBuilder b) => b
      ..rideType = RideRequestBodyRideTypeEnum.valueOf('car')
      ..paymentMethod = RideRequestBodyPaymentMethodEnum.valueOf('cash');

  @BuiltValueSerializer(custom: true)
  static Serializer<RideRequestBody> get serializer => _$RideRequestBodySerializer();
}

class _$RideRequestBodySerializer implements PrimitiveSerializer<RideRequestBody> {
  @override
  final Iterable<Type> types = const [RideRequestBody, _$RideRequestBody];

  @override
  final String wireName = r'RideRequestBody';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RideRequestBody object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
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
        specifiedType: const FullType(String),
      );
    }
    if (object.destinationAddress != null) {
      yield r'destination_address';
      yield serializers.serialize(
        object.destinationAddress,
        specifiedType: const FullType(String),
      );
    }
    if (object.notes != null) {
      yield r'notes';
      yield serializers.serialize(
        object.notes,
        specifiedType: const FullType(String),
      );
    }
    yield r'ride_type';
    yield serializers.serialize(
      object.rideType,
      specifiedType: const FullType(RideRequestBodyRideTypeEnum),
    );
    if (object.paymentMethod != null) {
      yield r'payment_method';
      yield serializers.serialize(
        object.paymentMethod,
        specifiedType: const FullType(RideRequestBodyPaymentMethodEnum),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    RideRequestBody object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RideRequestBodyBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
        case r'notes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.notes = valueDes;
          break;
        case r'ride_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(RideRequestBodyRideTypeEnum),
          ) as RideRequestBodyRideTypeEnum;
          result.rideType = valueDes;
          break;
        case r'payment_method':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(RideRequestBodyPaymentMethodEnum),
          ) as RideRequestBodyPaymentMethodEnum;
          result.paymentMethod = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RideRequestBody deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RideRequestBodyBuilder();
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

class RideRequestBodyRideTypeEnum extends EnumClass {

  /// Passenger's selected vehicle type
  @BuiltValueEnumConst(wireName: r'motorcycle')
  static const RideRequestBodyRideTypeEnum motorcycle = _$rideRequestBodyRideTypeEnum_motorcycle;
  /// Passenger's selected vehicle type
  @BuiltValueEnumConst(wireName: r'car')
  static const RideRequestBodyRideTypeEnum car = _$rideRequestBodyRideTypeEnum_car;
  /// Passenger's selected vehicle type
  @BuiltValueEnumConst(wireName: r'tricycle')
  static const RideRequestBodyRideTypeEnum tricycle = _$rideRequestBodyRideTypeEnum_tricycle;

  static Serializer<RideRequestBodyRideTypeEnum> get serializer => _$rideRequestBodyRideTypeEnumSerializer;

  const RideRequestBodyRideTypeEnum._(String name): super(name);

  static BuiltSet<RideRequestBodyRideTypeEnum> get values => _$rideRequestBodyRideTypeEnumValues;
  static RideRequestBodyRideTypeEnum valueOf(String name) => _$rideRequestBodyRideTypeEnumValueOf(name);
}

class RideRequestBodyPaymentMethodEnum extends EnumClass {

  /// Payment method for this ride
  @BuiltValueEnumConst(wireName: r'cash')
  static const RideRequestBodyPaymentMethodEnum cash = _$rideRequestBodyPaymentMethodEnum_cash;
  /// Payment method for this ride
  @BuiltValueEnumConst(wireName: r'card')
  static const RideRequestBodyPaymentMethodEnum card = _$rideRequestBodyPaymentMethodEnum_card;

  static Serializer<RideRequestBodyPaymentMethodEnum> get serializer => _$rideRequestBodyPaymentMethodEnumSerializer;

  const RideRequestBodyPaymentMethodEnum._(String name): super(name);

  static BuiltSet<RideRequestBodyPaymentMethodEnum> get values => _$rideRequestBodyPaymentMethodEnumValues;
  static RideRequestBodyPaymentMethodEnum valueOf(String name) => _$rideRequestBodyPaymentMethodEnumValueOf(name);
}


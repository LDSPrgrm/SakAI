//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sakai_api_client/src/model/lat_lng.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'nearby_driver.g.dart';

/// NearbyDriver
///
/// Properties:
/// * [id] 
/// * [name] 
/// * [vehicleMake] 
/// * [vehicleModel] 
/// * [vehiclePlate] 
/// * [vehicleType] 
/// * [rating] 
/// * [distanceM] 
/// * [location] 
/// * [heading] - Compass bearing in degrees
@BuiltValue()
abstract class NearbyDriver implements Built<NearbyDriver, NearbyDriverBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'vehicle_make')
  String? get vehicleMake;

  @BuiltValueField(wireName: r'vehicle_model')
  String? get vehicleModel;

  @BuiltValueField(wireName: r'vehicle_plate')
  String? get vehiclePlate;

  @BuiltValueField(wireName: r'vehicle_type')
  NearbyDriverVehicleTypeEnum get vehicleType;
  // enum vehicleTypeEnum {  motorcycle,  car,  tricycle,  };

  @BuiltValueField(wireName: r'rating')
  double? get rating;

  @BuiltValueField(wireName: r'distance_m')
  double? get distanceM;

  @BuiltValueField(wireName: r'location')
  LatLng get location;

  /// Compass bearing in degrees
  @BuiltValueField(wireName: r'heading')
  double? get heading;

  NearbyDriver._();

  factory NearbyDriver([void updates(NearbyDriverBuilder b)]) = _$NearbyDriver;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(NearbyDriverBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<NearbyDriver> get serializer => _$NearbyDriverSerializer();
}

class _$NearbyDriverSerializer implements PrimitiveSerializer<NearbyDriver> {
  @override
  final Iterable<Type> types = const [NearbyDriver, _$NearbyDriver];

  @override
  final String wireName = r'NearbyDriver';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    NearbyDriver object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    if (object.vehicleMake != null) {
      yield r'vehicle_make';
      yield serializers.serialize(
        object.vehicleMake,
        specifiedType: const FullType(String),
      );
    }
    if (object.vehicleModel != null) {
      yield r'vehicle_model';
      yield serializers.serialize(
        object.vehicleModel,
        specifiedType: const FullType(String),
      );
    }
    if (object.vehiclePlate != null) {
      yield r'vehicle_plate';
      yield serializers.serialize(
        object.vehiclePlate,
        specifiedType: const FullType(String),
      );
    }
    yield r'vehicle_type';
    yield serializers.serialize(
      object.vehicleType,
      specifiedType: const FullType(NearbyDriverVehicleTypeEnum),
    );
    if (object.rating != null) {
      yield r'rating';
      yield serializers.serialize(
        object.rating,
        specifiedType: const FullType.nullable(double),
      );
    }
    if (object.distanceM != null) {
      yield r'distance_m';
      yield serializers.serialize(
        object.distanceM,
        specifiedType: const FullType.nullable(double),
      );
    }
    yield r'location';
    yield serializers.serialize(
      object.location,
      specifiedType: const FullType(LatLng),
    );
    if (object.heading != null) {
      yield r'heading';
      yield serializers.serialize(
        object.heading,
        specifiedType: const FullType.nullable(double),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    NearbyDriver object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required NearbyDriverBuilder result,
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
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'vehicle_make':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.vehicleMake = valueDes;
          break;
        case r'vehicle_model':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.vehicleModel = valueDes;
          break;
        case r'vehicle_plate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.vehiclePlate = valueDes;
          break;
        case r'vehicle_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(NearbyDriverVehicleTypeEnum),
          ) as NearbyDriverVehicleTypeEnum;
          result.vehicleType = valueDes;
          break;
        case r'rating':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(double),
          ) as double?;
          if (valueDes == null) continue;
          result.rating = valueDes;
          break;
        case r'distance_m':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(double),
          ) as double?;
          if (valueDes == null) continue;
          result.distanceM = valueDes;
          break;
        case r'location':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(LatLng),
          ) as LatLng;
          result.location.replace(valueDes);
          break;
        case r'heading':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(double),
          ) as double?;
          if (valueDes == null) continue;
          result.heading = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  NearbyDriver deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = NearbyDriverBuilder();
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

class NearbyDriverVehicleTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'motorcycle')
  static const NearbyDriverVehicleTypeEnum motorcycle = _$nearbyDriverVehicleTypeEnum_motorcycle;
  @BuiltValueEnumConst(wireName: r'car')
  static const NearbyDriverVehicleTypeEnum car = _$nearbyDriverVehicleTypeEnum_car;
  @BuiltValueEnumConst(wireName: r'tricycle')
  static const NearbyDriverVehicleTypeEnum tricycle = _$nearbyDriverVehicleTypeEnum_tricycle;

  static Serializer<NearbyDriverVehicleTypeEnum> get serializer => _$nearbyDriverVehicleTypeEnumSerializer;

  const NearbyDriverVehicleTypeEnum._(String name): super(name);

  static BuiltSet<NearbyDriverVehicleTypeEnum> get values => _$nearbyDriverVehicleTypeEnumValues;
  static NearbyDriverVehicleTypeEnum valueOf(String name) => _$nearbyDriverVehicleTypeEnumValueOf(name);
}


// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'heatmap_position.g.dart';

/// HeatmapPosition
///
/// Properties:
/// * [driverId] 
/// * [lat] 
/// * [lng] 
/// * [vehicleType] 
/// * [isAvailable] 
/// * [updatedAt] 
@BuiltValue()
abstract class HeatmapPosition implements Built<HeatmapPosition, HeatmapPositionBuilder> {
  @BuiltValueField(wireName: r'driver_id')
  String? get driverId;

  @BuiltValueField(wireName: r'lat')
  double? get lat;

  @BuiltValueField(wireName: r'lng')
  double? get lng;

  @BuiltValueField(wireName: r'vehicle_type')
  HeatmapPositionVehicleTypeEnum? get vehicleType;
  // enum vehicleTypeEnum {  motorcycle,  tricycle,  car,  };

  @BuiltValueField(wireName: r'is_available')
  bool? get isAvailable;

  @BuiltValueField(wireName: r'updated_at')
  DateTime? get updatedAt;

  HeatmapPosition._();

  factory HeatmapPosition([void updates(HeatmapPositionBuilder b)]) = _$HeatmapPosition;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(HeatmapPositionBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<HeatmapPosition> get serializer => _$HeatmapPositionSerializer();
}

class _$HeatmapPositionSerializer implements PrimitiveSerializer<HeatmapPosition> {
  @override
  final Iterable<Type> types = const [HeatmapPosition, _$HeatmapPosition];

  @override
  final String wireName = r'HeatmapPosition';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    HeatmapPosition object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.driverId != null) {
      yield r'driver_id';
      yield serializers.serialize(
        object.driverId,
        specifiedType: const FullType(String),
      );
    }
    if (object.lat != null) {
      yield r'lat';
      yield serializers.serialize(
        object.lat,
        specifiedType: const FullType(double),
      );
    }
    if (object.lng != null) {
      yield r'lng';
      yield serializers.serialize(
        object.lng,
        specifiedType: const FullType(double),
      );
    }
    if (object.vehicleType != null) {
      yield r'vehicle_type';
      yield serializers.serialize(
        object.vehicleType,
        specifiedType: const FullType(HeatmapPositionVehicleTypeEnum),
      );
    }
    if (object.isAvailable != null) {
      yield r'is_available';
      yield serializers.serialize(
        object.isAvailable,
        specifiedType: const FullType(bool),
      );
    }
    if (object.updatedAt != null) {
      yield r'updated_at';
      yield serializers.serialize(
        object.updatedAt,
        specifiedType: const FullType(DateTime),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    HeatmapPosition object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required HeatmapPositionBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'driver_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.driverId = valueDes;
          break;
        case r'lat':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(double),
          ) as double;
          result.lat = valueDes;
          break;
        case r'lng':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(double),
          ) as double;
          result.lng = valueDes;
          break;
        case r'vehicle_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(HeatmapPositionVehicleTypeEnum),
          ) as HeatmapPositionVehicleTypeEnum;
          result.vehicleType = valueDes;
          break;
        case r'is_available':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isAvailable = valueDes;
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
  HeatmapPosition deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = HeatmapPositionBuilder();
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

class HeatmapPositionVehicleTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'motorcycle')
  static const HeatmapPositionVehicleTypeEnum motorcycle = _$heatmapPositionVehicleTypeEnum_motorcycle;
  @BuiltValueEnumConst(wireName: r'tricycle')
  static const HeatmapPositionVehicleTypeEnum tricycle = _$heatmapPositionVehicleTypeEnum_tricycle;
  @BuiltValueEnumConst(wireName: r'car')
  static const HeatmapPositionVehicleTypeEnum car = _$heatmapPositionVehicleTypeEnum_car;

  static Serializer<HeatmapPositionVehicleTypeEnum> get serializer => _$heatmapPositionVehicleTypeEnumSerializer;

  const HeatmapPositionVehicleTypeEnum._(String name): super(name);

  static BuiltSet<HeatmapPositionVehicleTypeEnum> get values => _$heatmapPositionVehicleTypeEnumValues;
  static HeatmapPositionVehicleTypeEnum valueOf(String name) => _$heatmapPositionVehicleTypeEnumValueOf(name);
}


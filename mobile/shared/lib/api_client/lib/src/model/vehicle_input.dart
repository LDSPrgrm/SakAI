// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'vehicle_input.g.dart';

/// VehicleInput
///
/// Properties:
/// * [make] 
/// * [model] 
/// * [color] 
/// * [plate] 
/// * [vehicleType] 
@BuiltValue()
abstract class VehicleInput implements Built<VehicleInput, VehicleInputBuilder> {
  @BuiltValueField(wireName: r'make')
  String get make;

  @BuiltValueField(wireName: r'model')
  String get model;

  @BuiltValueField(wireName: r'color')
  String get color;

  @BuiltValueField(wireName: r'plate')
  String get plate;

  @BuiltValueField(wireName: r'vehicle_type')
  VehicleInputVehicleTypeEnum get vehicleType;
  // enum vehicleTypeEnum {  motorcycle,  car,  tricycle,  };

  VehicleInput._();

  factory VehicleInput([void updates(VehicleInputBuilder b)]) = _$VehicleInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(VehicleInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<VehicleInput> get serializer => _$VehicleInputSerializer();
}

class _$VehicleInputSerializer implements PrimitiveSerializer<VehicleInput> {
  @override
  final Iterable<Type> types = const [VehicleInput, _$VehicleInput];

  @override
  final String wireName = r'VehicleInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    VehicleInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'make';
    yield serializers.serialize(
      object.make,
      specifiedType: const FullType(String),
    );
    yield r'model';
    yield serializers.serialize(
      object.model,
      specifiedType: const FullType(String),
    );
    yield r'color';
    yield serializers.serialize(
      object.color,
      specifiedType: const FullType(String),
    );
    yield r'plate';
    yield serializers.serialize(
      object.plate,
      specifiedType: const FullType(String),
    );
    yield r'vehicle_type';
    yield serializers.serialize(
      object.vehicleType,
      specifiedType: const FullType(VehicleInputVehicleTypeEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    VehicleInput object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required VehicleInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'make':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.make = valueDes;
          break;
        case r'model':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.model = valueDes;
          break;
        case r'color':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.color = valueDes;
          break;
        case r'plate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.plate = valueDes;
          break;
        case r'vehicle_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(VehicleInputVehicleTypeEnum),
          ) as VehicleInputVehicleTypeEnum;
          result.vehicleType = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  VehicleInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = VehicleInputBuilder();
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

class VehicleInputVehicleTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'motorcycle')
  static const VehicleInputVehicleTypeEnum motorcycle = _$vehicleInputVehicleTypeEnum_motorcycle;
  @BuiltValueEnumConst(wireName: r'car')
  static const VehicleInputVehicleTypeEnum car = _$vehicleInputVehicleTypeEnum_car;
  @BuiltValueEnumConst(wireName: r'tricycle')
  static const VehicleInputVehicleTypeEnum tricycle = _$vehicleInputVehicleTypeEnum_tricycle;

  static Serializer<VehicleInputVehicleTypeEnum> get serializer => _$vehicleInputVehicleTypeEnumSerializer;

  const VehicleInputVehicleTypeEnum._(String name): super(name);

  static BuiltSet<VehicleInputVehicleTypeEnum> get values => _$vehicleInputVehicleTypeEnumValues;
  static VehicleInputVehicleTypeEnum valueOf(String name) => _$vehicleInputVehicleTypeEnumValueOf(name);
}


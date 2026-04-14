//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'vehicle_info.g.dart';

/// Vehicle details for a driver. Displayed to passengers after match.
///
/// Properties:
/// * [make] 
/// * [model] 
/// * [color] 
/// * [plate] 
@BuiltValue()
abstract class VehicleInfo implements Built<VehicleInfo, VehicleInfoBuilder> {
  @BuiltValueField(wireName: r'make')
  String get make;

  @BuiltValueField(wireName: r'model')
  String get model;

  @BuiltValueField(wireName: r'color')
  String get color;

  @BuiltValueField(wireName: r'plate')
  String get plate;

  VehicleInfo._();

  factory VehicleInfo([void updates(VehicleInfoBuilder b)]) = _$VehicleInfo;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(VehicleInfoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<VehicleInfo> get serializer => _$VehicleInfoSerializer();
}

class _$VehicleInfoSerializer implements PrimitiveSerializer<VehicleInfo> {
  @override
  final Iterable<Type> types = const [VehicleInfo, _$VehicleInfo];

  @override
  final String wireName = r'VehicleInfo';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    VehicleInfo object, {
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
  }

  @override
  Object serialize(
    Serializers serializers,
    VehicleInfo object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required VehicleInfoBuilder result,
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  VehicleInfo deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = VehicleInfoBuilder();
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


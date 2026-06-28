// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sakai_api_client/src/model/surge_zone.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'service_area_input.g.dart';

/// ServiceAreaInput
///
/// Properties:
/// * [name] 
/// * [lguCode] 
/// * [boundary] 
/// * [active] 
@BuiltValue()
abstract class ServiceAreaInput implements Built<ServiceAreaInput, ServiceAreaInputBuilder> {
  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'lgu_code')
  String? get lguCode;

  @BuiltValueField(wireName: r'boundary')
  SurgeZone get boundary;

  @BuiltValueField(wireName: r'active')
  bool? get active;

  ServiceAreaInput._();

  factory ServiceAreaInput([void updates(ServiceAreaInputBuilder b)]) = _$ServiceAreaInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ServiceAreaInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ServiceAreaInput> get serializer => _$ServiceAreaInputSerializer();
}

class _$ServiceAreaInputSerializer implements PrimitiveSerializer<ServiceAreaInput> {
  @override
  final Iterable<Type> types = const [ServiceAreaInput, _$ServiceAreaInput];

  @override
  final String wireName = r'ServiceAreaInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ServiceAreaInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    if (object.lguCode != null) {
      yield r'lgu_code';
      yield serializers.serialize(
        object.lguCode,
        specifiedType: const FullType(String),
      );
    }
    yield r'boundary';
    yield serializers.serialize(
      object.boundary,
      specifiedType: const FullType(SurgeZone),
    );
    if (object.active != null) {
      yield r'active';
      yield serializers.serialize(
        object.active,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ServiceAreaInput object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ServiceAreaInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'lgu_code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.lguCode = valueDes;
          break;
        case r'boundary':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SurgeZone),
          ) as SurgeZone;
          result.boundary.replace(valueDes);
          break;
        case r'active':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.active = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ServiceAreaInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ServiceAreaInputBuilder();
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


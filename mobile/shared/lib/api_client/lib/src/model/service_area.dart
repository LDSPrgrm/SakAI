// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sakai_api_client/src/model/surge_zone.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'service_area.g.dart';

/// ServiceArea
///
/// Properties:
/// * [id] 
/// * [name] 
/// * [lguCode] 
/// * [boundary] 
/// * [active] 
/// * [createdAt] 
/// * [updatedAt] 
@BuiltValue()
abstract class ServiceArea implements Built<ServiceArea, ServiceAreaBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'lgu_code')
  String? get lguCode;

  @BuiltValueField(wireName: r'boundary')
  SurgeZone get boundary;

  @BuiltValueField(wireName: r'active')
  bool get active;

  @BuiltValueField(wireName: r'created_at')
  DateTime? get createdAt;

  @BuiltValueField(wireName: r'updated_at')
  DateTime? get updatedAt;

  ServiceArea._();

  factory ServiceArea([void updates(ServiceAreaBuilder b)]) = _$ServiceArea;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ServiceAreaBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ServiceArea> get serializer => _$ServiceAreaSerializer();
}

class _$ServiceAreaSerializer implements PrimitiveSerializer<ServiceArea> {
  @override
  final Iterable<Type> types = const [ServiceArea, _$ServiceArea];

  @override
  final String wireName = r'ServiceArea';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ServiceArea object, {
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
    yield r'active';
    yield serializers.serialize(
      object.active,
      specifiedType: const FullType(bool),
    );
    if (object.createdAt != null) {
      yield r'created_at';
      yield serializers.serialize(
        object.createdAt,
        specifiedType: const FullType(DateTime),
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
    ServiceArea object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ServiceAreaBuilder result,
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
  ServiceArea deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ServiceAreaBuilder();
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


// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'health_response_dependencies.g.dart';

/// Health of critical dependencies
///
/// Properties:
/// * [database] 
/// * [redis] 
@BuiltValue()
abstract class HealthResponseDependencies implements Built<HealthResponseDependencies, HealthResponseDependenciesBuilder> {
  @BuiltValueField(wireName: r'database')
  HealthResponseDependenciesDatabaseEnum? get database;
  // enum databaseEnum {  ok,  down,  };

  @BuiltValueField(wireName: r'redis')
  HealthResponseDependenciesRedisEnum? get redis;
  // enum redisEnum {  ok,  down,  };

  HealthResponseDependencies._();

  factory HealthResponseDependencies([void updates(HealthResponseDependenciesBuilder b)]) = _$HealthResponseDependencies;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(HealthResponseDependenciesBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<HealthResponseDependencies> get serializer => _$HealthResponseDependenciesSerializer();
}

class _$HealthResponseDependenciesSerializer implements PrimitiveSerializer<HealthResponseDependencies> {
  @override
  final Iterable<Type> types = const [HealthResponseDependencies, _$HealthResponseDependencies];

  @override
  final String wireName = r'HealthResponseDependencies';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    HealthResponseDependencies object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.database != null) {
      yield r'database';
      yield serializers.serialize(
        object.database,
        specifiedType: const FullType(HealthResponseDependenciesDatabaseEnum),
      );
    }
    if (object.redis != null) {
      yield r'redis';
      yield serializers.serialize(
        object.redis,
        specifiedType: const FullType(HealthResponseDependenciesRedisEnum),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    HealthResponseDependencies object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required HealthResponseDependenciesBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'database':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(HealthResponseDependenciesDatabaseEnum),
          ) as HealthResponseDependenciesDatabaseEnum;
          result.database = valueDes;
          break;
        case r'redis':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(HealthResponseDependenciesRedisEnum),
          ) as HealthResponseDependenciesRedisEnum;
          result.redis = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  HealthResponseDependencies deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = HealthResponseDependenciesBuilder();
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

class HealthResponseDependenciesDatabaseEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'ok')
  static const HealthResponseDependenciesDatabaseEnum ok = _$healthResponseDependenciesDatabaseEnum_ok;
  @BuiltValueEnumConst(wireName: r'down')
  static const HealthResponseDependenciesDatabaseEnum down = _$healthResponseDependenciesDatabaseEnum_down;

  static Serializer<HealthResponseDependenciesDatabaseEnum> get serializer => _$healthResponseDependenciesDatabaseEnumSerializer;

  const HealthResponseDependenciesDatabaseEnum._(String name): super(name);

  static BuiltSet<HealthResponseDependenciesDatabaseEnum> get values => _$healthResponseDependenciesDatabaseEnumValues;
  static HealthResponseDependenciesDatabaseEnum valueOf(String name) => _$healthResponseDependenciesDatabaseEnumValueOf(name);
}

class HealthResponseDependenciesRedisEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'ok')
  static const HealthResponseDependenciesRedisEnum ok = _$healthResponseDependenciesRedisEnum_ok;
  @BuiltValueEnumConst(wireName: r'down')
  static const HealthResponseDependenciesRedisEnum down = _$healthResponseDependenciesRedisEnum_down;

  static Serializer<HealthResponseDependenciesRedisEnum> get serializer => _$healthResponseDependenciesRedisEnumSerializer;

  const HealthResponseDependenciesRedisEnum._(String name): super(name);

  static BuiltSet<HealthResponseDependenciesRedisEnum> get values => _$healthResponseDependenciesRedisEnumValues;
  static HealthResponseDependenciesRedisEnum valueOf(String name) => _$healthResponseDependenciesRedisEnumValueOf(name);
}


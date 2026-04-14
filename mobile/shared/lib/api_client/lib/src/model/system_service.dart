// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'system_service.g.dart';

/// SystemService
///
/// Properties:
/// * [name] 
/// * [status] 
/// * [latencyMs] 
/// * [uptimePct] 
/// * [lastChecked] 
@BuiltValue()
abstract class SystemService implements Built<SystemService, SystemServiceBuilder> {
  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'status')
  SystemServiceStatusEnum? get status;
  // enum statusEnum {  ok,  degraded,  down,  };

  @BuiltValueField(wireName: r'latency_ms')
  int? get latencyMs;

  @BuiltValueField(wireName: r'uptime_pct')
  num? get uptimePct;

  @BuiltValueField(wireName: r'last_checked')
  DateTime? get lastChecked;

  SystemService._();

  factory SystemService([void updates(SystemServiceBuilder b)]) = _$SystemService;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SystemServiceBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SystemService> get serializer => _$SystemServiceSerializer();
}

class _$SystemServiceSerializer implements PrimitiveSerializer<SystemService> {
  @override
  final Iterable<Type> types = const [SystemService, _$SystemService];

  @override
  final String wireName = r'SystemService';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SystemService object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(SystemServiceStatusEnum),
      );
    }
    if (object.latencyMs != null) {
      yield r'latency_ms';
      yield serializers.serialize(
        object.latencyMs,
        specifiedType: const FullType(int),
      );
    }
    if (object.uptimePct != null) {
      yield r'uptime_pct';
      yield serializers.serialize(
        object.uptimePct,
        specifiedType: const FullType(num),
      );
    }
    if (object.lastChecked != null) {
      yield r'last_checked';
      yield serializers.serialize(
        object.lastChecked,
        specifiedType: const FullType(DateTime),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SystemService object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SystemServiceBuilder result,
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
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SystemServiceStatusEnum),
          ) as SystemServiceStatusEnum;
          result.status = valueDes;
          break;
        case r'latency_ms':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.latencyMs = valueDes;
          break;
        case r'uptime_pct':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.uptimePct = valueDes;
          break;
        case r'last_checked':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.lastChecked = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SystemService deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SystemServiceBuilder();
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

class SystemServiceStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'ok')
  static const SystemServiceStatusEnum ok = _$systemServiceStatusEnum_ok;
  @BuiltValueEnumConst(wireName: r'degraded')
  static const SystemServiceStatusEnum degraded = _$systemServiceStatusEnum_degraded;
  @BuiltValueEnumConst(wireName: r'down')
  static const SystemServiceStatusEnum down = _$systemServiceStatusEnum_down;

  static Serializer<SystemServiceStatusEnum> get serializer => _$systemServiceStatusEnumSerializer;

  const SystemServiceStatusEnum._(String name): super(name);

  static BuiltSet<SystemServiceStatusEnum> get values => _$systemServiceStatusEnumValues;
  static SystemServiceStatusEnum valueOf(String name) => _$systemServiceStatusEnumValueOf(name);
}


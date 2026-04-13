// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'integration_test_result.g.dart';

/// IntegrationTestResult
///
/// Properties:
/// * [service] 
/// * [status] 
/// * [latencyMs] 
/// * [message] 
@BuiltValue()
abstract class IntegrationTestResult implements Built<IntegrationTestResult, IntegrationTestResultBuilder> {
  @BuiltValueField(wireName: r'service')
  String? get service;

  @BuiltValueField(wireName: r'status')
  IntegrationTestResultStatusEnum? get status;
  // enum statusEnum {  ok,  failed,  };

  @BuiltValueField(wireName: r'latency_ms')
  int? get latencyMs;

  @BuiltValueField(wireName: r'message')
  String? get message;

  IntegrationTestResult._();

  factory IntegrationTestResult([void updates(IntegrationTestResultBuilder b)]) = _$IntegrationTestResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(IntegrationTestResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<IntegrationTestResult> get serializer => _$IntegrationTestResultSerializer();
}

class _$IntegrationTestResultSerializer implements PrimitiveSerializer<IntegrationTestResult> {
  @override
  final Iterable<Type> types = const [IntegrationTestResult, _$IntegrationTestResult];

  @override
  final String wireName = r'IntegrationTestResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    IntegrationTestResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.service != null) {
      yield r'service';
      yield serializers.serialize(
        object.service,
        specifiedType: const FullType(String),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(IntegrationTestResultStatusEnum),
      );
    }
    if (object.latencyMs != null) {
      yield r'latency_ms';
      yield serializers.serialize(
        object.latencyMs,
        specifiedType: const FullType(int),
      );
    }
    if (object.message != null) {
      yield r'message';
      yield serializers.serialize(
        object.message,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    IntegrationTestResult object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required IntegrationTestResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'service':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.service = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(IntegrationTestResultStatusEnum),
          ) as IntegrationTestResultStatusEnum;
          result.status = valueDes;
          break;
        case r'latency_ms':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.latencyMs = valueDes;
          break;
        case r'message':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.message = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  IntegrationTestResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = IntegrationTestResultBuilder();
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

class IntegrationTestResultStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'ok')
  static const IntegrationTestResultStatusEnum ok = _$integrationTestResultStatusEnum_ok;
  @BuiltValueEnumConst(wireName: r'failed')
  static const IntegrationTestResultStatusEnum failed = _$integrationTestResultStatusEnum_failed;

  static Serializer<IntegrationTestResultStatusEnum> get serializer => _$integrationTestResultStatusEnumSerializer;

  const IntegrationTestResultStatusEnum._(String name): super(name);

  static BuiltSet<IntegrationTestResultStatusEnum> get values => _$integrationTestResultStatusEnumValues;
  static IntegrationTestResultStatusEnum valueOf(String name) => _$integrationTestResultStatusEnumValueOf(name);
}


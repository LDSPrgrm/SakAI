// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'integration.g.dart';

/// Integration
///
/// Properties:
/// * [service] 
/// * [status] 
/// * [lastSync] 
/// * [config] 
@BuiltValue()
abstract class Integration implements Built<Integration, IntegrationBuilder> {
  @BuiltValueField(wireName: r'service')
  String? get service;

  @BuiltValueField(wireName: r'status')
  IntegrationStatusEnum? get status;
  // enum statusEnum {  active,  degraded,  offline,  };

  @BuiltValueField(wireName: r'last_sync')
  DateTime? get lastSync;

  @BuiltValueField(wireName: r'config')
  BuiltMap<String, String>? get config;

  Integration._();

  factory Integration([void updates(IntegrationBuilder b)]) = _$Integration;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(IntegrationBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Integration> get serializer => _$IntegrationSerializer();
}

class _$IntegrationSerializer implements PrimitiveSerializer<Integration> {
  @override
  final Iterable<Type> types = const [Integration, _$Integration];

  @override
  final String wireName = r'Integration';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Integration object, {
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
        specifiedType: const FullType(IntegrationStatusEnum),
      );
    }
    if (object.lastSync != null) {
      yield r'last_sync';
      yield serializers.serialize(
        object.lastSync,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.config != null) {
      yield r'config';
      yield serializers.serialize(
        object.config,
        specifiedType: const FullType(BuiltMap, [FullType(String), FullType(String)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    Integration object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required IntegrationBuilder result,
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
            specifiedType: const FullType(IntegrationStatusEnum),
          ) as IntegrationStatusEnum;
          result.status = valueDes;
          break;
        case r'last_sync':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.lastSync = valueDes;
          break;
        case r'config':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType(String)]),
          ) as BuiltMap<String, String>;
          result.config.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Integration deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = IntegrationBuilder();
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

class IntegrationStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'active')
  static const IntegrationStatusEnum active = _$integrationStatusEnum_active;
  @BuiltValueEnumConst(wireName: r'degraded')
  static const IntegrationStatusEnum degraded = _$integrationStatusEnum_degraded;
  @BuiltValueEnumConst(wireName: r'offline')
  static const IntegrationStatusEnum offline = _$integrationStatusEnum_offline;

  static Serializer<IntegrationStatusEnum> get serializer => _$integrationStatusEnumSerializer;

  const IntegrationStatusEnum._(String name): super(name);

  static BuiltSet<IntegrationStatusEnum> get values => _$integrationStatusEnumValues;
  static IntegrationStatusEnum valueOf(String name) => _$integrationStatusEnumValueOf(name);
}


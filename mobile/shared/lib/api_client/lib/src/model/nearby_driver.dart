//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'nearby_driver.g.dart';

/// NearbyDriver
///
/// Properties:
/// * [id] 
/// * [provider] 
/// * [configFields] - API keys and settings — sensitive fields shown masked (last 4 chars)
/// * [isActive] 
/// * [updatedAt] 
@BuiltValue()
abstract class NearbyDriver implements Built<NearbyDriver, NearbyDriverBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'provider')
  NearbyDriverProviderEnum? get provider;
  // enum providerEnum {  gcash,  paymaya,  card,  cash,  };

  /// API keys and settings — sensitive fields shown masked (last 4 chars)
  @BuiltValueField(wireName: r'config_fields')
  BuiltMap<String, String>? get configFields;

  @BuiltValueField(wireName: r'is_active')
  bool? get isActive;

  @BuiltValueField(wireName: r'updated_at')
  DateTime? get updatedAt;

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
    if (object.provider != null) {
      yield r'provider';
      yield serializers.serialize(
        object.provider,
        specifiedType: const FullType(NearbyDriverProviderEnum),
      );
    }
    if (object.configFields != null) {
      yield r'config_fields';
      yield serializers.serialize(
        object.configFields,
        specifiedType: const FullType(BuiltMap, [FullType(String), FullType(String)]),
      );
    }
    if (object.isActive != null) {
      yield r'is_active';
      yield serializers.serialize(
        object.isActive,
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
        case r'provider':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(NearbyDriverProviderEnum),
          ) as NearbyDriverProviderEnum;
          result.provider = valueDes;
          break;
        case r'config_fields':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType(String)]),
          ) as BuiltMap<String, String>;
          result.configFields.replace(valueDes);
          break;
        case r'is_active':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isActive = valueDes;
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

class NearbyDriverProviderEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'gcash')
  static const NearbyDriverProviderEnum gcash = _$nearbyDriverProviderEnum_gcash;
  @BuiltValueEnumConst(wireName: r'paymaya')
  static const NearbyDriverProviderEnum paymaya = _$nearbyDriverProviderEnum_paymaya;
  @BuiltValueEnumConst(wireName: r'card')
  static const NearbyDriverProviderEnum card = _$nearbyDriverProviderEnum_card;
  @BuiltValueEnumConst(wireName: r'cash')
  static const NearbyDriverProviderEnum cash = _$nearbyDriverProviderEnum_cash;

  static Serializer<NearbyDriverProviderEnum> get serializer => _$nearbyDriverProviderEnumSerializer;

  const NearbyDriverProviderEnum._(String name): super(name);

  static BuiltSet<NearbyDriverProviderEnum> get values => _$nearbyDriverProviderEnumValues;
  static NearbyDriverProviderEnum valueOf(String name) => _$nearbyDriverProviderEnumValueOf(name);
}


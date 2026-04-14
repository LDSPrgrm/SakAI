//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'update_payment_config_request.g.dart';

/// UpdatePaymentConfigRequest
///
/// Properties:
/// * [configFields] 
/// * [isActive] 
@BuiltValue()
abstract class UpdatePaymentConfigRequest implements Built<UpdatePaymentConfigRequest, UpdatePaymentConfigRequestBuilder> {
  @BuiltValueField(wireName: r'config_fields')
  BuiltMap<String, String>? get configFields;

  @BuiltValueField(wireName: r'is_active')
  bool? get isActive;

  UpdatePaymentConfigRequest._();

  factory UpdatePaymentConfigRequest([void updates(UpdatePaymentConfigRequestBuilder b)]) = _$UpdatePaymentConfigRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UpdatePaymentConfigRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UpdatePaymentConfigRequest> get serializer => _$UpdatePaymentConfigRequestSerializer();
}

class _$UpdatePaymentConfigRequestSerializer implements PrimitiveSerializer<UpdatePaymentConfigRequest> {
  @override
  final Iterable<Type> types = const [UpdatePaymentConfigRequest, _$UpdatePaymentConfigRequest];

  @override
  final String wireName = r'UpdatePaymentConfigRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UpdatePaymentConfigRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
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
  }

  @override
  Object serialize(
    Serializers serializers,
    UpdatePaymentConfigRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UpdatePaymentConfigRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UpdatePaymentConfigRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UpdatePaymentConfigRequestBuilder();
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


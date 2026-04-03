//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_update_feature_flag_request.g.dart';

/// AdminUpdateFeatureFlagRequest
///
/// Properties:
/// * [enabled] 
@BuiltValue()
abstract class AdminUpdateFeatureFlagRequest implements Built<AdminUpdateFeatureFlagRequest, AdminUpdateFeatureFlagRequestBuilder> {
  @BuiltValueField(wireName: r'enabled')
  bool get enabled;

  AdminUpdateFeatureFlagRequest._();

  factory AdminUpdateFeatureFlagRequest([void updates(AdminUpdateFeatureFlagRequestBuilder b)]) = _$AdminUpdateFeatureFlagRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminUpdateFeatureFlagRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminUpdateFeatureFlagRequest> get serializer => _$AdminUpdateFeatureFlagRequestSerializer();
}

class _$AdminUpdateFeatureFlagRequestSerializer implements PrimitiveSerializer<AdminUpdateFeatureFlagRequest> {
  @override
  final Iterable<Type> types = const [AdminUpdateFeatureFlagRequest, _$AdminUpdateFeatureFlagRequest];

  @override
  final String wireName = r'AdminUpdateFeatureFlagRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminUpdateFeatureFlagRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'enabled';
    yield serializers.serialize(
      object.enabled,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminUpdateFeatureFlagRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminUpdateFeatureFlagRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'enabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.enabled = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminUpdateFeatureFlagRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminUpdateFeatureFlagRequestBuilder();
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


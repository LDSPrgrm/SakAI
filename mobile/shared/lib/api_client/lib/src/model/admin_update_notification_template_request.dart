// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_update_notification_template_request.g.dart';

/// AdminUpdateNotificationTemplateRequest
///
/// Properties:
/// * [body] 
@BuiltValue()
abstract class AdminUpdateNotificationTemplateRequest implements Built<AdminUpdateNotificationTemplateRequest, AdminUpdateNotificationTemplateRequestBuilder> {
  @BuiltValueField(wireName: r'body')
  String get body;

  AdminUpdateNotificationTemplateRequest._();

  factory AdminUpdateNotificationTemplateRequest([void updates(AdminUpdateNotificationTemplateRequestBuilder b)]) = _$AdminUpdateNotificationTemplateRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminUpdateNotificationTemplateRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminUpdateNotificationTemplateRequest> get serializer => _$AdminUpdateNotificationTemplateRequestSerializer();
}

class _$AdminUpdateNotificationTemplateRequestSerializer implements PrimitiveSerializer<AdminUpdateNotificationTemplateRequest> {
  @override
  final Iterable<Type> types = const [AdminUpdateNotificationTemplateRequest, _$AdminUpdateNotificationTemplateRequest];

  @override
  final String wireName = r'AdminUpdateNotificationTemplateRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminUpdateNotificationTemplateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'body';
    yield serializers.serialize(
      object.body,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminUpdateNotificationTemplateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminUpdateNotificationTemplateRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'body':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.body = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminUpdateNotificationTemplateRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminUpdateNotificationTemplateRequestBuilder();
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


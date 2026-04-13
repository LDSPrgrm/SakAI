// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'notification_template.g.dart';

/// NotificationTemplate
///
/// Properties:
/// * [event] 
/// * [channel] 
/// * [subject] 
/// * [body] 
@BuiltValue()
abstract class NotificationTemplate implements Built<NotificationTemplate, NotificationTemplateBuilder> {
  @BuiltValueField(wireName: r'event')
  String? get event;

  @BuiltValueField(wireName: r'channel')
  NotificationTemplateChannelEnum? get channel;
  // enum channelEnum {  email,  sms,  push,  };

  @BuiltValueField(wireName: r'subject')
  String? get subject;

  @BuiltValueField(wireName: r'body')
  String? get body;

  NotificationTemplate._();

  factory NotificationTemplate([void updates(NotificationTemplateBuilder b)]) = _$NotificationTemplate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(NotificationTemplateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<NotificationTemplate> get serializer => _$NotificationTemplateSerializer();
}

class _$NotificationTemplateSerializer implements PrimitiveSerializer<NotificationTemplate> {
  @override
  final Iterable<Type> types = const [NotificationTemplate, _$NotificationTemplate];

  @override
  final String wireName = r'NotificationTemplate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    NotificationTemplate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.event != null) {
      yield r'event';
      yield serializers.serialize(
        object.event,
        specifiedType: const FullType(String),
      );
    }
    if (object.channel != null) {
      yield r'channel';
      yield serializers.serialize(
        object.channel,
        specifiedType: const FullType(NotificationTemplateChannelEnum),
      );
    }
    if (object.subject != null) {
      yield r'subject';
      yield serializers.serialize(
        object.subject,
        specifiedType: const FullType(String),
      );
    }
    if (object.body != null) {
      yield r'body';
      yield serializers.serialize(
        object.body,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    NotificationTemplate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required NotificationTemplateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'event':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.event = valueDes;
          break;
        case r'channel':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(NotificationTemplateChannelEnum),
          ) as NotificationTemplateChannelEnum;
          result.channel = valueDes;
          break;
        case r'subject':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.subject = valueDes;
          break;
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
  NotificationTemplate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = NotificationTemplateBuilder();
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

class NotificationTemplateChannelEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'email')
  static const NotificationTemplateChannelEnum email = _$notificationTemplateChannelEnum_email;
  @BuiltValueEnumConst(wireName: r'sms')
  static const NotificationTemplateChannelEnum sms = _$notificationTemplateChannelEnum_sms;
  @BuiltValueEnumConst(wireName: r'push')
  static const NotificationTemplateChannelEnum push = _$notificationTemplateChannelEnum_push;

  static Serializer<NotificationTemplateChannelEnum> get serializer => _$notificationTemplateChannelEnumSerializer;

  const NotificationTemplateChannelEnum._(String name): super(name);

  static BuiltSet<NotificationTemplateChannelEnum> get values => _$notificationTemplateChannelEnumValues;
  static NotificationTemplateChannelEnum valueOf(String name) => _$notificationTemplateChannelEnumValueOf(name);
}


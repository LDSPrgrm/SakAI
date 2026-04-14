// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ws_envelope.g.dart';

/// Wrapper for all WebSocket messages
///
/// Properties:
/// * [event] - Event name
/// * [payload] - Event-specific payload — see schemas below
@BuiltValue()
abstract class WsEnvelope implements Built<WsEnvelope, WsEnvelopeBuilder> {
  /// Event name
  @BuiltValueField(wireName: r'event')
  String get event;

  /// Event-specific payload — see schemas below
  @BuiltValueField(wireName: r'payload')
  JsonObject get payload;

  WsEnvelope._();

  factory WsEnvelope([void updates(WsEnvelopeBuilder b)]) = _$WsEnvelope;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WsEnvelopeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WsEnvelope> get serializer => _$WsEnvelopeSerializer();
}

class _$WsEnvelopeSerializer implements PrimitiveSerializer<WsEnvelope> {
  @override
  final Iterable<Type> types = const [WsEnvelope, _$WsEnvelope];

  @override
  final String wireName = r'WsEnvelope';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    WsEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'event';
    yield serializers.serialize(
      object.event,
      specifiedType: const FullType(String),
    );
    yield r'payload';
    yield serializers.serialize(
      object.payload,
      specifiedType: const FullType(JsonObject),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    WsEnvelope object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required WsEnvelopeBuilder result,
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
        case r'payload':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.payload = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  WsEnvelope deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WsEnvelopeBuilder();
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


// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ws_event_conn_welcome.g.dart';

/// **Event:** `conn.welcome` **Direction:** server → client (single-shot on successful upgrade) First server-pushed frame after a successful WebSocket upgrade. Announces the negotiated subprotocol so clients can verify the upgrade before sending replay/ack frames. RFC v2 §4.1. 
///
/// Properties:
/// * [protocol] - Negotiated WebSocket subprotocol. Empty string for v1 clients, `\"sakai.v2\"` for v2. 
/// * [v] - Envelope protocol version supported by the server.
@BuiltValue()
abstract class WsEventConnWelcome implements Built<WsEventConnWelcome, WsEventConnWelcomeBuilder> {
  /// Negotiated WebSocket subprotocol. Empty string for v1 clients, `\"sakai.v2\"` for v2. 
  @BuiltValueField(wireName: r'protocol')
  String? get protocol;

  /// Envelope protocol version supported by the server.
  @BuiltValueField(wireName: r'v')
  int get v;

  WsEventConnWelcome._();

  factory WsEventConnWelcome([void updates(WsEventConnWelcomeBuilder b)]) = _$WsEventConnWelcome;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WsEventConnWelcomeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WsEventConnWelcome> get serializer => _$WsEventConnWelcomeSerializer();
}

class _$WsEventConnWelcomeSerializer implements PrimitiveSerializer<WsEventConnWelcome> {
  @override
  final Iterable<Type> types = const [WsEventConnWelcome, _$WsEventConnWelcome];

  @override
  final String wireName = r'WsEventConnWelcome';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    WsEventConnWelcome object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.protocol != null) {
      yield r'protocol';
      yield serializers.serialize(
        object.protocol,
        specifiedType: const FullType(String),
      );
    }
    yield r'v';
    yield serializers.serialize(
      object.v,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    WsEventConnWelcome object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required WsEventConnWelcomeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'protocol':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.protocol = valueDes;
          break;
        case r'v':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.v = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  WsEventConnWelcome deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WsEventConnWelcomeBuilder();
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


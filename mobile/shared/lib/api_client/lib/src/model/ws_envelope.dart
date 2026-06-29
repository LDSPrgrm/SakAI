// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sakai_api_client/src/model/ws_envelope_payload.dart';
import 'package:sakai_api_client/src/model/ws_event_type.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ws_envelope.g.dart';

/// Wrapper for all WebSocket messages. The `event` field selects which payload schema in the oneOf below applies — clients should validate against the matching schema after dispatching on `event`.  v2 fields (`v`, `seq`, `corr_id`, `ack_required`) are populated when the client negotiated the `sakai.v2` subprotocol (RFC v2 §4). v1 clients see them absent. 
///
/// Properties:
/// * [event] 
/// * [payload] 
/// * [timestamp] - RFC3339 UTC timestamp stamped by the server. Optional for backward compatibility — older servers omit it. 
/// * [eventId] - UUIDv7 stamped by the server. Enables client-side idempotency. Optional for backward compatibility. 
/// * [v] - Envelope protocol version. Present only when the client negotiated the `sakai.v2` subprotocol. RFC v2 §4.1. 
/// * [seq] - Monotonic per-user sequence number. Clients use this to detect gaps and request replay. v2-only. RFC v2 §4.2. 
/// * [corrId] - Correlation ID propagated from the originating HTTP request (or internal job). Lets clients/operators link a UI event back to the API call that produced it. v2-only. RFC v2 §4.3 / §12.4. 
/// * [ackRequired] - When true, the client must emit `{type:\"ack\", event_id}` after applying the event. Set for critical events (ride.requested, ride.accepted, ride.completed, …). RFC v2 §4.4. 
@BuiltValue()
abstract class WsEnvelope implements Built<WsEnvelope, WsEnvelopeBuilder> {
  @BuiltValueField(wireName: r'event')
  WsEventType get event;
  // enum eventEnum {  ride.requested,  ride.accepted,  ride.declined,  ride.offer_expired,  ride.status_changed,  ride.completed,  ride.cancelled,  ride.sos_triggered,  ride.no_drivers,  ride.state_sync,  incident.assigned,  incident.resolved,  driver.location_updated,  conn.welcome,  };

  @BuiltValueField(wireName: r'payload')
  WsEnvelopePayload get payload;

  /// RFC3339 UTC timestamp stamped by the server. Optional for backward compatibility — older servers omit it. 
  @BuiltValueField(wireName: r'timestamp')
  DateTime? get timestamp;

  /// UUIDv7 stamped by the server. Enables client-side idempotency. Optional for backward compatibility. 
  @BuiltValueField(wireName: r'event_id')
  String? get eventId;

  /// Envelope protocol version. Present only when the client negotiated the `sakai.v2` subprotocol. RFC v2 §4.1. 
  @BuiltValueField(wireName: r'v')
  int? get v;

  /// Monotonic per-user sequence number. Clients use this to detect gaps and request replay. v2-only. RFC v2 §4.2. 
  @BuiltValueField(wireName: r'seq')
  int? get seq;

  /// Correlation ID propagated from the originating HTTP request (or internal job). Lets clients/operators link a UI event back to the API call that produced it. v2-only. RFC v2 §4.3 / §12.4. 
  @BuiltValueField(wireName: r'corr_id')
  String? get corrId;

  /// When true, the client must emit `{type:\"ack\", event_id}` after applying the event. Set for critical events (ride.requested, ride.accepted, ride.completed, …). RFC v2 §4.4. 
  @BuiltValueField(wireName: r'ack_required')
  bool? get ackRequired;

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
      specifiedType: const FullType(WsEventType),
    );
    yield r'payload';
    yield serializers.serialize(
      object.payload,
      specifiedType: const FullType(WsEnvelopePayload),
    );
    if (object.timestamp != null) {
      yield r'timestamp';
      yield serializers.serialize(
        object.timestamp,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.eventId != null) {
      yield r'event_id';
      yield serializers.serialize(
        object.eventId,
        specifiedType: const FullType(String),
      );
    }
    if (object.v != null) {
      yield r'v';
      yield serializers.serialize(
        object.v,
        specifiedType: const FullType(int),
      );
    }
    if (object.seq != null) {
      yield r'seq';
      yield serializers.serialize(
        object.seq,
        specifiedType: const FullType(int),
      );
    }
    if (object.corrId != null) {
      yield r'corr_id';
      yield serializers.serialize(
        object.corrId,
        specifiedType: const FullType(String),
      );
    }
    if (object.ackRequired != null) {
      yield r'ack_required';
      yield serializers.serialize(
        object.ackRequired,
        specifiedType: const FullType(bool),
      );
    }
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
            specifiedType: const FullType(WsEventType),
          ) as WsEventType;
          result.event = valueDes;
          break;
        case r'payload':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(WsEnvelopePayload),
          ) as WsEnvelopePayload;
          result.payload.replace(valueDes);
          break;
        case r'timestamp':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.timestamp = valueDes;
          break;
        case r'event_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.eventId = valueDes;
          break;
        case r'v':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.v = valueDes;
          break;
        case r'seq':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.seq = valueDes;
          break;
        case r'corr_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.corrId = valueDes;
          break;
        case r'ack_required':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.ackRequired = valueDes;
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


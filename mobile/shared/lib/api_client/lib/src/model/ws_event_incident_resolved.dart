// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ws_event_incident_resolved.g.dart';

/// **Event:** `incident.resolved` **Direction:** server → both passenger and driver on the SOS ride Fired when the SOS incident is closed by an operator. Clients should dismiss the emergency banner and may surface `resolution_notes` as an informational toast (PII-redacted upstream). 
///
/// Properties:
/// * [rideId] 
/// * [incidentId] 
/// * [resolutionNotes] - Operator notes. May be redacted before send.
/// * [resolvedAt] 
@BuiltValue()
abstract class WsEventIncidentResolved implements Built<WsEventIncidentResolved, WsEventIncidentResolvedBuilder> {
  @BuiltValueField(wireName: r'ride_id')
  String get rideId;

  @BuiltValueField(wireName: r'incident_id')
  String get incidentId;

  /// Operator notes. May be redacted before send.
  @BuiltValueField(wireName: r'resolution_notes')
  String? get resolutionNotes;

  @BuiltValueField(wireName: r'resolved_at')
  DateTime get resolvedAt;

  WsEventIncidentResolved._();

  factory WsEventIncidentResolved([void updates(WsEventIncidentResolvedBuilder b)]) = _$WsEventIncidentResolved;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WsEventIncidentResolvedBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WsEventIncidentResolved> get serializer => _$WsEventIncidentResolvedSerializer();
}

class _$WsEventIncidentResolvedSerializer implements PrimitiveSerializer<WsEventIncidentResolved> {
  @override
  final Iterable<Type> types = const [WsEventIncidentResolved, _$WsEventIncidentResolved];

  @override
  final String wireName = r'WsEventIncidentResolved';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    WsEventIncidentResolved object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'ride_id';
    yield serializers.serialize(
      object.rideId,
      specifiedType: const FullType(String),
    );
    yield r'incident_id';
    yield serializers.serialize(
      object.incidentId,
      specifiedType: const FullType(String),
    );
    if (object.resolutionNotes != null) {
      yield r'resolution_notes';
      yield serializers.serialize(
        object.resolutionNotes,
        specifiedType: const FullType(String),
      );
    }
    yield r'resolved_at';
    yield serializers.serialize(
      object.resolvedAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    WsEventIncidentResolved object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required WsEventIncidentResolvedBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'ride_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.rideId = valueDes;
          break;
        case r'incident_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.incidentId = valueDes;
          break;
        case r'resolution_notes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.resolutionNotes = valueDes;
          break;
        case r'resolved_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.resolvedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  WsEventIncidentResolved deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WsEventIncidentResolvedBuilder();
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


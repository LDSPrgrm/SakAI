// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sakai_api_client/src/model/incident.dart';
import 'package:sakai_api_client/src/model/incident_status_event.dart';
import 'package:built_collection/built_collection.dart';
import 'package:sakai_api_client/src/model/incident_location_point.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'incident_detail.g.dart';

/// IncidentDetail
///
/// Properties:
/// * [incident] 
/// * [statusHistory] 
/// * [locationTrail] - GPS pings captured during the incident's active window (between created_at and resolved_at). Populated by the driver_location_history write-path while the driver has an unresolved incident; empty when no pings were recorded. 
@BuiltValue()
abstract class IncidentDetail implements Built<IncidentDetail, IncidentDetailBuilder> {
  @BuiltValueField(wireName: r'incident')
  Incident get incident;

  @BuiltValueField(wireName: r'status_history')
  BuiltList<IncidentStatusEvent> get statusHistory;

  /// GPS pings captured during the incident's active window (between created_at and resolved_at). Populated by the driver_location_history write-path while the driver has an unresolved incident; empty when no pings were recorded. 
  @BuiltValueField(wireName: r'location_trail')
  BuiltList<IncidentLocationPoint>? get locationTrail;

  IncidentDetail._();

  factory IncidentDetail([void updates(IncidentDetailBuilder b)]) = _$IncidentDetail;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(IncidentDetailBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<IncidentDetail> get serializer => _$IncidentDetailSerializer();
}

class _$IncidentDetailSerializer implements PrimitiveSerializer<IncidentDetail> {
  @override
  final Iterable<Type> types = const [IncidentDetail, _$IncidentDetail];

  @override
  final String wireName = r'IncidentDetail';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    IncidentDetail object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'incident';
    yield serializers.serialize(
      object.incident,
      specifiedType: const FullType(Incident),
    );
    yield r'status_history';
    yield serializers.serialize(
      object.statusHistory,
      specifiedType: const FullType(BuiltList, [FullType(IncidentStatusEvent)]),
    );
    if (object.locationTrail != null) {
      yield r'location_trail';
      yield serializers.serialize(
        object.locationTrail,
        specifiedType: const FullType(BuiltList, [FullType(IncidentLocationPoint)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    IncidentDetail object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required IncidentDetailBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'incident':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Incident),
          ) as Incident;
          result.incident.replace(valueDes);
          break;
        case r'status_history':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(IncidentStatusEvent)]),
          ) as BuiltList<IncidentStatusEvent>;
          result.statusHistory.replace(valueDes);
          break;
        case r'location_trail':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(IncidentLocationPoint)]),
          ) as BuiltList<IncidentLocationPoint>;
          result.locationTrail.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  IncidentDetail deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = IncidentDetailBuilder();
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


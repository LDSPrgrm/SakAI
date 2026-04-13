// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'incident.g.dart';

/// Incident
///
/// Properties:
/// * [id] 
/// * [rideId] 
/// * [type] 
/// * [severity] - Operator-assigned urgency level
/// * [status] 
/// * [triggeredBy] 
/// * [riderId] 
/// * [riderName] 
/// * [driverId] 
/// * [driverName] 
/// * [assignedTo] 
/// * [createdAt] 
/// * [resolvedAt] 
/// * [resolutionNotes] 
@BuiltValue()
abstract class Incident implements Built<Incident, IncidentBuilder> {
  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'ride_id')
  String? get rideId;

  @BuiltValueField(wireName: r'type')
  IncidentTypeEnum? get type;
  // enum typeEnum {  sos_triggered,  reported_incident,  safety_complaint,  };

  /// Operator-assigned urgency level
  @BuiltValueField(wireName: r'severity')
  IncidentSeverityEnum? get severity;
  // enum severityEnum {  low,  medium,  high,  };

  @BuiltValueField(wireName: r'status')
  IncidentStatusEnum? get status;
  // enum statusEnum {  open,  investigating,  resolved,  escalated,  };

  @BuiltValueField(wireName: r'triggered_by')
  IncidentTriggeredByEnum? get triggeredBy;
  // enum triggeredByEnum {  rider,  driver,  };

  @BuiltValueField(wireName: r'rider_id')
  String? get riderId;

  @BuiltValueField(wireName: r'rider_name')
  String? get riderName;

  @BuiltValueField(wireName: r'driver_id')
  String? get driverId;

  @BuiltValueField(wireName: r'driver_name')
  String? get driverName;

  @BuiltValueField(wireName: r'assigned_to')
  String? get assignedTo;

  @BuiltValueField(wireName: r'created_at')
  DateTime? get createdAt;

  @BuiltValueField(wireName: r'resolved_at')
  DateTime? get resolvedAt;

  @BuiltValueField(wireName: r'resolution_notes')
  String? get resolutionNotes;

  Incident._();

  factory Incident([void updates(IncidentBuilder b)]) = _$Incident;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(IncidentBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Incident> get serializer => _$IncidentSerializer();
}

class _$IncidentSerializer implements PrimitiveSerializer<Incident> {
  @override
  final Iterable<Type> types = const [Incident, _$Incident];

  @override
  final String wireName = r'Incident';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Incident object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
    if (object.rideId != null) {
      yield r'ride_id';
      yield serializers.serialize(
        object.rideId,
        specifiedType: const FullType(String),
      );
    }
    if (object.type != null) {
      yield r'type';
      yield serializers.serialize(
        object.type,
        specifiedType: const FullType(IncidentTypeEnum),
      );
    }
    if (object.severity != null) {
      yield r'severity';
      yield serializers.serialize(
        object.severity,
        specifiedType: const FullType(IncidentSeverityEnum),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(IncidentStatusEnum),
      );
    }
    if (object.triggeredBy != null) {
      yield r'triggered_by';
      yield serializers.serialize(
        object.triggeredBy,
        specifiedType: const FullType(IncidentTriggeredByEnum),
      );
    }
    if (object.riderId != null) {
      yield r'rider_id';
      yield serializers.serialize(
        object.riderId,
        specifiedType: const FullType(String),
      );
    }
    if (object.riderName != null) {
      yield r'rider_name';
      yield serializers.serialize(
        object.riderName,
        specifiedType: const FullType(String),
      );
    }
    if (object.driverId != null) {
      yield r'driver_id';
      yield serializers.serialize(
        object.driverId,
        specifiedType: const FullType(String),
      );
    }
    if (object.driverName != null) {
      yield r'driver_name';
      yield serializers.serialize(
        object.driverName,
        specifiedType: const FullType(String),
      );
    }
    if (object.assignedTo != null) {
      yield r'assigned_to';
      yield serializers.serialize(
        object.assignedTo,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.createdAt != null) {
      yield r'created_at';
      yield serializers.serialize(
        object.createdAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.resolvedAt != null) {
      yield r'resolved_at';
      yield serializers.serialize(
        object.resolvedAt,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
    if (object.resolutionNotes != null) {
      yield r'resolution_notes';
      yield serializers.serialize(
        object.resolutionNotes,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    Incident object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required IncidentBuilder result,
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
        case r'ride_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.rideId = valueDes;
          break;
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(IncidentTypeEnum),
          ) as IncidentTypeEnum;
          result.type = valueDes;
          break;
        case r'severity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(IncidentSeverityEnum),
          ) as IncidentSeverityEnum;
          result.severity = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(IncidentStatusEnum),
          ) as IncidentStatusEnum;
          result.status = valueDes;
          break;
        case r'triggered_by':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(IncidentTriggeredByEnum),
          ) as IncidentTriggeredByEnum;
          result.triggeredBy = valueDes;
          break;
        case r'rider_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.riderId = valueDes;
          break;
        case r'rider_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.riderName = valueDes;
          break;
        case r'driver_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.driverId = valueDes;
          break;
        case r'driver_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.driverName = valueDes;
          break;
        case r'assigned_to':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.assignedTo = valueDes;
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'resolved_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.resolvedAt = valueDes;
          break;
        case r'resolution_notes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.resolutionNotes = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Incident deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = IncidentBuilder();
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

class IncidentTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'sos_triggered')
  static const IncidentTypeEnum sosTriggered = _$incidentTypeEnum_sosTriggered;
  @BuiltValueEnumConst(wireName: r'reported_incident')
  static const IncidentTypeEnum reportedIncident = _$incidentTypeEnum_reportedIncident;
  @BuiltValueEnumConst(wireName: r'safety_complaint')
  static const IncidentTypeEnum safetyComplaint = _$incidentTypeEnum_safetyComplaint;

  static Serializer<IncidentTypeEnum> get serializer => _$incidentTypeEnumSerializer;

  const IncidentTypeEnum._(String name): super(name);

  static BuiltSet<IncidentTypeEnum> get values => _$incidentTypeEnumValues;
  static IncidentTypeEnum valueOf(String name) => _$incidentTypeEnumValueOf(name);
}

class IncidentSeverityEnum extends EnumClass {

  /// Operator-assigned urgency level
  @BuiltValueEnumConst(wireName: r'low')
  static const IncidentSeverityEnum low = _$incidentSeverityEnum_low;
  /// Operator-assigned urgency level
  @BuiltValueEnumConst(wireName: r'medium')
  static const IncidentSeverityEnum medium = _$incidentSeverityEnum_medium;
  /// Operator-assigned urgency level
  @BuiltValueEnumConst(wireName: r'high')
  static const IncidentSeverityEnum high = _$incidentSeverityEnum_high;

  static Serializer<IncidentSeverityEnum> get serializer => _$incidentSeverityEnumSerializer;

  const IncidentSeverityEnum._(String name): super(name);

  static BuiltSet<IncidentSeverityEnum> get values => _$incidentSeverityEnumValues;
  static IncidentSeverityEnum valueOf(String name) => _$incidentSeverityEnumValueOf(name);
}

class IncidentStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'open')
  static const IncidentStatusEnum open = _$incidentStatusEnum_open;
  @BuiltValueEnumConst(wireName: r'investigating')
  static const IncidentStatusEnum investigating = _$incidentStatusEnum_investigating;
  @BuiltValueEnumConst(wireName: r'resolved')
  static const IncidentStatusEnum resolved = _$incidentStatusEnum_resolved;
  @BuiltValueEnumConst(wireName: r'escalated')
  static const IncidentStatusEnum escalated = _$incidentStatusEnum_escalated;

  static Serializer<IncidentStatusEnum> get serializer => _$incidentStatusEnumSerializer;

  const IncidentStatusEnum._(String name): super(name);

  static BuiltSet<IncidentStatusEnum> get values => _$incidentStatusEnumValues;
  static IncidentStatusEnum valueOf(String name) => _$incidentStatusEnumValueOf(name);
}

class IncidentTriggeredByEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'rider')
  static const IncidentTriggeredByEnum rider = _$incidentTriggeredByEnum_rider;
  @BuiltValueEnumConst(wireName: r'driver')
  static const IncidentTriggeredByEnum driver = _$incidentTriggeredByEnum_driver;

  static Serializer<IncidentTriggeredByEnum> get serializer => _$incidentTriggeredByEnumSerializer;

  const IncidentTriggeredByEnum._(String name): super(name);

  static BuiltSet<IncidentTriggeredByEnum> get values => _$incidentTriggeredByEnumValues;
  static IncidentTriggeredByEnum valueOf(String name) => _$incidentTriggeredByEnumValueOf(name);
}


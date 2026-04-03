//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'incident.g.dart';

/// Incident
///
/// Properties:
/// * [id] 
/// * [rideId] 
/// * [type] 
/// * [status] 
/// * [triggeredBy] 
/// * [riderId] 
/// * [driverId] 
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
  String? get type;

  @BuiltValueField(wireName: r'status')
  String? get status;

  @BuiltValueField(wireName: r'triggered_by')
  String? get triggeredBy;

  @BuiltValueField(wireName: r'rider_id')
  String? get riderId;

  @BuiltValueField(wireName: r'driver_id')
  String? get driverId;

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
        specifiedType: const FullType(String),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(String),
      );
    }
    if (object.triggeredBy != null) {
      yield r'triggered_by';
      yield serializers.serialize(
        object.triggeredBy,
        specifiedType: const FullType(String),
      );
    }
    if (object.riderId != null) {
      yield r'rider_id';
      yield serializers.serialize(
        object.riderId,
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
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.resolutionNotes != null) {
      yield r'resolution_notes';
      yield serializers.serialize(
        object.resolutionNotes,
        specifiedType: const FullType(String),
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
            specifiedType: const FullType(String),
          ) as String;
          result.type = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.status = valueDes;
          break;
        case r'triggered_by':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.triggeredBy = valueDes;
          break;
        case r'rider_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.riderId = valueDes;
          break;
        case r'driver_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.driverId = valueDes;
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
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.resolvedAt = valueDes;
          break;
        case r'resolution_notes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
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


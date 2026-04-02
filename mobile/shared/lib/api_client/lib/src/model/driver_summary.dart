//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sakai_api_client/src/model/lat_lng.dart';
import 'package:sakai_api_client/src/model/vehicle_info.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'driver_summary.g.dart';

/// Minimal driver info embedded in ride responses and WebSocket events.
///
/// Properties:
/// * [id] 
/// * [name] 
/// * [vehicle] 
/// * [currentLocation] 
@BuiltValue()
abstract class DriverSummary implements Built<DriverSummary, DriverSummaryBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'vehicle')
  VehicleInfo get vehicle;

  @BuiltValueField(wireName: r'current_location')
  LatLng? get currentLocation;

  DriverSummary._();

  factory DriverSummary([void updates(DriverSummaryBuilder b)]) = _$DriverSummary;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DriverSummaryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DriverSummary> get serializer => _$DriverSummarySerializer();
}

class _$DriverSummarySerializer implements PrimitiveSerializer<DriverSummary> {
  @override
  final Iterable<Type> types = const [DriverSummary, _$DriverSummary];

  @override
  final String wireName = r'DriverSummary';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DriverSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'vehicle';
    yield serializers.serialize(
      object.vehicle,
      specifiedType: const FullType(VehicleInfo),
    );
    if (object.currentLocation != null) {
      yield r'current_location';
      yield serializers.serialize(
        object.currentLocation,
        specifiedType: const FullType(LatLng),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    DriverSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DriverSummaryBuilder result,
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
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'vehicle':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(VehicleInfo),
          ) as VehicleInfo;
          result.vehicle.replace(valueDes);
          break;
        case r'current_location':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(LatLng),
          ) as LatLng;
          result.currentLocation.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DriverSummary deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DriverSummaryBuilder();
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


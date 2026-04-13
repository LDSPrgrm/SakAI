// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sakai_api_client/src/model/lat_lng.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'fare_simulation_request.g.dart';

/// FareSimulationRequest
///
/// Properties:
/// * [vehicleType] 
/// * [origin] 
/// * [destination] 
@BuiltValue()
abstract class FareSimulationRequest implements Built<FareSimulationRequest, FareSimulationRequestBuilder> {
  @BuiltValueField(wireName: r'vehicle_type')
  String get vehicleType;

  @BuiltValueField(wireName: r'origin')
  LatLng get origin;

  @BuiltValueField(wireName: r'destination')
  LatLng get destination;

  FareSimulationRequest._();

  factory FareSimulationRequest([void updates(FareSimulationRequestBuilder b)]) = _$FareSimulationRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FareSimulationRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FareSimulationRequest> get serializer => _$FareSimulationRequestSerializer();
}

class _$FareSimulationRequestSerializer implements PrimitiveSerializer<FareSimulationRequest> {
  @override
  final Iterable<Type> types = const [FareSimulationRequest, _$FareSimulationRequest];

  @override
  final String wireName = r'FareSimulationRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FareSimulationRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'vehicle_type';
    yield serializers.serialize(
      object.vehicleType,
      specifiedType: const FullType(String),
    );
    yield r'origin';
    yield serializers.serialize(
      object.origin,
      specifiedType: const FullType(LatLng),
    );
    yield r'destination';
    yield serializers.serialize(
      object.destination,
      specifiedType: const FullType(LatLng),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    FareSimulationRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required FareSimulationRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'vehicle_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.vehicleType = valueDes;
          break;
        case r'origin':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(LatLng),
          ) as LatLng;
          result.origin.replace(valueDes);
          break;
        case r'destination':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(LatLng),
          ) as LatLng;
          result.destination.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  FareSimulationRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FareSimulationRequestBuilder();
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


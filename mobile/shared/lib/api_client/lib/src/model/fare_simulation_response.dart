// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'fare_simulation_response.g.dart';

/// FareSimulationResponse
///
/// Properties:
/// * [estimatedFare] 
@BuiltValue()
abstract class FareSimulationResponse implements Built<FareSimulationResponse, FareSimulationResponseBuilder> {
  @BuiltValueField(wireName: r'estimated_fare')
  num? get estimatedFare;

  FareSimulationResponse._();

  factory FareSimulationResponse([void updates(FareSimulationResponseBuilder b)]) = _$FareSimulationResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FareSimulationResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FareSimulationResponse> get serializer => _$FareSimulationResponseSerializer();
}

class _$FareSimulationResponseSerializer implements PrimitiveSerializer<FareSimulationResponse> {
  @override
  final Iterable<Type> types = const [FareSimulationResponse, _$FareSimulationResponse];

  @override
  final String wireName = r'FareSimulationResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FareSimulationResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.estimatedFare != null) {
      yield r'estimated_fare';
      yield serializers.serialize(
        object.estimatedFare,
        specifiedType: const FullType(num),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    FareSimulationResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required FareSimulationResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'estimated_fare':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.estimatedFare = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  FareSimulationResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FareSimulationResponseBuilder();
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


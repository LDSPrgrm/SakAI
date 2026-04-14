//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sakai_api_client/src/model/nearby_driver.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'nearby_drivers_response.g.dart';

/// NearbyDriversResponse
///
/// Properties:
/// * [drivers] 
@BuiltValue()
abstract class NearbyDriversResponse implements Built<NearbyDriversResponse, NearbyDriversResponseBuilder> {
  @BuiltValueField(wireName: r'drivers')
  BuiltList<NearbyDriver>? get drivers;

  NearbyDriversResponse._();

  factory NearbyDriversResponse([void updates(NearbyDriversResponseBuilder b)]) = _$NearbyDriversResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(NearbyDriversResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<NearbyDriversResponse> get serializer => _$NearbyDriversResponseSerializer();
}

class _$NearbyDriversResponseSerializer implements PrimitiveSerializer<NearbyDriversResponse> {
  @override
  final Iterable<Type> types = const [NearbyDriversResponse, _$NearbyDriversResponse];

  @override
  final String wireName = r'NearbyDriversResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    NearbyDriversResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.drivers != null) {
      yield r'drivers';
      yield serializers.serialize(
        object.drivers,
        specifiedType: const FullType(BuiltList, [FullType(NearbyDriver)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    NearbyDriversResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required NearbyDriversResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'drivers':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(NearbyDriver)]),
          ) as BuiltList<NearbyDriver>;
          result.drivers.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  NearbyDriversResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = NearbyDriversResponseBuilder();
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


// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sakai_api_client/src/model/nearby_driver.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_nearby_drivers200_response.g.dart';

/// GetNearbyDrivers200Response
///
/// Properties:
/// * [drivers] 
@BuiltValue()
abstract class GetNearbyDrivers200Response implements Built<GetNearbyDrivers200Response, GetNearbyDrivers200ResponseBuilder> {
  @BuiltValueField(wireName: r'drivers')
  BuiltList<NearbyDriver>? get drivers;

  GetNearbyDrivers200Response._();

  factory GetNearbyDrivers200Response([void updates(GetNearbyDrivers200ResponseBuilder b)]) = _$GetNearbyDrivers200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetNearbyDrivers200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetNearbyDrivers200Response> get serializer => _$GetNearbyDrivers200ResponseSerializer();
}

class _$GetNearbyDrivers200ResponseSerializer implements PrimitiveSerializer<GetNearbyDrivers200Response> {
  @override
  final Iterable<Type> types = const [GetNearbyDrivers200Response, _$GetNearbyDrivers200Response];

  @override
  final String wireName = r'GetNearbyDrivers200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetNearbyDrivers200Response object, {
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
    GetNearbyDrivers200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GetNearbyDrivers200ResponseBuilder result,
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
  GetNearbyDrivers200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetNearbyDrivers200ResponseBuilder();
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


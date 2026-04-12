//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sakai_api_client/src/model/service_area.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'service_area_response.g.dart';

/// ServiceAreaResponse
///
/// Properties:
/// * [areas] 
@BuiltValue()
abstract class ServiceAreaResponse implements Built<ServiceAreaResponse, ServiceAreaResponseBuilder> {
  @BuiltValueField(wireName: r'areas')
  BuiltList<ServiceArea>? get areas;

  ServiceAreaResponse._();

  factory ServiceAreaResponse([void updates(ServiceAreaResponseBuilder b)]) = _$ServiceAreaResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ServiceAreaResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ServiceAreaResponse> get serializer => _$ServiceAreaResponseSerializer();
}

class _$ServiceAreaResponseSerializer implements PrimitiveSerializer<ServiceAreaResponse> {
  @override
  final Iterable<Type> types = const [ServiceAreaResponse, _$ServiceAreaResponse];

  @override
  final String wireName = r'ServiceAreaResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ServiceAreaResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.areas != null) {
      yield r'areas';
      yield serializers.serialize(
        object.areas,
        specifiedType: const FullType(BuiltList, [FullType(ServiceArea)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ServiceAreaResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ServiceAreaResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'areas':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(ServiceArea)]),
          ) as BuiltList<ServiceArea>;
          result.areas.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ServiceAreaResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ServiceAreaResponseBuilder();
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


// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sakai_api_client/src/model/pagination_meta.dart';
import 'package:built_collection/built_collection.dart';
import 'package:sakai_api_client/src/model/earnings_item.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'driver_get_earnings200_response.g.dart';

/// DriverGetEarnings200Response
///
/// Properties:
/// * [data] 
/// * [pagination] 
@BuiltValue()
abstract class DriverGetEarnings200Response implements Built<DriverGetEarnings200Response, DriverGetEarnings200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<EarningsItem>? get data;

  @BuiltValueField(wireName: r'pagination')
  PaginationMeta? get pagination;

  DriverGetEarnings200Response._();

  factory DriverGetEarnings200Response([void updates(DriverGetEarnings200ResponseBuilder b)]) = _$DriverGetEarnings200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DriverGetEarnings200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DriverGetEarnings200Response> get serializer => _$DriverGetEarnings200ResponseSerializer();
}

class _$DriverGetEarnings200ResponseSerializer implements PrimitiveSerializer<DriverGetEarnings200Response> {
  @override
  final Iterable<Type> types = const [DriverGetEarnings200Response, _$DriverGetEarnings200Response];

  @override
  final String wireName = r'DriverGetEarnings200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DriverGetEarnings200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(BuiltList, [FullType(EarningsItem)]),
      );
    }
    if (object.pagination != null) {
      yield r'pagination';
      yield serializers.serialize(
        object.pagination,
        specifiedType: const FullType(PaginationMeta),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    DriverGetEarnings200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DriverGetEarnings200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(EarningsItem)]),
          ) as BuiltList<EarningsItem>;
          result.data.replace(valueDes);
          break;
        case r'pagination':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PaginationMeta),
          ) as PaginationMeta;
          result.pagination.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DriverGetEarnings200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DriverGetEarnings200ResponseBuilder();
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


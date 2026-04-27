// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sakai_api_client/src/model/pagination_meta.dart';
import 'package:built_collection/built_collection.dart';
import 'package:sakai_api_client/src/model/ride_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_list_driver_rides200_response.g.dart';

/// AdminListDriverRides200Response
///
/// Properties:
/// * [rides] 
/// * [pagination] 
@BuiltValue()
abstract class AdminListDriverRides200Response implements Built<AdminListDriverRides200Response, AdminListDriverRides200ResponseBuilder> {
  @BuiltValueField(wireName: r'rides')
  BuiltList<RideResponse>? get rides;

  @BuiltValueField(wireName: r'pagination')
  PaginationMeta? get pagination;

  AdminListDriverRides200Response._();

  factory AdminListDriverRides200Response([void updates(AdminListDriverRides200ResponseBuilder b)]) = _$AdminListDriverRides200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminListDriverRides200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminListDriverRides200Response> get serializer => _$AdminListDriverRides200ResponseSerializer();
}

class _$AdminListDriverRides200ResponseSerializer implements PrimitiveSerializer<AdminListDriverRides200Response> {
  @override
  final Iterable<Type> types = const [AdminListDriverRides200Response, _$AdminListDriverRides200Response];

  @override
  final String wireName = r'AdminListDriverRides200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminListDriverRides200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.rides != null) {
      yield r'rides';
      yield serializers.serialize(
        object.rides,
        specifiedType: const FullType(BuiltList, [FullType(RideResponse)]),
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
    AdminListDriverRides200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminListDriverRides200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'rides':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(RideResponse)]),
          ) as BuiltList<RideResponse>;
          result.rides.replace(valueDes);
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
  AdminListDriverRides200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminListDriverRides200ResponseBuilder();
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


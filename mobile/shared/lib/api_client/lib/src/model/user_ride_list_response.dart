// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sakai_api_client/src/model/pagination_meta.dart';
import 'package:built_collection/built_collection.dart';
import 'package:sakai_api_client/src/model/user_ride_item.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'user_ride_list_response.g.dart';

/// UserRideListResponse
///
/// Properties:
/// * [data] 
/// * [pagination] 
@BuiltValue()
abstract class UserRideListResponse implements Built<UserRideListResponse, UserRideListResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<UserRideItem> get data;

  @BuiltValueField(wireName: r'pagination')
  PaginationMeta get pagination;

  UserRideListResponse._();

  factory UserRideListResponse([void updates(UserRideListResponseBuilder b)]) = _$UserRideListResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UserRideListResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UserRideListResponse> get serializer => _$UserRideListResponseSerializer();
}

class _$UserRideListResponseSerializer implements PrimitiveSerializer<UserRideListResponse> {
  @override
  final Iterable<Type> types = const [UserRideListResponse, _$UserRideListResponse];

  @override
  final String wireName = r'UserRideListResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UserRideListResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(UserRideItem)]),
    );
    yield r'pagination';
    yield serializers.serialize(
      object.pagination,
      specifiedType: const FullType(PaginationMeta),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    UserRideListResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UserRideListResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(UserRideItem)]),
          ) as BuiltList<UserRideItem>;
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
  UserRideListResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UserRideListResponseBuilder();
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


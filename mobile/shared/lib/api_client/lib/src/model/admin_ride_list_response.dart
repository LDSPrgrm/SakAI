// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sakai_api_client/src/model/pagination_meta.dart';
import 'package:sakai_api_client/src/model/admin_ride_item.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_ride_list_response.g.dart';

/// AdminRideListResponse
///
/// Properties:
/// * [items] 
/// * [meta] 
@BuiltValue()
abstract class AdminRideListResponse implements Built<AdminRideListResponse, AdminRideListResponseBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<AdminRideItem>? get items;

  @BuiltValueField(wireName: r'meta')
  PaginationMeta? get meta;

  AdminRideListResponse._();

  factory AdminRideListResponse([void updates(AdminRideListResponseBuilder b)]) = _$AdminRideListResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminRideListResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminRideListResponse> get serializer => _$AdminRideListResponseSerializer();
}

class _$AdminRideListResponseSerializer implements PrimitiveSerializer<AdminRideListResponse> {
  @override
  final Iterable<Type> types = const [AdminRideListResponse, _$AdminRideListResponse];

  @override
  final String wireName = r'AdminRideListResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminRideListResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.items != null) {
      yield r'items';
      yield serializers.serialize(
        object.items,
        specifiedType: const FullType(BuiltList, [FullType(AdminRideItem)]),
      );
    }
    if (object.meta != null) {
      yield r'meta';
      yield serializers.serialize(
        object.meta,
        specifiedType: const FullType(PaginationMeta),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminRideListResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminRideListResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(AdminRideItem)]),
          ) as BuiltList<AdminRideItem>;
          result.items.replace(valueDes);
          break;
        case r'meta':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PaginationMeta),
          ) as PaginationMeta;
          result.meta.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminRideListResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminRideListResponseBuilder();
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


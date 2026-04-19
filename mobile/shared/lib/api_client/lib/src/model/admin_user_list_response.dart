// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sakai_api_client/src/model/pagination_meta.dart';
import 'package:sakai_api_client/src/model/user_profile.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_user_list_response.g.dart';

/// AdminUserListResponse
///
/// Properties:
/// * [items] 
/// * [meta] 
@BuiltValue()
abstract class AdminUserListResponse implements Built<AdminUserListResponse, AdminUserListResponseBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<UserProfile>? get items;

  @BuiltValueField(wireName: r'meta')
  PaginationMeta? get meta;

  AdminUserListResponse._();

  factory AdminUserListResponse([void updates(AdminUserListResponseBuilder b)]) = _$AdminUserListResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminUserListResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminUserListResponse> get serializer => _$AdminUserListResponseSerializer();
}

class _$AdminUserListResponseSerializer implements PrimitiveSerializer<AdminUserListResponse> {
  @override
  final Iterable<Type> types = const [AdminUserListResponse, _$AdminUserListResponse];

  @override
  final String wireName = r'AdminUserListResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminUserListResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.items != null) {
      yield r'items';
      yield serializers.serialize(
        object.items,
        specifiedType: const FullType(BuiltList, [FullType(UserProfile)]),
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
    AdminUserListResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminUserListResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(UserProfile)]),
          ) as BuiltList<UserProfile>;
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
  AdminUserListResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminUserListResponseBuilder();
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


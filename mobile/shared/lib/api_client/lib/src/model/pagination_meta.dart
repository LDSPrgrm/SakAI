// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pagination_meta.g.dart';

/// PaginationMeta
///
/// Properties:
/// * [currentPage] 
/// * [limit] 
/// * [totalItems] 
/// * [totalPages] 
@BuiltValue()
abstract class PaginationMeta implements Built<PaginationMeta, PaginationMetaBuilder> {
  @BuiltValueField(wireName: r'current_page')
  int? get currentPage;

  @BuiltValueField(wireName: r'limit')
  int? get limit;

  @BuiltValueField(wireName: r'total_items')
  int? get totalItems;

  @BuiltValueField(wireName: r'total_pages')
  int? get totalPages;

  PaginationMeta._();

  factory PaginationMeta([void updates(PaginationMetaBuilder b)]) = _$PaginationMeta;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PaginationMetaBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PaginationMeta> get serializer => _$PaginationMetaSerializer();
}

class _$PaginationMetaSerializer implements PrimitiveSerializer<PaginationMeta> {
  @override
  final Iterable<Type> types = const [PaginationMeta, _$PaginationMeta];

  @override
  final String wireName = r'PaginationMeta';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PaginationMeta object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.currentPage != null) {
      yield r'current_page';
      yield serializers.serialize(
        object.currentPage,
        specifiedType: const FullType(int),
      );
    }
    if (object.limit != null) {
      yield r'limit';
      yield serializers.serialize(
        object.limit,
        specifiedType: const FullType(int),
      );
    }
    if (object.totalItems != null) {
      yield r'total_items';
      yield serializers.serialize(
        object.totalItems,
        specifiedType: const FullType(int),
      );
    }
    if (object.totalPages != null) {
      yield r'total_pages';
      yield serializers.serialize(
        object.totalPages,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PaginationMeta object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PaginationMetaBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'current_page':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.currentPage = valueDes;
          break;
        case r'limit':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.limit = valueDes;
          break;
        case r'total_items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.totalItems = valueDes;
          break;
        case r'total_pages':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.totalPages = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PaginationMeta deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PaginationMetaBuilder();
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


//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sakai_api_client/src/model/driver_document_response.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'driver_documents_list_response.g.dart';

/// DriverDocumentsListResponse
///
/// Properties:
/// * [documents] 
@BuiltValue()
abstract class DriverDocumentsListResponse implements Built<DriverDocumentsListResponse, DriverDocumentsListResponseBuilder> {
  @BuiltValueField(wireName: r'documents')
  BuiltList<DriverDocumentResponse> get documents;

  DriverDocumentsListResponse._();

  factory DriverDocumentsListResponse([void updates(DriverDocumentsListResponseBuilder b)]) = _$DriverDocumentsListResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DriverDocumentsListResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DriverDocumentsListResponse> get serializer => _$DriverDocumentsListResponseSerializer();
}

class _$DriverDocumentsListResponseSerializer implements PrimitiveSerializer<DriverDocumentsListResponse> {
  @override
  final Iterable<Type> types = const [DriverDocumentsListResponse, _$DriverDocumentsListResponse];

  @override
  final String wireName = r'DriverDocumentsListResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DriverDocumentsListResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'documents';
    yield serializers.serialize(
      object.documents,
      specifiedType: const FullType(BuiltList, [FullType(DriverDocumentResponse)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DriverDocumentsListResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DriverDocumentsListResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'documents':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(DriverDocumentResponse)]),
          ) as BuiltList<DriverDocumentResponse>;
          result.documents.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DriverDocumentsListResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DriverDocumentsListResponseBuilder();
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


//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'batch_approve_request.g.dart';

/// BatchApproveRequest
///
/// Properties:
/// * [ids] 
@BuiltValue()
abstract class BatchApproveRequest implements Built<BatchApproveRequest, BatchApproveRequestBuilder> {
  @BuiltValueField(wireName: r'ids')
  BuiltList<String> get ids;

  BatchApproveRequest._();

  factory BatchApproveRequest([void updates(BatchApproveRequestBuilder b)]) = _$BatchApproveRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BatchApproveRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BatchApproveRequest> get serializer => _$BatchApproveRequestSerializer();
}

class _$BatchApproveRequestSerializer implements PrimitiveSerializer<BatchApproveRequest> {
  @override
  final Iterable<Type> types = const [BatchApproveRequest, _$BatchApproveRequest];

  @override
  final String wireName = r'BatchApproveRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BatchApproveRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'ids';
    yield serializers.serialize(
      object.ids,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BatchApproveRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BatchApproveRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'ids':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.ids.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BatchApproveRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BatchApproveRequestBuilder();
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


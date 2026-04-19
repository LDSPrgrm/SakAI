// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_batch_kyc200_response.g.dart';

/// AdminBatchKyc200Response
///
/// Properties:
/// * [processed] 
@BuiltValue()
abstract class AdminBatchKyc200Response implements Built<AdminBatchKyc200Response, AdminBatchKyc200ResponseBuilder> {
  @BuiltValueField(wireName: r'processed')
  int? get processed;

  AdminBatchKyc200Response._();

  factory AdminBatchKyc200Response([void updates(AdminBatchKyc200ResponseBuilder b)]) = _$AdminBatchKyc200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminBatchKyc200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminBatchKyc200Response> get serializer => _$AdminBatchKyc200ResponseSerializer();
}

class _$AdminBatchKyc200ResponseSerializer implements PrimitiveSerializer<AdminBatchKyc200Response> {
  @override
  final Iterable<Type> types = const [AdminBatchKyc200Response, _$AdminBatchKyc200Response];

  @override
  final String wireName = r'AdminBatchKyc200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminBatchKyc200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.processed != null) {
      yield r'processed';
      yield serializers.serialize(
        object.processed,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminBatchKyc200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminBatchKyc200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'processed':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.processed = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminBatchKyc200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminBatchKyc200ResponseBuilder();
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


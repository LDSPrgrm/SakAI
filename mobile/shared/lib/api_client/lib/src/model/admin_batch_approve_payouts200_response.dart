// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_batch_approve_payouts200_response.g.dart';

/// AdminBatchApprovePayouts200Response
///
/// Properties:
/// * [approved] 
@BuiltValue()
abstract class AdminBatchApprovePayouts200Response implements Built<AdminBatchApprovePayouts200Response, AdminBatchApprovePayouts200ResponseBuilder> {
  @BuiltValueField(wireName: r'approved')
  int? get approved;

  AdminBatchApprovePayouts200Response._();

  factory AdminBatchApprovePayouts200Response([void updates(AdminBatchApprovePayouts200ResponseBuilder b)]) = _$AdminBatchApprovePayouts200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminBatchApprovePayouts200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminBatchApprovePayouts200Response> get serializer => _$AdminBatchApprovePayouts200ResponseSerializer();
}

class _$AdminBatchApprovePayouts200ResponseSerializer implements PrimitiveSerializer<AdminBatchApprovePayouts200Response> {
  @override
  final Iterable<Type> types = const [AdminBatchApprovePayouts200Response, _$AdminBatchApprovePayouts200Response];

  @override
  final String wireName = r'AdminBatchApprovePayouts200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminBatchApprovePayouts200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.approved != null) {
      yield r'approved';
      yield serializers.serialize(
        object.approved,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminBatchApprovePayouts200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminBatchApprovePayouts200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'approved':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.approved = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminBatchApprovePayouts200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminBatchApprovePayouts200ResponseBuilder();
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


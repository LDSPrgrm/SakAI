// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'promotion_validate_request.g.dart';

/// PromotionValidateRequest
///
/// Properties:
/// * [code] 
/// * [rideFare] - Optional fare to check if minimum amount criteria is met
@BuiltValue()
abstract class PromotionValidateRequest implements Built<PromotionValidateRequest, PromotionValidateRequestBuilder> {
  @BuiltValueField(wireName: r'code')
  String get code;

  /// Optional fare to check if minimum amount criteria is met
  @BuiltValueField(wireName: r'rideFare')
  double? get rideFare;

  PromotionValidateRequest._();

  factory PromotionValidateRequest([void updates(PromotionValidateRequestBuilder b)]) = _$PromotionValidateRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PromotionValidateRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PromotionValidateRequest> get serializer => _$PromotionValidateRequestSerializer();
}

class _$PromotionValidateRequestSerializer implements PrimitiveSerializer<PromotionValidateRequest> {
  @override
  final Iterable<Type> types = const [PromotionValidateRequest, _$PromotionValidateRequest];

  @override
  final String wireName = r'PromotionValidateRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PromotionValidateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(String),
    );
    if (object.rideFare != null) {
      yield r'rideFare';
      yield serializers.serialize(
        object.rideFare,
        specifiedType: const FullType.nullable(double),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PromotionValidateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PromotionValidateRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.code = valueDes;
          break;
        case r'rideFare':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(double),
          ) as double?;
          if (valueDes == null) continue;
          result.rideFare = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PromotionValidateRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PromotionValidateRequestBuilder();
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


// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'submit_rating_request.g.dart';

/// SubmitRatingRequest
///
/// Properties:
/// * [stars] - Star rating (1-5)
/// * [feedback] - Optional written feedback (max 500 characters)
@BuiltValue()
abstract class SubmitRatingRequest implements Built<SubmitRatingRequest, SubmitRatingRequestBuilder> {
  /// Star rating (1-5)
  @BuiltValueField(wireName: r'stars')
  int get stars;

  /// Optional written feedback (max 500 characters)
  @BuiltValueField(wireName: r'feedback')
  String? get feedback;

  SubmitRatingRequest._();

  factory SubmitRatingRequest([void updates(SubmitRatingRequestBuilder b)]) = _$SubmitRatingRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SubmitRatingRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SubmitRatingRequest> get serializer => _$SubmitRatingRequestSerializer();
}

class _$SubmitRatingRequestSerializer implements PrimitiveSerializer<SubmitRatingRequest> {
  @override
  final Iterable<Type> types = const [SubmitRatingRequest, _$SubmitRatingRequest];

  @override
  final String wireName = r'SubmitRatingRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SubmitRatingRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'stars';
    yield serializers.serialize(
      object.stars,
      specifiedType: const FullType(int),
    );
    if (object.feedback != null) {
      yield r'feedback';
      yield serializers.serialize(
        object.feedback,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SubmitRatingRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SubmitRatingRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'stars':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.stars = valueDes;
          break;
        case r'feedback':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.feedback = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SubmitRatingRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SubmitRatingRequestBuilder();
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


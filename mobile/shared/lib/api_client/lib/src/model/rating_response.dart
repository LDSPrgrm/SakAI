// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'rating_response.g.dart';

/// RatingResponse
///
/// Properties:
/// * [id] 
/// * [rideId] 
/// * [raterId] - User who gave the rating
/// * [rateeId] - User who received the rating
/// * [stars] 
/// * [feedback] 
/// * [createdAt] 
@BuiltValue()
abstract class RatingResponse implements Built<RatingResponse, RatingResponseBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'rideId')
  String get rideId;

  /// User who gave the rating
  @BuiltValueField(wireName: r'raterId')
  String get raterId;

  /// User who received the rating
  @BuiltValueField(wireName: r'rateeId')
  String get rateeId;

  @BuiltValueField(wireName: r'stars')
  int get stars;

  @BuiltValueField(wireName: r'feedback')
  String? get feedback;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  RatingResponse._();

  factory RatingResponse([void updates(RatingResponseBuilder b)]) = _$RatingResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RatingResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RatingResponse> get serializer => _$RatingResponseSerializer();
}

class _$RatingResponseSerializer implements PrimitiveSerializer<RatingResponse> {
  @override
  final Iterable<Type> types = const [RatingResponse, _$RatingResponse];

  @override
  final String wireName = r'RatingResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RatingResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'rideId';
    yield serializers.serialize(
      object.rideId,
      specifiedType: const FullType(String),
    );
    yield r'raterId';
    yield serializers.serialize(
      object.raterId,
      specifiedType: const FullType(String),
    );
    yield r'rateeId';
    yield serializers.serialize(
      object.rateeId,
      specifiedType: const FullType(String),
    );
    yield r'stars';
    yield serializers.serialize(
      object.stars,
      specifiedType: const FullType(int),
    );
    if (object.feedback != null) {
      yield r'feedback';
      yield serializers.serialize(
        object.feedback,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RatingResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RatingResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'rideId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.rideId = valueDes;
          break;
        case r'raterId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.raterId = valueDes;
          break;
        case r'rateeId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.rateeId = valueDes;
          break;
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
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.feedback = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RatingResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RatingResponseBuilder();
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


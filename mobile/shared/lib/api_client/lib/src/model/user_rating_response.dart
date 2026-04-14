// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'user_rating_response.g.dart';

/// UserRatingResponse
///
/// Properties:
/// * [userId] 
/// * [averageRating] 
/// * [ratingCount] - Total number of ratings received
/// * [lastUpdated] 
@BuiltValue()
abstract class UserRatingResponse implements Built<UserRatingResponse, UserRatingResponseBuilder> {
  @BuiltValueField(wireName: r'userId')
  String get userId;

  @BuiltValueField(wireName: r'averageRating')
  double get averageRating;

  /// Total number of ratings received
  @BuiltValueField(wireName: r'ratingCount')
  int get ratingCount;

  @BuiltValueField(wireName: r'lastUpdated')
  DateTime? get lastUpdated;

  UserRatingResponse._();

  factory UserRatingResponse([void updates(UserRatingResponseBuilder b)]) = _$UserRatingResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UserRatingResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UserRatingResponse> get serializer => _$UserRatingResponseSerializer();
}

class _$UserRatingResponseSerializer implements PrimitiveSerializer<UserRatingResponse> {
  @override
  final Iterable<Type> types = const [UserRatingResponse, _$UserRatingResponse];

  @override
  final String wireName = r'UserRatingResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UserRatingResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'userId';
    yield serializers.serialize(
      object.userId,
      specifiedType: const FullType(String),
    );
    yield r'averageRating';
    yield serializers.serialize(
      object.averageRating,
      specifiedType: const FullType(double),
    );
    yield r'ratingCount';
    yield serializers.serialize(
      object.ratingCount,
      specifiedType: const FullType(int),
    );
    if (object.lastUpdated != null) {
      yield r'lastUpdated';
      yield serializers.serialize(
        object.lastUpdated,
        specifiedType: const FullType(DateTime),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    UserRatingResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UserRatingResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'userId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.userId = valueDes;
          break;
        case r'averageRating':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(double),
          ) as double;
          result.averageRating = valueDes;
          break;
        case r'ratingCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.ratingCount = valueDes;
          break;
        case r'lastUpdated':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.lastUpdated = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UserRatingResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UserRatingResponseBuilder();
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


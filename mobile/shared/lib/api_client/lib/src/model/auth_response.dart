// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sakai_api_client/src/model/user_profile.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_response.g.dart';

/// AuthResponse
///
/// Properties:
/// * [accessToken] - Short-lived JWT (60 min). Include as `Authorization: Bearer <access_token>`. 
/// * [refreshToken] - Long-lived opaque token (30 days). Store securely (e.g., flutter_secure_storage). Use with `POST /auth/refresh` to silently obtain new access tokens. Rotated on every use — old token is invalidated. 
/// * [accessTokenExpiresAt] - UTC expiry of the access token. Refresh before this time.
/// * [user] 
@BuiltValue()
abstract class AuthResponse implements Built<AuthResponse, AuthResponseBuilder> {
  /// Short-lived JWT (60 min). Include as `Authorization: Bearer <access_token>`. 
  @BuiltValueField(wireName: r'access_token')
  String get accessToken;

  /// Long-lived opaque token (30 days). Store securely (e.g., flutter_secure_storage). Use with `POST /auth/refresh` to silently obtain new access tokens. Rotated on every use — old token is invalidated. 
  @BuiltValueField(wireName: r'refresh_token')
  String get refreshToken;

  /// UTC expiry of the access token. Refresh before this time.
  @BuiltValueField(wireName: r'access_token_expires_at')
  DateTime get accessTokenExpiresAt;

  @BuiltValueField(wireName: r'user')
  UserProfile get user;

  AuthResponse._();

  factory AuthResponse([void updates(AuthResponseBuilder b)]) = _$AuthResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthResponse> get serializer => _$AuthResponseSerializer();
}

class _$AuthResponseSerializer implements PrimitiveSerializer<AuthResponse> {
  @override
  final Iterable<Type> types = const [AuthResponse, _$AuthResponse];

  @override
  final String wireName = r'AuthResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'access_token';
    yield serializers.serialize(
      object.accessToken,
      specifiedType: const FullType(String),
    );
    yield r'refresh_token';
    yield serializers.serialize(
      object.refreshToken,
      specifiedType: const FullType(String),
    );
    yield r'access_token_expires_at';
    yield serializers.serialize(
      object.accessTokenExpiresAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'user';
    yield serializers.serialize(
      object.user,
      specifiedType: const FullType(UserProfile),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AuthResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AuthResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'access_token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.accessToken = valueDes;
          break;
        case r'refresh_token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.refreshToken = valueDes;
          break;
        case r'access_token_expires_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.accessTokenExpiresAt = valueDes;
          break;
        case r'user':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(UserProfile),
          ) as UserProfile;
          result.user = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AuthResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthResponseBuilder();
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


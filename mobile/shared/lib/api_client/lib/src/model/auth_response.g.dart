// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AuthResponse extends AuthResponse {
  @override
  final String accessToken;
  @override
  final String refreshToken;
  @override
  final DateTime accessTokenExpiresAt;
  @override
  final UserProfile user;

  factory _$AuthResponse([void Function(AuthResponseBuilder)? updates]) =>
      (AuthResponseBuilder()..update(updates))._build();

  _$AuthResponse._({
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiresAt,
    required this.user,
  }) : super._();
  @override
  AuthResponse rebuild(void Function(AuthResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AuthResponseBuilder toBuilder() => AuthResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthResponse &&
        accessToken == other.accessToken &&
        refreshToken == other.refreshToken &&
        accessTokenExpiresAt == other.accessTokenExpiresAt &&
        user == other.user;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, accessToken.hashCode);
    _$hash = $jc(_$hash, refreshToken.hashCode);
    _$hash = $jc(_$hash, accessTokenExpiresAt.hashCode);
    _$hash = $jc(_$hash, user.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AuthResponse')
          ..add('accessToken', accessToken)
          ..add('refreshToken', refreshToken)
          ..add('accessTokenExpiresAt', accessTokenExpiresAt)
          ..add('user', user))
        .toString();
  }
}

class AuthResponseBuilder
    implements Builder<AuthResponse, AuthResponseBuilder> {
  _$AuthResponse? _$v;

  String? _accessToken;
  String? get accessToken => _$this._accessToken;
  set accessToken(String? accessToken) => _$this._accessToken = accessToken;

  String? _refreshToken;
  String? get refreshToken => _$this._refreshToken;
  set refreshToken(String? refreshToken) => _$this._refreshToken = refreshToken;

  DateTime? _accessTokenExpiresAt;
  DateTime? get accessTokenExpiresAt => _$this._accessTokenExpiresAt;
  set accessTokenExpiresAt(DateTime? accessTokenExpiresAt) =>
      _$this._accessTokenExpiresAt = accessTokenExpiresAt;

  UserProfileBuilder? _user;
  UserProfileBuilder get user => _$this._user ??= UserProfileBuilder();
  set user(UserProfileBuilder? user) => _$this._user = user;

  AuthResponseBuilder() {
    AuthResponse._defaults(this);
  }

  AuthResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _accessToken = $v.accessToken;
      _refreshToken = $v.refreshToken;
      _accessTokenExpiresAt = $v.accessTokenExpiresAt;
      _user = $v.user.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuthResponse other) {
    _$v = other as _$AuthResponse;
  }

  @override
  void update(void Function(AuthResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuthResponse build() => _build();

  _$AuthResponse _build() {
    _$AuthResponse _$result;
    try {
      _$result =
          _$v ??
          _$AuthResponse._(
            accessToken: BuiltValueNullFieldError.checkNotNull(
              accessToken,
              r'AuthResponse',
              'accessToken',
            ),
            refreshToken: BuiltValueNullFieldError.checkNotNull(
              refreshToken,
              r'AuthResponse',
              'refreshToken',
            ),
            accessTokenExpiresAt: BuiltValueNullFieldError.checkNotNull(
              accessTokenExpiresAt,
              r'AuthResponse',
              'accessTokenExpiresAt',
            ),
            user: user.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'user';
        user.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'AuthResponse',
          _$failedField,
          e.toString(),
        );
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

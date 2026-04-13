// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_rating_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UserRatingResponse extends UserRatingResponse {
  @override
  final String userId;
  @override
  final double averageRating;
  @override
  final int ratingCount;
  @override
  final DateTime? lastUpdated;

  factory _$UserRatingResponse(
          [void Function(UserRatingResponseBuilder)? updates]) =>
      (UserRatingResponseBuilder()..update(updates))._build();

  _$UserRatingResponse._(
      {required this.userId,
      required this.averageRating,
      required this.ratingCount,
      this.lastUpdated})
      : super._();
  @override
  UserRatingResponse rebuild(
          void Function(UserRatingResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UserRatingResponseBuilder toBuilder() =>
      UserRatingResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UserRatingResponse &&
        userId == other.userId &&
        averageRating == other.averageRating &&
        ratingCount == other.ratingCount &&
        lastUpdated == other.lastUpdated;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, averageRating.hashCode);
    _$hash = $jc(_$hash, ratingCount.hashCode);
    _$hash = $jc(_$hash, lastUpdated.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UserRatingResponse')
          ..add('userId', userId)
          ..add('averageRating', averageRating)
          ..add('ratingCount', ratingCount)
          ..add('lastUpdated', lastUpdated))
        .toString();
  }
}

class UserRatingResponseBuilder
    implements Builder<UserRatingResponse, UserRatingResponseBuilder> {
  _$UserRatingResponse? _$v;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

  double? _averageRating;
  double? get averageRating => _$this._averageRating;
  set averageRating(double? averageRating) =>
      _$this._averageRating = averageRating;

  int? _ratingCount;
  int? get ratingCount => _$this._ratingCount;
  set ratingCount(int? ratingCount) => _$this._ratingCount = ratingCount;

  DateTime? _lastUpdated;
  DateTime? get lastUpdated => _$this._lastUpdated;
  set lastUpdated(DateTime? lastUpdated) => _$this._lastUpdated = lastUpdated;

  UserRatingResponseBuilder() {
    UserRatingResponse._defaults(this);
  }

  UserRatingResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _userId = $v.userId;
      _averageRating = $v.averageRating;
      _ratingCount = $v.ratingCount;
      _lastUpdated = $v.lastUpdated;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UserRatingResponse other) {
    _$v = other as _$UserRatingResponse;
  }

  @override
  void update(void Function(UserRatingResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UserRatingResponse build() => _build();

  _$UserRatingResponse _build() {
    final _$result = _$v ??
        _$UserRatingResponse._(
          userId: BuiltValueNullFieldError.checkNotNull(
              userId, r'UserRatingResponse', 'userId'),
          averageRating: BuiltValueNullFieldError.checkNotNull(
              averageRating, r'UserRatingResponse', 'averageRating'),
          ratingCount: BuiltValueNullFieldError.checkNotNull(
              ratingCount, r'UserRatingResponse', 'ratingCount'),
          lastUpdated: lastUpdated,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

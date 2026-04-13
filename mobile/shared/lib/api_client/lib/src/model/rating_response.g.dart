// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rating_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RatingResponse extends RatingResponse {
  @override
  final String id;
  @override
  final String rideId;
  @override
  final String raterId;
  @override
  final String rateeId;
  @override
  final int stars;
  @override
  final String? feedback;
  @override
  final DateTime createdAt;

  factory _$RatingResponse([void Function(RatingResponseBuilder)? updates]) =>
      (RatingResponseBuilder()..update(updates))._build();

  _$RatingResponse._(
      {required this.id,
      required this.rideId,
      required this.raterId,
      required this.rateeId,
      required this.stars,
      this.feedback,
      required this.createdAt})
      : super._();
  @override
  RatingResponse rebuild(void Function(RatingResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RatingResponseBuilder toBuilder() => RatingResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RatingResponse &&
        id == other.id &&
        rideId == other.rideId &&
        raterId == other.raterId &&
        rateeId == other.rateeId &&
        stars == other.stars &&
        feedback == other.feedback &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, rideId.hashCode);
    _$hash = $jc(_$hash, raterId.hashCode);
    _$hash = $jc(_$hash, rateeId.hashCode);
    _$hash = $jc(_$hash, stars.hashCode);
    _$hash = $jc(_$hash, feedback.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RatingResponse')
          ..add('id', id)
          ..add('rideId', rideId)
          ..add('raterId', raterId)
          ..add('rateeId', rateeId)
          ..add('stars', stars)
          ..add('feedback', feedback)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class RatingResponseBuilder
    implements Builder<RatingResponse, RatingResponseBuilder> {
  _$RatingResponse? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _rideId;
  String? get rideId => _$this._rideId;
  set rideId(String? rideId) => _$this._rideId = rideId;

  String? _raterId;
  String? get raterId => _$this._raterId;
  set raterId(String? raterId) => _$this._raterId = raterId;

  String? _rateeId;
  String? get rateeId => _$this._rateeId;
  set rateeId(String? rateeId) => _$this._rateeId = rateeId;

  int? _stars;
  int? get stars => _$this._stars;
  set stars(int? stars) => _$this._stars = stars;

  String? _feedback;
  String? get feedback => _$this._feedback;
  set feedback(String? feedback) => _$this._feedback = feedback;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  RatingResponseBuilder() {
    RatingResponse._defaults(this);
  }

  RatingResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _rideId = $v.rideId;
      _raterId = $v.raterId;
      _rateeId = $v.rateeId;
      _stars = $v.stars;
      _feedback = $v.feedback;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RatingResponse other) {
    _$v = other as _$RatingResponse;
  }

  @override
  void update(void Function(RatingResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RatingResponse build() => _build();

  _$RatingResponse _build() {
    final _$result = _$v ??
        _$RatingResponse._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'RatingResponse', 'id'),
          rideId: BuiltValueNullFieldError.checkNotNull(
              rideId, r'RatingResponse', 'rideId'),
          raterId: BuiltValueNullFieldError.checkNotNull(
              raterId, r'RatingResponse', 'raterId'),
          rateeId: BuiltValueNullFieldError.checkNotNull(
              rateeId, r'RatingResponse', 'rateeId'),
          stars: BuiltValueNullFieldError.checkNotNull(
              stars, r'RatingResponse', 'stars'),
          feedback: feedback,
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'RatingResponse', 'createdAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

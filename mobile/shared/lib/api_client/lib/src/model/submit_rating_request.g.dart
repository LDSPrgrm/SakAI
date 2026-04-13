// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'submit_rating_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SubmitRatingRequest extends SubmitRatingRequest {
  @override
  final int stars;
  @override
  final String? feedback;

  factory _$SubmitRatingRequest(
          [void Function(SubmitRatingRequestBuilder)? updates]) =>
      (SubmitRatingRequestBuilder()..update(updates))._build();

  _$SubmitRatingRequest._({required this.stars, this.feedback}) : super._();
  @override
  SubmitRatingRequest rebuild(
          void Function(SubmitRatingRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SubmitRatingRequestBuilder toBuilder() =>
      SubmitRatingRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SubmitRatingRequest &&
        stars == other.stars &&
        feedback == other.feedback;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, stars.hashCode);
    _$hash = $jc(_$hash, feedback.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SubmitRatingRequest')
          ..add('stars', stars)
          ..add('feedback', feedback))
        .toString();
  }
}

class SubmitRatingRequestBuilder
    implements Builder<SubmitRatingRequest, SubmitRatingRequestBuilder> {
  _$SubmitRatingRequest? _$v;

  int? _stars;
  int? get stars => _$this._stars;
  set stars(int? stars) => _$this._stars = stars;

  String? _feedback;
  String? get feedback => _$this._feedback;
  set feedback(String? feedback) => _$this._feedback = feedback;

  SubmitRatingRequestBuilder() {
    SubmitRatingRequest._defaults(this);
  }

  SubmitRatingRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _stars = $v.stars;
      _feedback = $v.feedback;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SubmitRatingRequest other) {
    _$v = other as _$SubmitRatingRequest;
  }

  @override
  void update(void Function(SubmitRatingRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SubmitRatingRequest build() => _build();

  _$SubmitRatingRequest _build() {
    final _$result = _$v ??
        _$SubmitRatingRequest._(
          stars: BuiltValueNullFieldError.checkNotNull(
              stars, r'SubmitRatingRequest', 'stars'),
          feedback: feedback,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'promotion_validate_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PromotionValidateRequest extends PromotionValidateRequest {
  @override
  final String code;
  @override
  final double? rideFare;

  factory _$PromotionValidateRequest([
    void Function(PromotionValidateRequestBuilder)? updates,
  ]) => (PromotionValidateRequestBuilder()..update(updates))._build();

  _$PromotionValidateRequest._({required this.code, this.rideFare}) : super._();
  @override
  PromotionValidateRequest rebuild(
    void Function(PromotionValidateRequestBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  PromotionValidateRequestBuilder toBuilder() =>
      PromotionValidateRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PromotionValidateRequest &&
        code == other.code &&
        rideFare == other.rideFare;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, rideFare.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PromotionValidateRequest')
          ..add('code', code)
          ..add('rideFare', rideFare))
        .toString();
  }
}

class PromotionValidateRequestBuilder
    implements
        Builder<PromotionValidateRequest, PromotionValidateRequestBuilder> {
  _$PromotionValidateRequest? _$v;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  double? _rideFare;
  double? get rideFare => _$this._rideFare;
  set rideFare(double? rideFare) => _$this._rideFare = rideFare;

  PromotionValidateRequestBuilder() {
    PromotionValidateRequest._defaults(this);
  }

  PromotionValidateRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _code = $v.code;
      _rideFare = $v.rideFare;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PromotionValidateRequest other) {
    _$v = other as _$PromotionValidateRequest;
  }

  @override
  void update(void Function(PromotionValidateRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PromotionValidateRequest build() => _build();

  _$PromotionValidateRequest _build() {
    final _$result =
        _$v ??
        _$PromotionValidateRequest._(
          code: BuiltValueNullFieldError.checkNotNull(
            code,
            r'PromotionValidateRequest',
            'code',
          ),
          rideFare: rideFare,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

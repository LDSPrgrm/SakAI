// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_fares_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminFaresResponse extends AdminFaresResponse {
  @override
  final BuiltList<FareConfig>? fares;
  @override
  final SurgeConfig? surge;

  factory _$AdminFaresResponse([
    void Function(AdminFaresResponseBuilder)? updates,
  ]) => (AdminFaresResponseBuilder()..update(updates))._build();

  _$AdminFaresResponse._({this.fares, this.surge}) : super._();
  @override
  AdminFaresResponse rebuild(
    void Function(AdminFaresResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminFaresResponseBuilder toBuilder() =>
      AdminFaresResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminFaresResponse &&
        fares == other.fares &&
        surge == other.surge;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, fares.hashCode);
    _$hash = $jc(_$hash, surge.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminFaresResponse')
          ..add('fares', fares)
          ..add('surge', surge))
        .toString();
  }
}

class AdminFaresResponseBuilder
    implements Builder<AdminFaresResponse, AdminFaresResponseBuilder> {
  _$AdminFaresResponse? _$v;

  ListBuilder<FareConfig>? _fares;
  ListBuilder<FareConfig> get fares =>
      _$this._fares ??= ListBuilder<FareConfig>();
  set fares(ListBuilder<FareConfig>? fares) => _$this._fares = fares;

  SurgeConfigBuilder? _surge;
  SurgeConfigBuilder get surge => _$this._surge ??= SurgeConfigBuilder();
  set surge(SurgeConfigBuilder? surge) => _$this._surge = surge;

  AdminFaresResponseBuilder() {
    AdminFaresResponse._defaults(this);
  }

  AdminFaresResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _fares = $v.fares?.toBuilder();
      _surge = $v.surge?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminFaresResponse other) {
    _$v = other as _$AdminFaresResponse;
  }

  @override
  void update(void Function(AdminFaresResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminFaresResponse build() => _build();

  _$AdminFaresResponse _build() {
    _$AdminFaresResponse _$result;
    try {
      _$result =
          _$v ??
          _$AdminFaresResponse._(
            fares: _fares?.build(),
            surge: _surge?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'fares';
        _fares?.build();
        _$failedField = 'surge';
        _surge?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'AdminFaresResponse',
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

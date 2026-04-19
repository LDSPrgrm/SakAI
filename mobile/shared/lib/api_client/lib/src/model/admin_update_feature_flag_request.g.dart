// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_update_feature_flag_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminUpdateFeatureFlagRequest extends AdminUpdateFeatureFlagRequest {
  @override
  final bool enabled;

  factory _$AdminUpdateFeatureFlagRequest([
    void Function(AdminUpdateFeatureFlagRequestBuilder)? updates,
  ]) => (AdminUpdateFeatureFlagRequestBuilder()..update(updates))._build();

  _$AdminUpdateFeatureFlagRequest._({required this.enabled}) : super._();
  @override
  AdminUpdateFeatureFlagRequest rebuild(
    void Function(AdminUpdateFeatureFlagRequestBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminUpdateFeatureFlagRequestBuilder toBuilder() =>
      AdminUpdateFeatureFlagRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminUpdateFeatureFlagRequest && enabled == other.enabled;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, enabled.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'AdminUpdateFeatureFlagRequest',
    )..add('enabled', enabled)).toString();
  }
}

class AdminUpdateFeatureFlagRequestBuilder
    implements
        Builder<
          AdminUpdateFeatureFlagRequest,
          AdminUpdateFeatureFlagRequestBuilder
        > {
  _$AdminUpdateFeatureFlagRequest? _$v;

  bool? _enabled;
  bool? get enabled => _$this._enabled;
  set enabled(bool? enabled) => _$this._enabled = enabled;

  AdminUpdateFeatureFlagRequestBuilder() {
    AdminUpdateFeatureFlagRequest._defaults(this);
  }

  AdminUpdateFeatureFlagRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _enabled = $v.enabled;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminUpdateFeatureFlagRequest other) {
    _$v = other as _$AdminUpdateFeatureFlagRequest;
  }

  @override
  void update(void Function(AdminUpdateFeatureFlagRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminUpdateFeatureFlagRequest build() => _build();

  _$AdminUpdateFeatureFlagRequest _build() {
    final _$result =
        _$v ??
        _$AdminUpdateFeatureFlagRequest._(
          enabled: BuiltValueNullFieldError.checkNotNull(
            enabled,
            r'AdminUpdateFeatureFlagRequest',
            'enabled',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

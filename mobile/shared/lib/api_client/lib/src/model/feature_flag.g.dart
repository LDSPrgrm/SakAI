// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feature_flag.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$FeatureFlag extends FeatureFlag {
  @override
  final String? key;
  @override
  final String? label;
  @override
  final String? description;
  @override
  final bool? enabled;

  factory _$FeatureFlag([void Function(FeatureFlagBuilder)? updates]) =>
      (FeatureFlagBuilder()..update(updates))._build();

  _$FeatureFlag._({this.key, this.label, this.description, this.enabled})
    : super._();
  @override
  FeatureFlag rebuild(void Function(FeatureFlagBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FeatureFlagBuilder toBuilder() => FeatureFlagBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FeatureFlag &&
        key == other.key &&
        label == other.label &&
        description == other.description &&
        enabled == other.enabled;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, key.hashCode);
    _$hash = $jc(_$hash, label.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, enabled.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FeatureFlag')
          ..add('key', key)
          ..add('label', label)
          ..add('description', description)
          ..add('enabled', enabled))
        .toString();
  }
}

class FeatureFlagBuilder implements Builder<FeatureFlag, FeatureFlagBuilder> {
  _$FeatureFlag? _$v;

  String? _key;
  String? get key => _$this._key;
  set key(String? key) => _$this._key = key;

  String? _label;
  String? get label => _$this._label;
  set label(String? label) => _$this._label = label;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  bool? _enabled;
  bool? get enabled => _$this._enabled;
  set enabled(bool? enabled) => _$this._enabled = enabled;

  FeatureFlagBuilder() {
    FeatureFlag._defaults(this);
  }

  FeatureFlagBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _key = $v.key;
      _label = $v.label;
      _description = $v.description;
      _enabled = $v.enabled;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FeatureFlag other) {
    _$v = other as _$FeatureFlag;
  }

  @override
  void update(void Function(FeatureFlagBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FeatureFlag build() => _build();

  _$FeatureFlag _build() {
    final _$result =
        _$v ??
        _$FeatureFlag._(
          key: key,
          label: label,
          description: description,
          enabled: enabled,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

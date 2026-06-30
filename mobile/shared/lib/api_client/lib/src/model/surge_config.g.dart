// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'surge_config.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SurgeConfig extends SurgeConfig {
  @override
  final String? id;
  @override
  final bool? enabled;
  @override
  final num? maxMultiplier;
  @override
  final num? triggerRatio;
  @override
  final BuiltList<SurgeZone>? zones;
  @override
  final BuiltList<BlackoutHour>? blackoutHours;
  @override
  final DateTime? updatedAt;
  @override
  final String? updatedBy;
  @override
  final String? updatedByName;

  factory _$SurgeConfig([void Function(SurgeConfigBuilder)? updates]) =>
      (SurgeConfigBuilder()..update(updates))._build();

  _$SurgeConfig._({
    this.id,
    this.enabled,
    this.maxMultiplier,
    this.triggerRatio,
    this.zones,
    this.blackoutHours,
    this.updatedAt,
    this.updatedBy,
    this.updatedByName,
  }) : super._();
  @override
  SurgeConfig rebuild(void Function(SurgeConfigBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SurgeConfigBuilder toBuilder() => SurgeConfigBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SurgeConfig &&
        id == other.id &&
        enabled == other.enabled &&
        maxMultiplier == other.maxMultiplier &&
        triggerRatio == other.triggerRatio &&
        zones == other.zones &&
        blackoutHours == other.blackoutHours &&
        updatedAt == other.updatedAt &&
        updatedBy == other.updatedBy &&
        updatedByName == other.updatedByName;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, enabled.hashCode);
    _$hash = $jc(_$hash, maxMultiplier.hashCode);
    _$hash = $jc(_$hash, triggerRatio.hashCode);
    _$hash = $jc(_$hash, zones.hashCode);
    _$hash = $jc(_$hash, blackoutHours.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, updatedBy.hashCode);
    _$hash = $jc(_$hash, updatedByName.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SurgeConfig')
          ..add('id', id)
          ..add('enabled', enabled)
          ..add('maxMultiplier', maxMultiplier)
          ..add('triggerRatio', triggerRatio)
          ..add('zones', zones)
          ..add('blackoutHours', blackoutHours)
          ..add('updatedAt', updatedAt)
          ..add('updatedBy', updatedBy)
          ..add('updatedByName', updatedByName))
        .toString();
  }
}

class SurgeConfigBuilder implements Builder<SurgeConfig, SurgeConfigBuilder> {
  _$SurgeConfig? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  bool? _enabled;
  bool? get enabled => _$this._enabled;
  set enabled(bool? enabled) => _$this._enabled = enabled;

  num? _maxMultiplier;
  num? get maxMultiplier => _$this._maxMultiplier;
  set maxMultiplier(num? maxMultiplier) =>
      _$this._maxMultiplier = maxMultiplier;

  num? _triggerRatio;
  num? get triggerRatio => _$this._triggerRatio;
  set triggerRatio(num? triggerRatio) => _$this._triggerRatio = triggerRatio;

  ListBuilder<SurgeZone>? _zones;
  ListBuilder<SurgeZone> get zones =>
      _$this._zones ??= ListBuilder<SurgeZone>();
  set zones(ListBuilder<SurgeZone>? zones) => _$this._zones = zones;

  ListBuilder<BlackoutHour>? _blackoutHours;
  ListBuilder<BlackoutHour> get blackoutHours =>
      _$this._blackoutHours ??= ListBuilder<BlackoutHour>();
  set blackoutHours(ListBuilder<BlackoutHour>? blackoutHours) =>
      _$this._blackoutHours = blackoutHours;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  String? _updatedBy;
  String? get updatedBy => _$this._updatedBy;
  set updatedBy(String? updatedBy) => _$this._updatedBy = updatedBy;

  String? _updatedByName;
  String? get updatedByName => _$this._updatedByName;
  set updatedByName(String? updatedByName) =>
      _$this._updatedByName = updatedByName;

  SurgeConfigBuilder() {
    SurgeConfig._defaults(this);
  }

  SurgeConfigBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _enabled = $v.enabled;
      _maxMultiplier = $v.maxMultiplier;
      _triggerRatio = $v.triggerRatio;
      _zones = $v.zones?.toBuilder();
      _blackoutHours = $v.blackoutHours?.toBuilder();
      _updatedAt = $v.updatedAt;
      _updatedBy = $v.updatedBy;
      _updatedByName = $v.updatedByName;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SurgeConfig other) {
    _$v = other as _$SurgeConfig;
  }

  @override
  void update(void Function(SurgeConfigBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SurgeConfig build() => _build();

  _$SurgeConfig _build() {
    _$SurgeConfig _$result;
    try {
      _$result =
          _$v ??
          _$SurgeConfig._(
            id: id,
            enabled: enabled,
            maxMultiplier: maxMultiplier,
            triggerRatio: triggerRatio,
            zones: _zones?.build(),
            blackoutHours: _blackoutHours?.build(),
            updatedAt: updatedAt,
            updatedBy: updatedBy,
            updatedByName: updatedByName,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'zones';
        _zones?.build();
        _$failedField = 'blackoutHours';
        _blackoutHours?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'SurgeConfig',
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

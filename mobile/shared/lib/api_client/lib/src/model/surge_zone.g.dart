// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'surge_zone.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SurgeZone extends SurgeZone {
  @override
  final String name;
  @override
  final double multiplier;
  @override
  final BuiltList<BuiltList<num>> polygon;

  factory _$SurgeZone([void Function(SurgeZoneBuilder)? updates]) =>
      (SurgeZoneBuilder()..update(updates))._build();

  _$SurgeZone._({
    required this.name,
    required this.multiplier,
    required this.polygon,
  }) : super._();
  @override
  SurgeZone rebuild(void Function(SurgeZoneBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SurgeZoneBuilder toBuilder() => SurgeZoneBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SurgeZone &&
        name == other.name &&
        multiplier == other.multiplier &&
        polygon == other.polygon;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, multiplier.hashCode);
    _$hash = $jc(_$hash, polygon.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SurgeZone')
          ..add('name', name)
          ..add('multiplier', multiplier)
          ..add('polygon', polygon))
        .toString();
  }
}

class SurgeZoneBuilder implements Builder<SurgeZone, SurgeZoneBuilder> {
  _$SurgeZone? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  double? _multiplier;
  double? get multiplier => _$this._multiplier;
  set multiplier(double? multiplier) => _$this._multiplier = multiplier;

  ListBuilder<BuiltList<num>>? _polygon;
  ListBuilder<BuiltList<num>> get polygon =>
      _$this._polygon ??= ListBuilder<BuiltList<num>>();
  set polygon(ListBuilder<BuiltList<num>>? polygon) =>
      _$this._polygon = polygon;

  SurgeZoneBuilder() {
    SurgeZone._defaults(this);
  }

  SurgeZoneBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _multiplier = $v.multiplier;
      _polygon = $v.polygon.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SurgeZone other) {
    _$v = other as _$SurgeZone;
  }

  @override
  void update(void Function(SurgeZoneBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SurgeZone build() => _build();

  _$SurgeZone _build() {
    _$SurgeZone _$result;
    try {
      _$result =
          _$v ??
          _$SurgeZone._(
            name: BuiltValueNullFieldError.checkNotNull(
              name,
              r'SurgeZone',
              'name',
            ),
            multiplier: BuiltValueNullFieldError.checkNotNull(
              multiplier,
              r'SurgeZone',
              'multiplier',
            ),
            polygon: polygon.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'polygon';
        polygon.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'SurgeZone',
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

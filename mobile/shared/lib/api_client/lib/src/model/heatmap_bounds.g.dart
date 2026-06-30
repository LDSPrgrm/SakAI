// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'heatmap_bounds.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$HeatmapBounds extends HeatmapBounds {
  @override
  final double? north;
  @override
  final double? south;
  @override
  final double? east;
  @override
  final double? west;

  factory _$HeatmapBounds([void Function(HeatmapBoundsBuilder)? updates]) =>
      (HeatmapBoundsBuilder()..update(updates))._build();

  _$HeatmapBounds._({this.north, this.south, this.east, this.west}) : super._();
  @override
  HeatmapBounds rebuild(void Function(HeatmapBoundsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  HeatmapBoundsBuilder toBuilder() => HeatmapBoundsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is HeatmapBounds &&
        north == other.north &&
        south == other.south &&
        east == other.east &&
        west == other.west;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, north.hashCode);
    _$hash = $jc(_$hash, south.hashCode);
    _$hash = $jc(_$hash, east.hashCode);
    _$hash = $jc(_$hash, west.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'HeatmapBounds')
          ..add('north', north)
          ..add('south', south)
          ..add('east', east)
          ..add('west', west))
        .toString();
  }
}

class HeatmapBoundsBuilder
    implements Builder<HeatmapBounds, HeatmapBoundsBuilder> {
  _$HeatmapBounds? _$v;

  double? _north;
  double? get north => _$this._north;
  set north(double? north) => _$this._north = north;

  double? _south;
  double? get south => _$this._south;
  set south(double? south) => _$this._south = south;

  double? _east;
  double? get east => _$this._east;
  set east(double? east) => _$this._east = east;

  double? _west;
  double? get west => _$this._west;
  set west(double? west) => _$this._west = west;

  HeatmapBoundsBuilder() {
    HeatmapBounds._defaults(this);
  }

  HeatmapBoundsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _north = $v.north;
      _south = $v.south;
      _east = $v.east;
      _west = $v.west;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(HeatmapBounds other) {
    _$v = other as _$HeatmapBounds;
  }

  @override
  void update(void Function(HeatmapBoundsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  HeatmapBounds build() => _build();

  _$HeatmapBounds _build() {
    final _$result =
        _$v ??
        _$HeatmapBounds._(north: north, south: south, east: east, west: west);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_heatmap.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DriverHeatmap extends DriverHeatmap {
  @override
  final BuiltList<HeatmapPosition>? positions;
  @override
  final HeatmapBounds? bounds;
  @override
  final DateTime? generatedAt;

  factory _$DriverHeatmap([void Function(DriverHeatmapBuilder)? updates]) =>
      (DriverHeatmapBuilder()..update(updates))._build();

  _$DriverHeatmap._({this.positions, this.bounds, this.generatedAt})
    : super._();
  @override
  DriverHeatmap rebuild(void Function(DriverHeatmapBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DriverHeatmapBuilder toBuilder() => DriverHeatmapBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DriverHeatmap &&
        positions == other.positions &&
        bounds == other.bounds &&
        generatedAt == other.generatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, positions.hashCode);
    _$hash = $jc(_$hash, bounds.hashCode);
    _$hash = $jc(_$hash, generatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DriverHeatmap')
          ..add('positions', positions)
          ..add('bounds', bounds)
          ..add('generatedAt', generatedAt))
        .toString();
  }
}

class DriverHeatmapBuilder
    implements Builder<DriverHeatmap, DriverHeatmapBuilder> {
  _$DriverHeatmap? _$v;

  ListBuilder<HeatmapPosition>? _positions;
  ListBuilder<HeatmapPosition> get positions =>
      _$this._positions ??= ListBuilder<HeatmapPosition>();
  set positions(ListBuilder<HeatmapPosition>? positions) =>
      _$this._positions = positions;

  HeatmapBoundsBuilder? _bounds;
  HeatmapBoundsBuilder get bounds => _$this._bounds ??= HeatmapBoundsBuilder();
  set bounds(HeatmapBoundsBuilder? bounds) => _$this._bounds = bounds;

  DateTime? _generatedAt;
  DateTime? get generatedAt => _$this._generatedAt;
  set generatedAt(DateTime? generatedAt) => _$this._generatedAt = generatedAt;

  DriverHeatmapBuilder() {
    DriverHeatmap._defaults(this);
  }

  DriverHeatmapBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _positions = $v.positions?.toBuilder();
      _bounds = $v.bounds?.toBuilder();
      _generatedAt = $v.generatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DriverHeatmap other) {
    _$v = other as _$DriverHeatmap;
  }

  @override
  void update(void Function(DriverHeatmapBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DriverHeatmap build() => _build();

  _$DriverHeatmap _build() {
    _$DriverHeatmap _$result;
    try {
      _$result =
          _$v ??
          _$DriverHeatmap._(
            positions: _positions?.build(),
            bounds: _bounds?.build(),
            generatedAt: generatedAt,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'positions';
        _positions?.build();
        _$failedField = 'bounds';
        _bounds?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'DriverHeatmap',
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

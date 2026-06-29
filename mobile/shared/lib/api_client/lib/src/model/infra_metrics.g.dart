// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'infra_metrics.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$InfraMetrics extends InfraMetrics {
  @override
  final num? apiP50Ms;
  @override
  final num? apiP95Ms;
  @override
  final int? wsConnections;
  @override
  final num? dbQueryP99Ms;
  @override
  final int? sampleCount;
  @override
  final int? windowMinutes;

  factory _$InfraMetrics([void Function(InfraMetricsBuilder)? updates]) =>
      (InfraMetricsBuilder()..update(updates))._build();

  _$InfraMetrics._({
    this.apiP50Ms,
    this.apiP95Ms,
    this.wsConnections,
    this.dbQueryP99Ms,
    this.sampleCount,
    this.windowMinutes,
  }) : super._();
  @override
  InfraMetrics rebuild(void Function(InfraMetricsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  InfraMetricsBuilder toBuilder() => InfraMetricsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is InfraMetrics &&
        apiP50Ms == other.apiP50Ms &&
        apiP95Ms == other.apiP95Ms &&
        wsConnections == other.wsConnections &&
        dbQueryP99Ms == other.dbQueryP99Ms &&
        sampleCount == other.sampleCount &&
        windowMinutes == other.windowMinutes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, apiP50Ms.hashCode);
    _$hash = $jc(_$hash, apiP95Ms.hashCode);
    _$hash = $jc(_$hash, wsConnections.hashCode);
    _$hash = $jc(_$hash, dbQueryP99Ms.hashCode);
    _$hash = $jc(_$hash, sampleCount.hashCode);
    _$hash = $jc(_$hash, windowMinutes.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'InfraMetrics')
          ..add('apiP50Ms', apiP50Ms)
          ..add('apiP95Ms', apiP95Ms)
          ..add('wsConnections', wsConnections)
          ..add('dbQueryP99Ms', dbQueryP99Ms)
          ..add('sampleCount', sampleCount)
          ..add('windowMinutes', windowMinutes))
        .toString();
  }
}

class InfraMetricsBuilder
    implements Builder<InfraMetrics, InfraMetricsBuilder> {
  _$InfraMetrics? _$v;

  num? _apiP50Ms;
  num? get apiP50Ms => _$this._apiP50Ms;
  set apiP50Ms(num? apiP50Ms) => _$this._apiP50Ms = apiP50Ms;

  num? _apiP95Ms;
  num? get apiP95Ms => _$this._apiP95Ms;
  set apiP95Ms(num? apiP95Ms) => _$this._apiP95Ms = apiP95Ms;

  int? _wsConnections;
  int? get wsConnections => _$this._wsConnections;
  set wsConnections(int? wsConnections) =>
      _$this._wsConnections = wsConnections;

  num? _dbQueryP99Ms;
  num? get dbQueryP99Ms => _$this._dbQueryP99Ms;
  set dbQueryP99Ms(num? dbQueryP99Ms) => _$this._dbQueryP99Ms = dbQueryP99Ms;

  int? _sampleCount;
  int? get sampleCount => _$this._sampleCount;
  set sampleCount(int? sampleCount) => _$this._sampleCount = sampleCount;

  int? _windowMinutes;
  int? get windowMinutes => _$this._windowMinutes;
  set windowMinutes(int? windowMinutes) =>
      _$this._windowMinutes = windowMinutes;

  InfraMetricsBuilder() {
    InfraMetrics._defaults(this);
  }

  InfraMetricsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _apiP50Ms = $v.apiP50Ms;
      _apiP95Ms = $v.apiP95Ms;
      _wsConnections = $v.wsConnections;
      _dbQueryP99Ms = $v.dbQueryP99Ms;
      _sampleCount = $v.sampleCount;
      _windowMinutes = $v.windowMinutes;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(InfraMetrics other) {
    _$v = other as _$InfraMetrics;
  }

  @override
  void update(void Function(InfraMetricsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  InfraMetrics build() => _build();

  _$InfraMetrics _build() {
    final _$result =
        _$v ??
        _$InfraMetrics._(
          apiP50Ms: apiP50Ms,
          apiP95Ms: apiP95Ms,
          wsConnections: wsConnections,
          dbQueryP99Ms: dbQueryP99Ms,
          sampleCount: sampleCount,
          windowMinutes: windowMinutes,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

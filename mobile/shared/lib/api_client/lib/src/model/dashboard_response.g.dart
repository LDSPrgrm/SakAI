// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DashboardResponse extends DashboardResponse {
  @override
  final int? activeRiders;
  @override
  final int? activeDrivers;
  @override
  final int? ridesToday;
  @override
  final num? revenueToday;
  @override
  final num? avgWaitTimeSeconds;
  @override
  final num? systemUptime;

  factory _$DashboardResponse([
    void Function(DashboardResponseBuilder)? updates,
  ]) => (DashboardResponseBuilder()..update(updates))._build();

  _$DashboardResponse._({
    this.activeRiders,
    this.activeDrivers,
    this.ridesToday,
    this.revenueToday,
    this.avgWaitTimeSeconds,
    this.systemUptime,
  }) : super._();
  @override
  DashboardResponse rebuild(void Function(DashboardResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DashboardResponseBuilder toBuilder() =>
      DashboardResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DashboardResponse &&
        activeRiders == other.activeRiders &&
        activeDrivers == other.activeDrivers &&
        ridesToday == other.ridesToday &&
        revenueToday == other.revenueToday &&
        avgWaitTimeSeconds == other.avgWaitTimeSeconds &&
        systemUptime == other.systemUptime;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, activeRiders.hashCode);
    _$hash = $jc(_$hash, activeDrivers.hashCode);
    _$hash = $jc(_$hash, ridesToday.hashCode);
    _$hash = $jc(_$hash, revenueToday.hashCode);
    _$hash = $jc(_$hash, avgWaitTimeSeconds.hashCode);
    _$hash = $jc(_$hash, systemUptime.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DashboardResponse')
          ..add('activeRiders', activeRiders)
          ..add('activeDrivers', activeDrivers)
          ..add('ridesToday', ridesToday)
          ..add('revenueToday', revenueToday)
          ..add('avgWaitTimeSeconds', avgWaitTimeSeconds)
          ..add('systemUptime', systemUptime))
        .toString();
  }
}

class DashboardResponseBuilder
    implements Builder<DashboardResponse, DashboardResponseBuilder> {
  _$DashboardResponse? _$v;

  int? _activeRiders;
  int? get activeRiders => _$this._activeRiders;
  set activeRiders(int? activeRiders) => _$this._activeRiders = activeRiders;

  int? _activeDrivers;
  int? get activeDrivers => _$this._activeDrivers;
  set activeDrivers(int? activeDrivers) =>
      _$this._activeDrivers = activeDrivers;

  int? _ridesToday;
  int? get ridesToday => _$this._ridesToday;
  set ridesToday(int? ridesToday) => _$this._ridesToday = ridesToday;

  num? _revenueToday;
  num? get revenueToday => _$this._revenueToday;
  set revenueToday(num? revenueToday) => _$this._revenueToday = revenueToday;

  num? _avgWaitTimeSeconds;
  num? get avgWaitTimeSeconds => _$this._avgWaitTimeSeconds;
  set avgWaitTimeSeconds(num? avgWaitTimeSeconds) =>
      _$this._avgWaitTimeSeconds = avgWaitTimeSeconds;

  num? _systemUptime;
  num? get systemUptime => _$this._systemUptime;
  set systemUptime(num? systemUptime) => _$this._systemUptime = systemUptime;

  DashboardResponseBuilder() {
    DashboardResponse._defaults(this);
  }

  DashboardResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _activeRiders = $v.activeRiders;
      _activeDrivers = $v.activeDrivers;
      _ridesToday = $v.ridesToday;
      _revenueToday = $v.revenueToday;
      _avgWaitTimeSeconds = $v.avgWaitTimeSeconds;
      _systemUptime = $v.systemUptime;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DashboardResponse other) {
    _$v = other as _$DashboardResponse;
  }

  @override
  void update(void Function(DashboardResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DashboardResponse build() => _build();

  _$DashboardResponse _build() {
    final _$result =
        _$v ??
        _$DashboardResponse._(
          activeRiders: activeRiders,
          activeDrivers: activeDrivers,
          ridesToday: ridesToday,
          revenueToday: revenueToday,
          avgWaitTimeSeconds: avgWaitTimeSeconds,
          systemUptime: systemUptime,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

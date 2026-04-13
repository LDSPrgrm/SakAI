// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DashboardResponse extends DashboardResponse {
  @override
  final int? activeRiders;
  @override
  final int? totalRiders;
  @override
  final String? ridersTrend;
  @override
  final int? activeDrivers;
  @override
  final int? totalDrivers;
  @override
  final String? driversTrend;
  @override
  final int? ridesToday;
  @override
  final String? ridesTrend;
  @override
  final num? revenueToday;
  @override
  final String? revenueTrend;
  @override
  final num? avgWaitTimeSeconds;
  @override
  final num? avgWaitMinutes;
  @override
  final String? waitTrend;
  @override
  final num? systemUptime;
  @override
  final num? platformUptime;

  factory _$DashboardResponse(
          [void Function(DashboardResponseBuilder)? updates]) =>
      (DashboardResponseBuilder()..update(updates))._build();

  _$DashboardResponse._(
      {this.activeRiders,
      this.totalRiders,
      this.ridersTrend,
      this.activeDrivers,
      this.totalDrivers,
      this.driversTrend,
      this.ridesToday,
      this.ridesTrend,
      this.revenueToday,
      this.revenueTrend,
      this.avgWaitTimeSeconds,
      this.avgWaitMinutes,
      this.waitTrend,
      this.systemUptime,
      this.platformUptime})
      : super._();
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
        totalRiders == other.totalRiders &&
        ridersTrend == other.ridersTrend &&
        activeDrivers == other.activeDrivers &&
        totalDrivers == other.totalDrivers &&
        driversTrend == other.driversTrend &&
        ridesToday == other.ridesToday &&
        ridesTrend == other.ridesTrend &&
        revenueToday == other.revenueToday &&
        revenueTrend == other.revenueTrend &&
        avgWaitTimeSeconds == other.avgWaitTimeSeconds &&
        avgWaitMinutes == other.avgWaitMinutes &&
        waitTrend == other.waitTrend &&
        systemUptime == other.systemUptime &&
        platformUptime == other.platformUptime;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, activeRiders.hashCode);
    _$hash = $jc(_$hash, totalRiders.hashCode);
    _$hash = $jc(_$hash, ridersTrend.hashCode);
    _$hash = $jc(_$hash, activeDrivers.hashCode);
    _$hash = $jc(_$hash, totalDrivers.hashCode);
    _$hash = $jc(_$hash, driversTrend.hashCode);
    _$hash = $jc(_$hash, ridesToday.hashCode);
    _$hash = $jc(_$hash, ridesTrend.hashCode);
    _$hash = $jc(_$hash, revenueToday.hashCode);
    _$hash = $jc(_$hash, revenueTrend.hashCode);
    _$hash = $jc(_$hash, avgWaitTimeSeconds.hashCode);
    _$hash = $jc(_$hash, avgWaitMinutes.hashCode);
    _$hash = $jc(_$hash, waitTrend.hashCode);
    _$hash = $jc(_$hash, systemUptime.hashCode);
    _$hash = $jc(_$hash, platformUptime.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DashboardResponse')
          ..add('activeRiders', activeRiders)
          ..add('totalRiders', totalRiders)
          ..add('ridersTrend', ridersTrend)
          ..add('activeDrivers', activeDrivers)
          ..add('totalDrivers', totalDrivers)
          ..add('driversTrend', driversTrend)
          ..add('ridesToday', ridesToday)
          ..add('ridesTrend', ridesTrend)
          ..add('revenueToday', revenueToday)
          ..add('revenueTrend', revenueTrend)
          ..add('avgWaitTimeSeconds', avgWaitTimeSeconds)
          ..add('avgWaitMinutes', avgWaitMinutes)
          ..add('waitTrend', waitTrend)
          ..add('systemUptime', systemUptime)
          ..add('platformUptime', platformUptime))
        .toString();
  }
}

class DashboardResponseBuilder
    implements Builder<DashboardResponse, DashboardResponseBuilder> {
  _$DashboardResponse? _$v;

  int? _activeRiders;
  int? get activeRiders => _$this._activeRiders;
  set activeRiders(int? activeRiders) => _$this._activeRiders = activeRiders;

  int? _totalRiders;
  int? get totalRiders => _$this._totalRiders;
  set totalRiders(int? totalRiders) => _$this._totalRiders = totalRiders;

  String? _ridersTrend;
  String? get ridersTrend => _$this._ridersTrend;
  set ridersTrend(String? ridersTrend) => _$this._ridersTrend = ridersTrend;

  int? _activeDrivers;
  int? get activeDrivers => _$this._activeDrivers;
  set activeDrivers(int? activeDrivers) =>
      _$this._activeDrivers = activeDrivers;

  int? _totalDrivers;
  int? get totalDrivers => _$this._totalDrivers;
  set totalDrivers(int? totalDrivers) => _$this._totalDrivers = totalDrivers;

  String? _driversTrend;
  String? get driversTrend => _$this._driversTrend;
  set driversTrend(String? driversTrend) => _$this._driversTrend = driversTrend;

  int? _ridesToday;
  int? get ridesToday => _$this._ridesToday;
  set ridesToday(int? ridesToday) => _$this._ridesToday = ridesToday;

  String? _ridesTrend;
  String? get ridesTrend => _$this._ridesTrend;
  set ridesTrend(String? ridesTrend) => _$this._ridesTrend = ridesTrend;

  num? _revenueToday;
  num? get revenueToday => _$this._revenueToday;
  set revenueToday(num? revenueToday) => _$this._revenueToday = revenueToday;

  String? _revenueTrend;
  String? get revenueTrend => _$this._revenueTrend;
  set revenueTrend(String? revenueTrend) => _$this._revenueTrend = revenueTrend;

  num? _avgWaitTimeSeconds;
  num? get avgWaitTimeSeconds => _$this._avgWaitTimeSeconds;
  set avgWaitTimeSeconds(num? avgWaitTimeSeconds) =>
      _$this._avgWaitTimeSeconds = avgWaitTimeSeconds;

  num? _avgWaitMinutes;
  num? get avgWaitMinutes => _$this._avgWaitMinutes;
  set avgWaitMinutes(num? avgWaitMinutes) =>
      _$this._avgWaitMinutes = avgWaitMinutes;

  String? _waitTrend;
  String? get waitTrend => _$this._waitTrend;
  set waitTrend(String? waitTrend) => _$this._waitTrend = waitTrend;

  num? _systemUptime;
  num? get systemUptime => _$this._systemUptime;
  set systemUptime(num? systemUptime) => _$this._systemUptime = systemUptime;

  num? _platformUptime;
  num? get platformUptime => _$this._platformUptime;
  set platformUptime(num? platformUptime) =>
      _$this._platformUptime = platformUptime;

  DashboardResponseBuilder() {
    DashboardResponse._defaults(this);
  }

  DashboardResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _activeRiders = $v.activeRiders;
      _totalRiders = $v.totalRiders;
      _ridersTrend = $v.ridersTrend;
      _activeDrivers = $v.activeDrivers;
      _totalDrivers = $v.totalDrivers;
      _driversTrend = $v.driversTrend;
      _ridesToday = $v.ridesToday;
      _ridesTrend = $v.ridesTrend;
      _revenueToday = $v.revenueToday;
      _revenueTrend = $v.revenueTrend;
      _avgWaitTimeSeconds = $v.avgWaitTimeSeconds;
      _avgWaitMinutes = $v.avgWaitMinutes;
      _waitTrend = $v.waitTrend;
      _systemUptime = $v.systemUptime;
      _platformUptime = $v.platformUptime;
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
    final _$result = _$v ??
        _$DashboardResponse._(
          activeRiders: activeRiders,
          totalRiders: totalRiders,
          ridersTrend: ridersTrend,
          activeDrivers: activeDrivers,
          totalDrivers: totalDrivers,
          driversTrend: driversTrend,
          ridesToday: ridesToday,
          ridesTrend: ridesTrend,
          revenueToday: revenueToday,
          revenueTrend: revenueTrend,
          avgWaitTimeSeconds: avgWaitTimeSeconds,
          avgWaitMinutes: avgWaitMinutes,
          waitTrend: waitTrend,
          systemUptime: systemUptime,
          platformUptime: platformUptime,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

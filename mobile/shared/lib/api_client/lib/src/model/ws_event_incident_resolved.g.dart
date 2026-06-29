// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ws_event_incident_resolved.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$WsEventIncidentResolved extends WsEventIncidentResolved {
  @override
  final String rideId;
  @override
  final String incidentId;
  @override
  final String? resolutionNotes;
  @override
  final DateTime resolvedAt;

  factory _$WsEventIncidentResolved([
    void Function(WsEventIncidentResolvedBuilder)? updates,
  ]) => (WsEventIncidentResolvedBuilder()..update(updates))._build();

  _$WsEventIncidentResolved._({
    required this.rideId,
    required this.incidentId,
    this.resolutionNotes,
    required this.resolvedAt,
  }) : super._();
  @override
  WsEventIncidentResolved rebuild(
    void Function(WsEventIncidentResolvedBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  WsEventIncidentResolvedBuilder toBuilder() =>
      WsEventIncidentResolvedBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WsEventIncidentResolved &&
        rideId == other.rideId &&
        incidentId == other.incidentId &&
        resolutionNotes == other.resolutionNotes &&
        resolvedAt == other.resolvedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, rideId.hashCode);
    _$hash = $jc(_$hash, incidentId.hashCode);
    _$hash = $jc(_$hash, resolutionNotes.hashCode);
    _$hash = $jc(_$hash, resolvedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'WsEventIncidentResolved')
          ..add('rideId', rideId)
          ..add('incidentId', incidentId)
          ..add('resolutionNotes', resolutionNotes)
          ..add('resolvedAt', resolvedAt))
        .toString();
  }
}

class WsEventIncidentResolvedBuilder
    implements
        Builder<WsEventIncidentResolved, WsEventIncidentResolvedBuilder> {
  _$WsEventIncidentResolved? _$v;

  String? _rideId;
  String? get rideId => _$this._rideId;
  set rideId(String? rideId) => _$this._rideId = rideId;

  String? _incidentId;
  String? get incidentId => _$this._incidentId;
  set incidentId(String? incidentId) => _$this._incidentId = incidentId;

  String? _resolutionNotes;
  String? get resolutionNotes => _$this._resolutionNotes;
  set resolutionNotes(String? resolutionNotes) =>
      _$this._resolutionNotes = resolutionNotes;

  DateTime? _resolvedAt;
  DateTime? get resolvedAt => _$this._resolvedAt;
  set resolvedAt(DateTime? resolvedAt) => _$this._resolvedAt = resolvedAt;

  WsEventIncidentResolvedBuilder() {
    WsEventIncidentResolved._defaults(this);
  }

  WsEventIncidentResolvedBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _rideId = $v.rideId;
      _incidentId = $v.incidentId;
      _resolutionNotes = $v.resolutionNotes;
      _resolvedAt = $v.resolvedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WsEventIncidentResolved other) {
    _$v = other as _$WsEventIncidentResolved;
  }

  @override
  void update(void Function(WsEventIncidentResolvedBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WsEventIncidentResolved build() => _build();

  _$WsEventIncidentResolved _build() {
    final _$result =
        _$v ??
        _$WsEventIncidentResolved._(
          rideId: BuiltValueNullFieldError.checkNotNull(
            rideId,
            r'WsEventIncidentResolved',
            'rideId',
          ),
          incidentId: BuiltValueNullFieldError.checkNotNull(
            incidentId,
            r'WsEventIncidentResolved',
            'incidentId',
          ),
          resolutionNotes: resolutionNotes,
          resolvedAt: BuiltValueNullFieldError.checkNotNull(
            resolvedAt,
            r'WsEventIncidentResolved',
            'resolvedAt',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

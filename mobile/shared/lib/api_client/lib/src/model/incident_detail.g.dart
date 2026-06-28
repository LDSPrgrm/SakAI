// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'incident_detail.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$IncidentDetail extends IncidentDetail {
  @override
  final Incident incident;
  @override
  final BuiltList<IncidentStatusEvent> statusHistory;
  @override
  final BuiltList<IncidentLocationPoint>? locationTrail;

  factory _$IncidentDetail([void Function(IncidentDetailBuilder)? updates]) =>
      (IncidentDetailBuilder()..update(updates))._build();

  _$IncidentDetail._({
    required this.incident,
    required this.statusHistory,
    this.locationTrail,
  }) : super._();
  @override
  IncidentDetail rebuild(void Function(IncidentDetailBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  IncidentDetailBuilder toBuilder() => IncidentDetailBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is IncidentDetail &&
        incident == other.incident &&
        statusHistory == other.statusHistory &&
        locationTrail == other.locationTrail;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, incident.hashCode);
    _$hash = $jc(_$hash, statusHistory.hashCode);
    _$hash = $jc(_$hash, locationTrail.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'IncidentDetail')
          ..add('incident', incident)
          ..add('statusHistory', statusHistory)
          ..add('locationTrail', locationTrail))
        .toString();
  }
}

class IncidentDetailBuilder
    implements Builder<IncidentDetail, IncidentDetailBuilder> {
  _$IncidentDetail? _$v;

  IncidentBuilder? _incident;
  IncidentBuilder get incident => _$this._incident ??= IncidentBuilder();
  set incident(IncidentBuilder? incident) => _$this._incident = incident;

  ListBuilder<IncidentStatusEvent>? _statusHistory;
  ListBuilder<IncidentStatusEvent> get statusHistory =>
      _$this._statusHistory ??= ListBuilder<IncidentStatusEvent>();
  set statusHistory(ListBuilder<IncidentStatusEvent>? statusHistory) =>
      _$this._statusHistory = statusHistory;

  ListBuilder<IncidentLocationPoint>? _locationTrail;
  ListBuilder<IncidentLocationPoint> get locationTrail =>
      _$this._locationTrail ??= ListBuilder<IncidentLocationPoint>();
  set locationTrail(ListBuilder<IncidentLocationPoint>? locationTrail) =>
      _$this._locationTrail = locationTrail;

  IncidentDetailBuilder() {
    IncidentDetail._defaults(this);
  }

  IncidentDetailBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _incident = $v.incident.toBuilder();
      _statusHistory = $v.statusHistory.toBuilder();
      _locationTrail = $v.locationTrail?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(IncidentDetail other) {
    _$v = other as _$IncidentDetail;
  }

  @override
  void update(void Function(IncidentDetailBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  IncidentDetail build() => _build();

  _$IncidentDetail _build() {
    _$IncidentDetail _$result;
    try {
      _$result =
          _$v ??
          _$IncidentDetail._(
            incident: incident.build(),
            statusHistory: statusHistory.build(),
            locationTrail: _locationTrail?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'incident';
        incident.build();
        _$failedField = 'statusHistory';
        statusHistory.build();
        _$failedField = 'locationTrail';
        _locationTrail?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'IncidentDetail',
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

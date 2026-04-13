// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'incident.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const IncidentTypeEnum _$incidentTypeEnum_sosTriggered =
    const IncidentTypeEnum._('sosTriggered');
const IncidentTypeEnum _$incidentTypeEnum_reportedIncident =
    const IncidentTypeEnum._('reportedIncident');
const IncidentTypeEnum _$incidentTypeEnum_safetyComplaint =
    const IncidentTypeEnum._('safetyComplaint');

IncidentTypeEnum _$incidentTypeEnumValueOf(String name) {
  switch (name) {
    case 'sosTriggered':
      return _$incidentTypeEnum_sosTriggered;
    case 'reportedIncident':
      return _$incidentTypeEnum_reportedIncident;
    case 'safetyComplaint':
      return _$incidentTypeEnum_safetyComplaint;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<IncidentTypeEnum> _$incidentTypeEnumValues =
    BuiltSet<IncidentTypeEnum>(const <IncidentTypeEnum>[
  _$incidentTypeEnum_sosTriggered,
  _$incidentTypeEnum_reportedIncident,
  _$incidentTypeEnum_safetyComplaint,
]);

const IncidentSeverityEnum _$incidentSeverityEnum_low =
    const IncidentSeverityEnum._('low');
const IncidentSeverityEnum _$incidentSeverityEnum_medium =
    const IncidentSeverityEnum._('medium');
const IncidentSeverityEnum _$incidentSeverityEnum_high =
    const IncidentSeverityEnum._('high');

IncidentSeverityEnum _$incidentSeverityEnumValueOf(String name) {
  switch (name) {
    case 'low':
      return _$incidentSeverityEnum_low;
    case 'medium':
      return _$incidentSeverityEnum_medium;
    case 'high':
      return _$incidentSeverityEnum_high;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<IncidentSeverityEnum> _$incidentSeverityEnumValues =
    BuiltSet<IncidentSeverityEnum>(const <IncidentSeverityEnum>[
  _$incidentSeverityEnum_low,
  _$incidentSeverityEnum_medium,
  _$incidentSeverityEnum_high,
]);

const IncidentStatusEnum _$incidentStatusEnum_open =
    const IncidentStatusEnum._('open');
const IncidentStatusEnum _$incidentStatusEnum_investigating =
    const IncidentStatusEnum._('investigating');
const IncidentStatusEnum _$incidentStatusEnum_resolved =
    const IncidentStatusEnum._('resolved');
const IncidentStatusEnum _$incidentStatusEnum_escalated =
    const IncidentStatusEnum._('escalated');

IncidentStatusEnum _$incidentStatusEnumValueOf(String name) {
  switch (name) {
    case 'open':
      return _$incidentStatusEnum_open;
    case 'investigating':
      return _$incidentStatusEnum_investigating;
    case 'resolved':
      return _$incidentStatusEnum_resolved;
    case 'escalated':
      return _$incidentStatusEnum_escalated;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<IncidentStatusEnum> _$incidentStatusEnumValues =
    BuiltSet<IncidentStatusEnum>(const <IncidentStatusEnum>[
  _$incidentStatusEnum_open,
  _$incidentStatusEnum_investigating,
  _$incidentStatusEnum_resolved,
  _$incidentStatusEnum_escalated,
]);

const IncidentTriggeredByEnum _$incidentTriggeredByEnum_rider =
    const IncidentTriggeredByEnum._('rider');
const IncidentTriggeredByEnum _$incidentTriggeredByEnum_driver =
    const IncidentTriggeredByEnum._('driver');

IncidentTriggeredByEnum _$incidentTriggeredByEnumValueOf(String name) {
  switch (name) {
    case 'rider':
      return _$incidentTriggeredByEnum_rider;
    case 'driver':
      return _$incidentTriggeredByEnum_driver;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<IncidentTriggeredByEnum> _$incidentTriggeredByEnumValues =
    BuiltSet<IncidentTriggeredByEnum>(const <IncidentTriggeredByEnum>[
  _$incidentTriggeredByEnum_rider,
  _$incidentTriggeredByEnum_driver,
]);

Serializer<IncidentTypeEnum> _$incidentTypeEnumSerializer =
    _$IncidentTypeEnumSerializer();
Serializer<IncidentSeverityEnum> _$incidentSeverityEnumSerializer =
    _$IncidentSeverityEnumSerializer();
Serializer<IncidentStatusEnum> _$incidentStatusEnumSerializer =
    _$IncidentStatusEnumSerializer();
Serializer<IncidentTriggeredByEnum> _$incidentTriggeredByEnumSerializer =
    _$IncidentTriggeredByEnumSerializer();

class _$IncidentTypeEnumSerializer
    implements PrimitiveSerializer<IncidentTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'sosTriggered': 'sos_triggered',
    'reportedIncident': 'reported_incident',
    'safetyComplaint': 'safety_complaint',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'sos_triggered': 'sosTriggered',
    'reported_incident': 'reportedIncident',
    'safety_complaint': 'safetyComplaint',
  };

  @override
  final Iterable<Type> types = const <Type>[IncidentTypeEnum];
  @override
  final String wireName = 'IncidentTypeEnum';

  @override
  Object serialize(Serializers serializers, IncidentTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  IncidentTypeEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      IncidentTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$IncidentSeverityEnumSerializer
    implements PrimitiveSerializer<IncidentSeverityEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'low': 'low',
    'medium': 'medium',
    'high': 'high',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'low': 'low',
    'medium': 'medium',
    'high': 'high',
  };

  @override
  final Iterable<Type> types = const <Type>[IncidentSeverityEnum];
  @override
  final String wireName = 'IncidentSeverityEnum';

  @override
  Object serialize(Serializers serializers, IncidentSeverityEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  IncidentSeverityEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      IncidentSeverityEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$IncidentStatusEnumSerializer
    implements PrimitiveSerializer<IncidentStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'open': 'open',
    'investigating': 'investigating',
    'resolved': 'resolved',
    'escalated': 'escalated',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'open': 'open',
    'investigating': 'investigating',
    'resolved': 'resolved',
    'escalated': 'escalated',
  };

  @override
  final Iterable<Type> types = const <Type>[IncidentStatusEnum];
  @override
  final String wireName = 'IncidentStatusEnum';

  @override
  Object serialize(Serializers serializers, IncidentStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  IncidentStatusEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      IncidentStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$IncidentTriggeredByEnumSerializer
    implements PrimitiveSerializer<IncidentTriggeredByEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'rider': 'rider',
    'driver': 'driver',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'rider': 'rider',
    'driver': 'driver',
  };

  @override
  final Iterable<Type> types = const <Type>[IncidentTriggeredByEnum];
  @override
  final String wireName = 'IncidentTriggeredByEnum';

  @override
  Object serialize(Serializers serializers, IncidentTriggeredByEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  IncidentTriggeredByEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      IncidentTriggeredByEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$Incident extends Incident {
  @override
  final String? id;
  @override
  final String? rideId;
  @override
  final IncidentTypeEnum? type;
  @override
  final IncidentSeverityEnum? severity;
  @override
  final IncidentStatusEnum? status;
  @override
  final IncidentTriggeredByEnum? triggeredBy;
  @override
  final String? riderId;
  @override
  final String? riderName;
  @override
  final String? driverId;
  @override
  final String? driverName;
  @override
  final String? assignedTo;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? resolvedAt;
  @override
  final String? resolutionNotes;

  factory _$Incident([void Function(IncidentBuilder)? updates]) =>
      (IncidentBuilder()..update(updates))._build();

  _$Incident._(
      {this.id,
      this.rideId,
      this.type,
      this.severity,
      this.status,
      this.triggeredBy,
      this.riderId,
      this.riderName,
      this.driverId,
      this.driverName,
      this.assignedTo,
      this.createdAt,
      this.resolvedAt,
      this.resolutionNotes})
      : super._();
  @override
  Incident rebuild(void Function(IncidentBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  IncidentBuilder toBuilder() => IncidentBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Incident &&
        id == other.id &&
        rideId == other.rideId &&
        type == other.type &&
        severity == other.severity &&
        status == other.status &&
        triggeredBy == other.triggeredBy &&
        riderId == other.riderId &&
        riderName == other.riderName &&
        driverId == other.driverId &&
        driverName == other.driverName &&
        assignedTo == other.assignedTo &&
        createdAt == other.createdAt &&
        resolvedAt == other.resolvedAt &&
        resolutionNotes == other.resolutionNotes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, rideId.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, severity.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, triggeredBy.hashCode);
    _$hash = $jc(_$hash, riderId.hashCode);
    _$hash = $jc(_$hash, riderName.hashCode);
    _$hash = $jc(_$hash, driverId.hashCode);
    _$hash = $jc(_$hash, driverName.hashCode);
    _$hash = $jc(_$hash, assignedTo.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, resolvedAt.hashCode);
    _$hash = $jc(_$hash, resolutionNotes.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Incident')
          ..add('id', id)
          ..add('rideId', rideId)
          ..add('type', type)
          ..add('severity', severity)
          ..add('status', status)
          ..add('triggeredBy', triggeredBy)
          ..add('riderId', riderId)
          ..add('riderName', riderName)
          ..add('driverId', driverId)
          ..add('driverName', driverName)
          ..add('assignedTo', assignedTo)
          ..add('createdAt', createdAt)
          ..add('resolvedAt', resolvedAt)
          ..add('resolutionNotes', resolutionNotes))
        .toString();
  }
}

class IncidentBuilder implements Builder<Incident, IncidentBuilder> {
  _$Incident? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _rideId;
  String? get rideId => _$this._rideId;
  set rideId(String? rideId) => _$this._rideId = rideId;

  IncidentTypeEnum? _type;
  IncidentTypeEnum? get type => _$this._type;
  set type(IncidentTypeEnum? type) => _$this._type = type;

  IncidentSeverityEnum? _severity;
  IncidentSeverityEnum? get severity => _$this._severity;
  set severity(IncidentSeverityEnum? severity) => _$this._severity = severity;

  IncidentStatusEnum? _status;
  IncidentStatusEnum? get status => _$this._status;
  set status(IncidentStatusEnum? status) => _$this._status = status;

  IncidentTriggeredByEnum? _triggeredBy;
  IncidentTriggeredByEnum? get triggeredBy => _$this._triggeredBy;
  set triggeredBy(IncidentTriggeredByEnum? triggeredBy) =>
      _$this._triggeredBy = triggeredBy;

  String? _riderId;
  String? get riderId => _$this._riderId;
  set riderId(String? riderId) => _$this._riderId = riderId;

  String? _riderName;
  String? get riderName => _$this._riderName;
  set riderName(String? riderName) => _$this._riderName = riderName;

  String? _driverId;
  String? get driverId => _$this._driverId;
  set driverId(String? driverId) => _$this._driverId = driverId;

  String? _driverName;
  String? get driverName => _$this._driverName;
  set driverName(String? driverName) => _$this._driverName = driverName;

  String? _assignedTo;
  String? get assignedTo => _$this._assignedTo;
  set assignedTo(String? assignedTo) => _$this._assignedTo = assignedTo;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _resolvedAt;
  DateTime? get resolvedAt => _$this._resolvedAt;
  set resolvedAt(DateTime? resolvedAt) => _$this._resolvedAt = resolvedAt;

  String? _resolutionNotes;
  String? get resolutionNotes => _$this._resolutionNotes;
  set resolutionNotes(String? resolutionNotes) =>
      _$this._resolutionNotes = resolutionNotes;

  IncidentBuilder() {
    Incident._defaults(this);
  }

  IncidentBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _rideId = $v.rideId;
      _type = $v.type;
      _severity = $v.severity;
      _status = $v.status;
      _triggeredBy = $v.triggeredBy;
      _riderId = $v.riderId;
      _riderName = $v.riderName;
      _driverId = $v.driverId;
      _driverName = $v.driverName;
      _assignedTo = $v.assignedTo;
      _createdAt = $v.createdAt;
      _resolvedAt = $v.resolvedAt;
      _resolutionNotes = $v.resolutionNotes;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Incident other) {
    _$v = other as _$Incident;
  }

  @override
  void update(void Function(IncidentBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Incident build() => _build();

  _$Incident _build() {
    final _$result = _$v ??
        _$Incident._(
          id: id,
          rideId: rideId,
          type: type,
          severity: severity,
          status: status,
          triggeredBy: triggeredBy,
          riderId: riderId,
          riderName: riderName,
          driverId: driverId,
          driverName: driverName,
          assignedTo: assignedTo,
          createdAt: createdAt,
          resolvedAt: resolvedAt,
          resolutionNotes: resolutionNotes,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

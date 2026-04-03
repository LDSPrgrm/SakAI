// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'incident.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const IncidentStatusEnum _$incidentStatusEnum_open = const IncidentStatusEnum._(
  'open',
);
const IncidentStatusEnum _$incidentStatusEnum_restricted =
    const IncidentStatusEnum._('restricted');
const IncidentStatusEnum _$incidentStatusEnum_resolved =
    const IncidentStatusEnum._('resolved');

IncidentStatusEnum _$incidentStatusEnumValueOf(String name) {
  switch (name) {
    case 'open':
      return _$incidentStatusEnum_open;
    case 'restricted':
      return _$incidentStatusEnum_restricted;
    case 'resolved':
      return _$incidentStatusEnum_resolved;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<IncidentStatusEnum> _$incidentStatusEnumValues =
    BuiltSet<IncidentStatusEnum>(const <IncidentStatusEnum>[
      _$incidentStatusEnum_open,
      _$incidentStatusEnum_restricted,
      _$incidentStatusEnum_resolved,
    ]);

Serializer<IncidentStatusEnum> _$incidentStatusEnumSerializer =
    _$IncidentStatusEnumSerializer();

class _$IncidentStatusEnumSerializer
    implements PrimitiveSerializer<IncidentStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'open': 'open',
    'restricted': 'restricted',
    'resolved': 'resolved',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'open': 'open',
    'restricted': 'restricted',
    'resolved': 'resolved',
  };

  @override
  final Iterable<Type> types = const <Type>[IncidentStatusEnum];
  @override
  final String wireName = 'IncidentStatusEnum';

  @override
  Object serialize(
    Serializers serializers,
    IncidentStatusEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  IncidentStatusEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => IncidentStatusEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$Incident extends Incident {
  @override
  final String? id;
  @override
  final String? rideId;
  @override
  final String? type;
  @override
  final IncidentStatusEnum? status;
  @override
  final String? triggeredBy;
  @override
  final String? riderId;
  @override
  final String? driverId;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? resolvedAt;
  @override
  final String? resolutionNotes;

  factory _$Incident([void Function(IncidentBuilder)? updates]) =>
      (IncidentBuilder()..update(updates))._build();

  _$Incident._({
    this.id,
    this.rideId,
    this.type,
    this.status,
    this.triggeredBy,
    this.riderId,
    this.driverId,
    this.createdAt,
    this.resolvedAt,
    this.resolutionNotes,
  }) : super._();
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
        status == other.status &&
        triggeredBy == other.triggeredBy &&
        riderId == other.riderId &&
        driverId == other.driverId &&
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
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, triggeredBy.hashCode);
    _$hash = $jc(_$hash, riderId.hashCode);
    _$hash = $jc(_$hash, driverId.hashCode);
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
          ..add('status', status)
          ..add('triggeredBy', triggeredBy)
          ..add('riderId', riderId)
          ..add('driverId', driverId)
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

  String? _type;
  String? get type => _$this._type;
  set type(String? type) => _$this._type = type;

  IncidentStatusEnum? _status;
  IncidentStatusEnum? get status => _$this._status;
  set status(IncidentStatusEnum? status) => _$this._status = status;

  String? _triggeredBy;
  String? get triggeredBy => _$this._triggeredBy;
  set triggeredBy(String? triggeredBy) => _$this._triggeredBy = triggeredBy;

  String? _riderId;
  String? get riderId => _$this._riderId;
  set riderId(String? riderId) => _$this._riderId = riderId;

  String? _driverId;
  String? get driverId => _$this._driverId;
  set driverId(String? driverId) => _$this._driverId = driverId;

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
      _status = $v.status;
      _triggeredBy = $v.triggeredBy;
      _riderId = $v.riderId;
      _driverId = $v.driverId;
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
    final _$result =
        _$v ??
        _$Incident._(
          id: id,
          rideId: rideId,
          type: type,
          status: status,
          triggeredBy: triggeredBy,
          riderId: riderId,
          driverId: driverId,
          createdAt: createdAt,
          resolvedAt: resolvedAt,
          resolutionNotes: resolutionNotes,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

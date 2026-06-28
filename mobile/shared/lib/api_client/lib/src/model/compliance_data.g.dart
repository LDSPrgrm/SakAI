// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compliance_data.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ComplianceDataAccreditationStatusEnum
_$complianceDataAccreditationStatusEnum_active =
    const ComplianceDataAccreditationStatusEnum._('active');
const ComplianceDataAccreditationStatusEnum
_$complianceDataAccreditationStatusEnum_expiring =
    const ComplianceDataAccreditationStatusEnum._('expiring');
const ComplianceDataAccreditationStatusEnum
_$complianceDataAccreditationStatusEnum_expired =
    const ComplianceDataAccreditationStatusEnum._('expired');
const ComplianceDataAccreditationStatusEnum
_$complianceDataAccreditationStatusEnum_pending =
    const ComplianceDataAccreditationStatusEnum._('pending');

ComplianceDataAccreditationStatusEnum
_$complianceDataAccreditationStatusEnumValueOf(String name) {
  switch (name) {
    case 'active':
      return _$complianceDataAccreditationStatusEnum_active;
    case 'expiring':
      return _$complianceDataAccreditationStatusEnum_expiring;
    case 'expired':
      return _$complianceDataAccreditationStatusEnum_expired;
    case 'pending':
      return _$complianceDataAccreditationStatusEnum_pending;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ComplianceDataAccreditationStatusEnum>
_$complianceDataAccreditationStatusEnumValues =
    BuiltSet<ComplianceDataAccreditationStatusEnum>(
      const <ComplianceDataAccreditationStatusEnum>[
        _$complianceDataAccreditationStatusEnum_active,
        _$complianceDataAccreditationStatusEnum_expiring,
        _$complianceDataAccreditationStatusEnum_expired,
        _$complianceDataAccreditationStatusEnum_pending,
      ],
    );

Serializer<ComplianceDataAccreditationStatusEnum>
_$complianceDataAccreditationStatusEnumSerializer =
    _$ComplianceDataAccreditationStatusEnumSerializer();

class _$ComplianceDataAccreditationStatusEnumSerializer
    implements PrimitiveSerializer<ComplianceDataAccreditationStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'active': 'active',
    'expiring': 'expiring',
    'expired': 'expired',
    'pending': 'pending',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'active': 'active',
    'expiring': 'expiring',
    'expired': 'expired',
    'pending': 'pending',
  };

  @override
  final Iterable<Type> types = const <Type>[
    ComplianceDataAccreditationStatusEnum,
  ];
  @override
  final String wireName = 'ComplianceDataAccreditationStatusEnum';

  @override
  Object serialize(
    Serializers serializers,
    ComplianceDataAccreditationStatusEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ComplianceDataAccreditationStatusEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ComplianceDataAccreditationStatusEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ComplianceData extends ComplianceData {
  @override
  final ComplianceDataAccreditationStatusEnum? accreditationStatus;
  @override
  final DateTime? accreditationExpiry;
  @override
  final num? driverComplianceRate;
  @override
  final int? violationCount;
  @override
  final int? violationsOpen;
  @override
  final int? violationsResolved;
  @override
  final DateTime? lastAuditAt;

  factory _$ComplianceData([void Function(ComplianceDataBuilder)? updates]) =>
      (ComplianceDataBuilder()..update(updates))._build();

  _$ComplianceData._({
    this.accreditationStatus,
    this.accreditationExpiry,
    this.driverComplianceRate,
    this.violationCount,
    this.violationsOpen,
    this.violationsResolved,
    this.lastAuditAt,
  }) : super._();
  @override
  ComplianceData rebuild(void Function(ComplianceDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ComplianceDataBuilder toBuilder() => ComplianceDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ComplianceData &&
        accreditationStatus == other.accreditationStatus &&
        accreditationExpiry == other.accreditationExpiry &&
        driverComplianceRate == other.driverComplianceRate &&
        violationCount == other.violationCount &&
        violationsOpen == other.violationsOpen &&
        violationsResolved == other.violationsResolved &&
        lastAuditAt == other.lastAuditAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, accreditationStatus.hashCode);
    _$hash = $jc(_$hash, accreditationExpiry.hashCode);
    _$hash = $jc(_$hash, driverComplianceRate.hashCode);
    _$hash = $jc(_$hash, violationCount.hashCode);
    _$hash = $jc(_$hash, violationsOpen.hashCode);
    _$hash = $jc(_$hash, violationsResolved.hashCode);
    _$hash = $jc(_$hash, lastAuditAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ComplianceData')
          ..add('accreditationStatus', accreditationStatus)
          ..add('accreditationExpiry', accreditationExpiry)
          ..add('driverComplianceRate', driverComplianceRate)
          ..add('violationCount', violationCount)
          ..add('violationsOpen', violationsOpen)
          ..add('violationsResolved', violationsResolved)
          ..add('lastAuditAt', lastAuditAt))
        .toString();
  }
}

class ComplianceDataBuilder
    implements Builder<ComplianceData, ComplianceDataBuilder> {
  _$ComplianceData? _$v;

  ComplianceDataAccreditationStatusEnum? _accreditationStatus;
  ComplianceDataAccreditationStatusEnum? get accreditationStatus =>
      _$this._accreditationStatus;
  set accreditationStatus(
    ComplianceDataAccreditationStatusEnum? accreditationStatus,
  ) => _$this._accreditationStatus = accreditationStatus;

  DateTime? _accreditationExpiry;
  DateTime? get accreditationExpiry => _$this._accreditationExpiry;
  set accreditationExpiry(DateTime? accreditationExpiry) =>
      _$this._accreditationExpiry = accreditationExpiry;

  num? _driverComplianceRate;
  num? get driverComplianceRate => _$this._driverComplianceRate;
  set driverComplianceRate(num? driverComplianceRate) =>
      _$this._driverComplianceRate = driverComplianceRate;

  int? _violationCount;
  int? get violationCount => _$this._violationCount;
  set violationCount(int? violationCount) =>
      _$this._violationCount = violationCount;

  int? _violationsOpen;
  int? get violationsOpen => _$this._violationsOpen;
  set violationsOpen(int? violationsOpen) =>
      _$this._violationsOpen = violationsOpen;

  int? _violationsResolved;
  int? get violationsResolved => _$this._violationsResolved;
  set violationsResolved(int? violationsResolved) =>
      _$this._violationsResolved = violationsResolved;

  DateTime? _lastAuditAt;
  DateTime? get lastAuditAt => _$this._lastAuditAt;
  set lastAuditAt(DateTime? lastAuditAt) => _$this._lastAuditAt = lastAuditAt;

  ComplianceDataBuilder() {
    ComplianceData._defaults(this);
  }

  ComplianceDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _accreditationStatus = $v.accreditationStatus;
      _accreditationExpiry = $v.accreditationExpiry;
      _driverComplianceRate = $v.driverComplianceRate;
      _violationCount = $v.violationCount;
      _violationsOpen = $v.violationsOpen;
      _violationsResolved = $v.violationsResolved;
      _lastAuditAt = $v.lastAuditAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ComplianceData other) {
    _$v = other as _$ComplianceData;
  }

  @override
  void update(void Function(ComplianceDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ComplianceData build() => _build();

  _$ComplianceData _build() {
    final _$result =
        _$v ??
        _$ComplianceData._(
          accreditationStatus: accreditationStatus,
          accreditationExpiry: accreditationExpiry,
          driverComplianceRate: driverComplianceRate,
          violationCount: violationCount,
          violationsOpen: violationsOpen,
          violationsResolved: violationsResolved,
          lastAuditAt: lastAuditAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

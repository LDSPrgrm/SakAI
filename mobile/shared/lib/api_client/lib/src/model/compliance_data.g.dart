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

ComplianceDataAccreditationStatusEnum
    _$complianceDataAccreditationStatusEnumValueOf(String name) {
  switch (name) {
    case 'active':
      return _$complianceDataAccreditationStatusEnum_active;
    case 'expiring':
      return _$complianceDataAccreditationStatusEnum_expiring;
    case 'expired':
      return _$complianceDataAccreditationStatusEnum_expired;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ComplianceDataAccreditationStatusEnum>
    _$complianceDataAccreditationStatusEnumValues = BuiltSet<
        ComplianceDataAccreditationStatusEnum>(const <ComplianceDataAccreditationStatusEnum>[
  _$complianceDataAccreditationStatusEnum_active,
  _$complianceDataAccreditationStatusEnum_expiring,
  _$complianceDataAccreditationStatusEnum_expired,
]);

Serializer<ComplianceDataAccreditationStatusEnum>
    _$complianceDataAccreditationStatusEnumSerializer =
    _$ComplianceDataAccreditationStatusEnumSerializer();

class _$ComplianceDataAccreditationStatusEnumSerializer
    implements PrimitiveSerializer<ComplianceDataAccreditationStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'active': 'active',
    'expiring': 'expiring',
    'expired': 'expired',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'active': 'active',
    'expiring': 'expiring',
    'expired': 'expired',
  };

  @override
  final Iterable<Type> types = const <Type>[
    ComplianceDataAccreditationStatusEnum
  ];
  @override
  final String wireName = 'ComplianceDataAccreditationStatusEnum';

  @override
  Object serialize(
          Serializers serializers, ComplianceDataAccreditationStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ComplianceDataAccreditationStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ComplianceDataAccreditationStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
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

  factory _$ComplianceData([void Function(ComplianceDataBuilder)? updates]) =>
      (ComplianceDataBuilder()..update(updates))._build();

  _$ComplianceData._(
      {this.accreditationStatus,
      this.accreditationExpiry,
      this.driverComplianceRate,
      this.violationCount})
      : super._();
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
        violationCount == other.violationCount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, accreditationStatus.hashCode);
    _$hash = $jc(_$hash, accreditationExpiry.hashCode);
    _$hash = $jc(_$hash, driverComplianceRate.hashCode);
    _$hash = $jc(_$hash, violationCount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ComplianceData')
          ..add('accreditationStatus', accreditationStatus)
          ..add('accreditationExpiry', accreditationExpiry)
          ..add('driverComplianceRate', driverComplianceRate)
          ..add('violationCount', violationCount))
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
          ComplianceDataAccreditationStatusEnum? accreditationStatus) =>
      _$this._accreditationStatus = accreditationStatus;

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
    final _$result = _$v ??
        _$ComplianceData._(
          accreditationStatus: accreditationStatus,
          accreditationExpiry: accreditationExpiry,
          driverComplianceRate: driverComplianceRate,
          violationCount: violationCount,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

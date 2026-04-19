// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'compliance_data.g.dart';

/// ComplianceData
///
/// Properties:
/// * [accreditationStatus] 
/// * [accreditationExpiry] 
/// * [driverComplianceRate] - Percentage of drivers with valid documents (0–100)
/// * [violationCount] - LTFRB-reportable violations in current period
@BuiltValue()
abstract class ComplianceData implements Built<ComplianceData, ComplianceDataBuilder> {
  @BuiltValueField(wireName: r'accreditation_status')
  ComplianceDataAccreditationStatusEnum? get accreditationStatus;
  // enum accreditationStatusEnum {  active,  expiring,  expired,  };

  @BuiltValueField(wireName: r'accreditation_expiry')
  DateTime? get accreditationExpiry;

  /// Percentage of drivers with valid documents (0–100)
  @BuiltValueField(wireName: r'driver_compliance_rate')
  num? get driverComplianceRate;

  /// LTFRB-reportable violations in current period
  @BuiltValueField(wireName: r'violation_count')
  int? get violationCount;

  ComplianceData._();

  factory ComplianceData([void updates(ComplianceDataBuilder b)]) = _$ComplianceData;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ComplianceDataBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ComplianceData> get serializer => _$ComplianceDataSerializer();
}

class _$ComplianceDataSerializer implements PrimitiveSerializer<ComplianceData> {
  @override
  final Iterable<Type> types = const [ComplianceData, _$ComplianceData];

  @override
  final String wireName = r'ComplianceData';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ComplianceData object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.accreditationStatus != null) {
      yield r'accreditation_status';
      yield serializers.serialize(
        object.accreditationStatus,
        specifiedType: const FullType(ComplianceDataAccreditationStatusEnum),
      );
    }
    if (object.accreditationExpiry != null) {
      yield r'accreditation_expiry';
      yield serializers.serialize(
        object.accreditationExpiry,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.driverComplianceRate != null) {
      yield r'driver_compliance_rate';
      yield serializers.serialize(
        object.driverComplianceRate,
        specifiedType: const FullType(num),
      );
    }
    if (object.violationCount != null) {
      yield r'violation_count';
      yield serializers.serialize(
        object.violationCount,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ComplianceData object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ComplianceDataBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'accreditation_status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ComplianceDataAccreditationStatusEnum),
          ) as ComplianceDataAccreditationStatusEnum;
          result.accreditationStatus = valueDes;
          break;
        case r'accreditation_expiry':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.accreditationExpiry = valueDes;
          break;
        case r'driver_compliance_rate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.driverComplianceRate = valueDes;
          break;
        case r'violation_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.violationCount = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ComplianceData deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ComplianceDataBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}

class ComplianceDataAccreditationStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'active')
  static const ComplianceDataAccreditationStatusEnum active = _$complianceDataAccreditationStatusEnum_active;
  @BuiltValueEnumConst(wireName: r'expiring')
  static const ComplianceDataAccreditationStatusEnum expiring = _$complianceDataAccreditationStatusEnum_expiring;
  @BuiltValueEnumConst(wireName: r'expired')
  static const ComplianceDataAccreditationStatusEnum expired = _$complianceDataAccreditationStatusEnum_expired;

  static Serializer<ComplianceDataAccreditationStatusEnum> get serializer => _$complianceDataAccreditationStatusEnumSerializer;

  const ComplianceDataAccreditationStatusEnum._(String name): super(name);

  static BuiltSet<ComplianceDataAccreditationStatusEnum> get values => _$complianceDataAccreditationStatusEnumValues;
  static ComplianceDataAccreditationStatusEnum valueOf(String name) => _$complianceDataAccreditationStatusEnumValueOf(name);
}


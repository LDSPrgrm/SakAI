// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sakai_api_client/src/model/kyc_document.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kyc_entry.g.dart';

/// KycEntry
///
/// Properties:
/// * [id] 
/// * [driverId] 
/// * [driverName] 
/// * [submittedAt] 
/// * [docs] 
/// * [status] 
@BuiltValue()
abstract class KycEntry implements Built<KycEntry, KycEntryBuilder> {
  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'driver_id')
  String? get driverId;

  @BuiltValueField(wireName: r'driver_name')
  String? get driverName;

  @BuiltValueField(wireName: r'submitted_at')
  DateTime? get submittedAt;

  @BuiltValueField(wireName: r'docs')
  BuiltList<KycDocument>? get docs;

  @BuiltValueField(wireName: r'status')
  KycEntryStatusEnum? get status;
  // enum statusEnum {  pending,  approved,  rejected,  needs_more_info,  };

  KycEntry._();

  factory KycEntry([void updates(KycEntryBuilder b)]) = _$KycEntry;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KycEntryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KycEntry> get serializer => _$KycEntrySerializer();
}

class _$KycEntrySerializer implements PrimitiveSerializer<KycEntry> {
  @override
  final Iterable<Type> types = const [KycEntry, _$KycEntry];

  @override
  final String wireName = r'KycEntry';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KycEntry object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
    if (object.driverId != null) {
      yield r'driver_id';
      yield serializers.serialize(
        object.driverId,
        specifiedType: const FullType(String),
      );
    }
    if (object.driverName != null) {
      yield r'driver_name';
      yield serializers.serialize(
        object.driverName,
        specifiedType: const FullType(String),
      );
    }
    if (object.submittedAt != null) {
      yield r'submitted_at';
      yield serializers.serialize(
        object.submittedAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.docs != null) {
      yield r'docs';
      yield serializers.serialize(
        object.docs,
        specifiedType: const FullType(BuiltList, [FullType(KycDocument)]),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(KycEntryStatusEnum),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    KycEntry object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required KycEntryBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'driver_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.driverId = valueDes;
          break;
        case r'driver_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.driverName = valueDes;
          break;
        case r'submitted_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.submittedAt = valueDes;
          break;
        case r'docs':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(KycDocument)]),
          ) as BuiltList<KycDocument>;
          result.docs.replace(valueDes);
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(KycEntryStatusEnum),
          ) as KycEntryStatusEnum;
          result.status = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  KycEntry deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KycEntryBuilder();
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

class KycEntryStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'pending')
  static const KycEntryStatusEnum pending = _$kycEntryStatusEnum_pending;
  @BuiltValueEnumConst(wireName: r'approved')
  static const KycEntryStatusEnum approved = _$kycEntryStatusEnum_approved;
  @BuiltValueEnumConst(wireName: r'rejected')
  static const KycEntryStatusEnum rejected = _$kycEntryStatusEnum_rejected;
  @BuiltValueEnumConst(wireName: r'needs_more_info')
  static const KycEntryStatusEnum needsMoreInfo = _$kycEntryStatusEnum_needsMoreInfo;

  static Serializer<KycEntryStatusEnum> get serializer => _$kycEntryStatusEnumSerializer;

  const KycEntryStatusEnum._(String name): super(name);

  static BuiltSet<KycEntryStatusEnum> get values => _$kycEntryStatusEnumValues;
  static KycEntryStatusEnum valueOf(String name) => _$kycEntryStatusEnumValueOf(name);
}


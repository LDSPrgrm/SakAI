//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'cancel_request.g.dart';

/// CancelRequest
///
/// Properties:
/// * [reasonCode] - Predefined cancellation reason
/// * [reasonText] - Free-text explanation when reason_code is \"other\"
@BuiltValue()
abstract class CancelRequest implements Built<CancelRequest, CancelRequestBuilder> {
  /// Predefined cancellation reason
  @BuiltValueField(wireName: r'reason_code')
  CancelRequestReasonCodeEnum get reasonCode;
  // enum reasonCodeEnum {  driver_too_far,  changed_plans,  wrong_pickup,  driver_not_moving,  safety_concern,  other,  };

  /// Free-text explanation when reason_code is \"other\"
  @BuiltValueField(wireName: r'reason_text')
  String? get reasonText;

  CancelRequest._();

  factory CancelRequest([void updates(CancelRequestBuilder b)]) = _$CancelRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CancelRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CancelRequest> get serializer => _$CancelRequestSerializer();
}

class _$CancelRequestSerializer implements PrimitiveSerializer<CancelRequest> {
  @override
  final Iterable<Type> types = const [CancelRequest, _$CancelRequest];

  @override
  final String wireName = r'CancelRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CancelRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'reason_code';
    yield serializers.serialize(
      object.reasonCode,
      specifiedType: const FullType(CancelRequestReasonCodeEnum),
    );
    if (object.reasonText != null) {
      yield r'reason_text';
      yield serializers.serialize(
        object.reasonText,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CancelRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CancelRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'reason_code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CancelRequestReasonCodeEnum),
          ) as CancelRequestReasonCodeEnum;
          result.reasonCode = valueDes;
          break;
        case r'reason_text':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.reasonText = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CancelRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CancelRequestBuilder();
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

class CancelRequestReasonCodeEnum extends EnumClass {

  /// Predefined cancellation reason
  @BuiltValueEnumConst(wireName: r'driver_too_far')
  static const CancelRequestReasonCodeEnum driverTooFar = _$cancelRequestReasonCodeEnum_driverTooFar;
  /// Predefined cancellation reason
  @BuiltValueEnumConst(wireName: r'changed_plans')
  static const CancelRequestReasonCodeEnum changedPlans = _$cancelRequestReasonCodeEnum_changedPlans;
  /// Predefined cancellation reason
  @BuiltValueEnumConst(wireName: r'wrong_pickup')
  static const CancelRequestReasonCodeEnum wrongPickup = _$cancelRequestReasonCodeEnum_wrongPickup;
  /// Predefined cancellation reason
  @BuiltValueEnumConst(wireName: r'driver_not_moving')
  static const CancelRequestReasonCodeEnum driverNotMoving = _$cancelRequestReasonCodeEnum_driverNotMoving;
  /// Predefined cancellation reason
  @BuiltValueEnumConst(wireName: r'safety_concern')
  static const CancelRequestReasonCodeEnum safetyConcern = _$cancelRequestReasonCodeEnum_safetyConcern;
  /// Predefined cancellation reason
  @BuiltValueEnumConst(wireName: r'other')
  static const CancelRequestReasonCodeEnum other = _$cancelRequestReasonCodeEnum_other;

  static Serializer<CancelRequestReasonCodeEnum> get serializer => _$cancelRequestReasonCodeEnumSerializer;

  const CancelRequestReasonCodeEnum._(String name): super(name);

  static BuiltSet<CancelRequestReasonCodeEnum> get values => _$cancelRequestReasonCodeEnumValues;
  static CancelRequestReasonCodeEnum valueOf(String name) => _$cancelRequestReasonCodeEnumValueOf(name);
}


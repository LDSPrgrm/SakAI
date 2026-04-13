// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'driver_status_request.g.dart';

/// DriverStatusRequest
///
/// Properties:
/// * [status] 
@BuiltValue()
abstract class DriverStatusRequest implements Built<DriverStatusRequest, DriverStatusRequestBuilder> {
  @BuiltValueField(wireName: r'status')
  DriverStatusRequestStatusEnum get status;
  // enum statusEnum {  online,  offline,  };

  DriverStatusRequest._();

  factory DriverStatusRequest([void updates(DriverStatusRequestBuilder b)]) = _$DriverStatusRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DriverStatusRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DriverStatusRequest> get serializer => _$DriverStatusRequestSerializer();
}

class _$DriverStatusRequestSerializer implements PrimitiveSerializer<DriverStatusRequest> {
  @override
  final Iterable<Type> types = const [DriverStatusRequest, _$DriverStatusRequest];

  @override
  final String wireName = r'DriverStatusRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DriverStatusRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(DriverStatusRequestStatusEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DriverStatusRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DriverStatusRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DriverStatusRequestStatusEnum),
          ) as DriverStatusRequestStatusEnum;
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
  DriverStatusRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DriverStatusRequestBuilder();
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

class DriverStatusRequestStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'online')
  static const DriverStatusRequestStatusEnum online = _$driverStatusRequestStatusEnum_online;
  @BuiltValueEnumConst(wireName: r'offline')
  static const DriverStatusRequestStatusEnum offline = _$driverStatusRequestStatusEnum_offline;

  static Serializer<DriverStatusRequestStatusEnum> get serializer => _$driverStatusRequestStatusEnumSerializer;

  const DriverStatusRequestStatusEnum._(String name): super(name);

  static BuiltSet<DriverStatusRequestStatusEnum> get values => _$driverStatusRequestStatusEnumValues;
  static DriverStatusRequestStatusEnum valueOf(String name) => _$driverStatusRequestStatusEnumValueOf(name);
}


// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'driver_status_response.g.dart';

/// DriverStatusResponse
///
/// Properties:
/// * [driverId] 
/// * [status] 
/// * [updatedAt] 
@BuiltValue()
abstract class DriverStatusResponse implements Built<DriverStatusResponse, DriverStatusResponseBuilder> {
  @BuiltValueField(wireName: r'driver_id')
  String get driverId;

  @BuiltValueField(wireName: r'status')
  DriverStatusResponseStatusEnum get status;
  // enum statusEnum {  online,  offline,  };

  @BuiltValueField(wireName: r'updated_at')
  DateTime get updatedAt;

  DriverStatusResponse._();

  factory DriverStatusResponse([void updates(DriverStatusResponseBuilder b)]) = _$DriverStatusResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DriverStatusResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DriverStatusResponse> get serializer => _$DriverStatusResponseSerializer();
}

class _$DriverStatusResponseSerializer implements PrimitiveSerializer<DriverStatusResponse> {
  @override
  final Iterable<Type> types = const [DriverStatusResponse, _$DriverStatusResponse];

  @override
  final String wireName = r'DriverStatusResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DriverStatusResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'driver_id';
    yield serializers.serialize(
      object.driverId,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(DriverStatusResponseStatusEnum),
    );
    yield r'updated_at';
    yield serializers.serialize(
      object.updatedAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DriverStatusResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DriverStatusResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'driver_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.driverId = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DriverStatusResponseStatusEnum),
          ) as DriverStatusResponseStatusEnum;
          result.status = valueDes;
          break;
        case r'updated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.updatedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DriverStatusResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DriverStatusResponseBuilder();
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

class DriverStatusResponseStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'online')
  static const DriverStatusResponseStatusEnum online = _$driverStatusResponseStatusEnum_online;
  @BuiltValueEnumConst(wireName: r'offline')
  static const DriverStatusResponseStatusEnum offline = _$driverStatusResponseStatusEnum_offline;

  static Serializer<DriverStatusResponseStatusEnum> get serializer => _$driverStatusResponseStatusEnumSerializer;

  const DriverStatusResponseStatusEnum._(String name): super(name);

  static BuiltSet<DriverStatusResponseStatusEnum> get values => _$driverStatusResponseStatusEnumValues;
  static DriverStatusResponseStatusEnum valueOf(String name) => _$driverStatusResponseStatusEnumValueOf(name);
}


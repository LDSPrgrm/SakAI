// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'add_ride_tip_request.g.dart';

/// AddRideTipRequest
///
/// Properties:
/// * [tipAmount] - Tip amount in ride currency
@BuiltValue()
abstract class AddRideTipRequest implements Built<AddRideTipRequest, AddRideTipRequestBuilder> {
  /// Tip amount in ride currency
  @BuiltValueField(wireName: r'tipAmount')
  double get tipAmount;

  AddRideTipRequest._();

  factory AddRideTipRequest([void updates(AddRideTipRequestBuilder b)]) = _$AddRideTipRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AddRideTipRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AddRideTipRequest> get serializer => _$AddRideTipRequestSerializer();
}

class _$AddRideTipRequestSerializer implements PrimitiveSerializer<AddRideTipRequest> {
  @override
  final Iterable<Type> types = const [AddRideTipRequest, _$AddRideTipRequest];

  @override
  final String wireName = r'AddRideTipRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AddRideTipRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'tipAmount';
    yield serializers.serialize(
      object.tipAmount,
      specifiedType: const FullType(double),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AddRideTipRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AddRideTipRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'tipAmount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(double),
          ) as double;
          result.tipAmount = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AddRideTipRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AddRideTipRequestBuilder();
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


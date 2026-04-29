// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'trigger_sos_request.g.dart';

/// TriggerSOSRequest
///
/// Properties:
/// * [reason] - Brief description of the emergency or reason for SOS
/// * [lat] - Current latitude of the reporter
/// * [lng] - Current longitude of the reporter
@BuiltValue()
abstract class TriggerSOSRequest implements Built<TriggerSOSRequest, TriggerSOSRequestBuilder> {
  /// Brief description of the emergency or reason for SOS
  @BuiltValueField(wireName: r'reason')
  String get reason;

  /// Current latitude of the reporter
  @BuiltValueField(wireName: r'lat')
  double? get lat;

  /// Current longitude of the reporter
  @BuiltValueField(wireName: r'lng')
  double? get lng;

  TriggerSOSRequest._();

  factory TriggerSOSRequest([void updates(TriggerSOSRequestBuilder b)]) = _$TriggerSOSRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TriggerSOSRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TriggerSOSRequest> get serializer => _$TriggerSOSRequestSerializer();
}

class _$TriggerSOSRequestSerializer implements PrimitiveSerializer<TriggerSOSRequest> {
  @override
  final Iterable<Type> types = const [TriggerSOSRequest, _$TriggerSOSRequest];

  @override
  final String wireName = r'TriggerSOSRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TriggerSOSRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'reason';
    yield serializers.serialize(
      object.reason,
      specifiedType: const FullType(String),
    );
    if (object.lat != null) {
      yield r'lat';
      yield serializers.serialize(
        object.lat,
        specifiedType: const FullType(double),
      );
    }
    if (object.lng != null) {
      yield r'lng';
      yield serializers.serialize(
        object.lng,
        specifiedType: const FullType(double),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    TriggerSOSRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TriggerSOSRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.reason = valueDes;
          break;
        case r'lat':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(double),
          ) as double;
          result.lat = valueDes;
          break;
        case r'lng':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(double),
          ) as double;
          result.lng = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TriggerSOSRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TriggerSOSRequestBuilder();
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


// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'blackout_hour.g.dart';

/// BlackoutHour
///
/// Properties:
/// * [dayOfWeek] 
/// * [startTime] 
/// * [endTime] 
@BuiltValue()
abstract class BlackoutHour implements Built<BlackoutHour, BlackoutHourBuilder> {
  @BuiltValueField(wireName: r'day_of_week')
  int? get dayOfWeek;

  @BuiltValueField(wireName: r'start_time')
  String? get startTime;

  @BuiltValueField(wireName: r'end_time')
  String? get endTime;

  BlackoutHour._();

  factory BlackoutHour([void updates(BlackoutHourBuilder b)]) = _$BlackoutHour;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BlackoutHourBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BlackoutHour> get serializer => _$BlackoutHourSerializer();
}

class _$BlackoutHourSerializer implements PrimitiveSerializer<BlackoutHour> {
  @override
  final Iterable<Type> types = const [BlackoutHour, _$BlackoutHour];

  @override
  final String wireName = r'BlackoutHour';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BlackoutHour object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.dayOfWeek != null) {
      yield r'day_of_week';
      yield serializers.serialize(
        object.dayOfWeek,
        specifiedType: const FullType(int),
      );
    }
    if (object.startTime != null) {
      yield r'start_time';
      yield serializers.serialize(
        object.startTime,
        specifiedType: const FullType(String),
      );
    }
    if (object.endTime != null) {
      yield r'end_time';
      yield serializers.serialize(
        object.endTime,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    BlackoutHour object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BlackoutHourBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'day_of_week':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.dayOfWeek = valueDes;
          break;
        case r'start_time':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.startTime = valueDes;
          break;
        case r'end_time':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.endTime = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BlackoutHour deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BlackoutHourBuilder();
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


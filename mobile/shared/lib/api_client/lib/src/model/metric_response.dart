// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'metric_response.g.dart';

/// MetricResponse
///
/// Properties:
/// * [current] - Current period value
/// * [previous] - Previous period value for comparison
/// * [changePercent] - Percentage change from previous to current
/// * [trend] 
@BuiltValue()
abstract class MetricResponse implements Built<MetricResponse, MetricResponseBuilder> {
  /// Current period value
  @BuiltValueField(wireName: r'current')
  num? get current;

  /// Previous period value for comparison
  @BuiltValueField(wireName: r'previous')
  num? get previous;

  /// Percentage change from previous to current
  @BuiltValueField(wireName: r'change_percent')
  num? get changePercent;

  @BuiltValueField(wireName: r'trend')
  MetricResponseTrendEnum? get trend;
  // enum trendEnum {  up,  down,  flat,  };

  MetricResponse._();

  factory MetricResponse([void updates(MetricResponseBuilder b)]) = _$MetricResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MetricResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MetricResponse> get serializer => _$MetricResponseSerializer();
}

class _$MetricResponseSerializer implements PrimitiveSerializer<MetricResponse> {
  @override
  final Iterable<Type> types = const [MetricResponse, _$MetricResponse];

  @override
  final String wireName = r'MetricResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MetricResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.current != null) {
      yield r'current';
      yield serializers.serialize(
        object.current,
        specifiedType: const FullType(num),
      );
    }
    if (object.previous != null) {
      yield r'previous';
      yield serializers.serialize(
        object.previous,
        specifiedType: const FullType(num),
      );
    }
    if (object.changePercent != null) {
      yield r'change_percent';
      yield serializers.serialize(
        object.changePercent,
        specifiedType: const FullType(num),
      );
    }
    if (object.trend != null) {
      yield r'trend';
      yield serializers.serialize(
        object.trend,
        specifiedType: const FullType(MetricResponseTrendEnum),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    MetricResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MetricResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'current':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.current = valueDes;
          break;
        case r'previous':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.previous = valueDes;
          break;
        case r'change_percent':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.changePercent = valueDes;
          break;
        case r'trend':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MetricResponseTrendEnum),
          ) as MetricResponseTrendEnum;
          result.trend = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MetricResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MetricResponseBuilder();
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

class MetricResponseTrendEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'up')
  static const MetricResponseTrendEnum up = _$metricResponseTrendEnum_up;
  @BuiltValueEnumConst(wireName: r'down')
  static const MetricResponseTrendEnum down = _$metricResponseTrendEnum_down;
  @BuiltValueEnumConst(wireName: r'flat')
  static const MetricResponseTrendEnum flat = _$metricResponseTrendEnum_flat;

  static Serializer<MetricResponseTrendEnum> get serializer => _$metricResponseTrendEnumSerializer;

  const MetricResponseTrendEnum._(String name): super(name);

  static BuiltSet<MetricResponseTrendEnum> get values => _$metricResponseTrendEnumValues;
  static MetricResponseTrendEnum valueOf(String name) => _$metricResponseTrendEnumValueOf(name);
}


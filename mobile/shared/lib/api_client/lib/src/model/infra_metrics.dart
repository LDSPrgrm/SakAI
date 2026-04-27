// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'infra_metrics.g.dart';

/// Aggregated infra metrics shown on the System Health page.
///
/// Properties:
/// * [apiP50Ms] - HTTP request latency p50 over window_minutes
/// * [apiP95Ms] - HTTP request latency p95 over window_minutes
/// * [wsConnections] - Current connected WebSocket client count from latest probe
/// * [dbQueryP99Ms] - Database probe latency p99 over last 24h
/// * [sampleCount] - Number of HTTP samples contributing to p50/p95
/// * [windowMinutes] - Size of the rolling window used for HTTP percentiles
@BuiltValue()
abstract class InfraMetrics implements Built<InfraMetrics, InfraMetricsBuilder> {
  /// HTTP request latency p50 over window_minutes
  @BuiltValueField(wireName: r'api_p50_ms')
  num? get apiP50Ms;

  /// HTTP request latency p95 over window_minutes
  @BuiltValueField(wireName: r'api_p95_ms')
  num? get apiP95Ms;

  /// Current connected WebSocket client count from latest probe
  @BuiltValueField(wireName: r'ws_connections')
  int? get wsConnections;

  /// Database probe latency p99 over last 24h
  @BuiltValueField(wireName: r'db_query_p99_ms')
  num? get dbQueryP99Ms;

  /// Number of HTTP samples contributing to p50/p95
  @BuiltValueField(wireName: r'sample_count')
  int? get sampleCount;

  /// Size of the rolling window used for HTTP percentiles
  @BuiltValueField(wireName: r'window_minutes')
  int? get windowMinutes;

  InfraMetrics._();

  factory InfraMetrics([void updates(InfraMetricsBuilder b)]) = _$InfraMetrics;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(InfraMetricsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<InfraMetrics> get serializer => _$InfraMetricsSerializer();
}

class _$InfraMetricsSerializer implements PrimitiveSerializer<InfraMetrics> {
  @override
  final Iterable<Type> types = const [InfraMetrics, _$InfraMetrics];

  @override
  final String wireName = r'InfraMetrics';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    InfraMetrics object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.apiP50Ms != null) {
      yield r'api_p50_ms';
      yield serializers.serialize(
        object.apiP50Ms,
        specifiedType: const FullType(num),
      );
    }
    if (object.apiP95Ms != null) {
      yield r'api_p95_ms';
      yield serializers.serialize(
        object.apiP95Ms,
        specifiedType: const FullType(num),
      );
    }
    if (object.wsConnections != null) {
      yield r'ws_connections';
      yield serializers.serialize(
        object.wsConnections,
        specifiedType: const FullType(int),
      );
    }
    if (object.dbQueryP99Ms != null) {
      yield r'db_query_p99_ms';
      yield serializers.serialize(
        object.dbQueryP99Ms,
        specifiedType: const FullType(num),
      );
    }
    if (object.sampleCount != null) {
      yield r'sample_count';
      yield serializers.serialize(
        object.sampleCount,
        specifiedType: const FullType(int),
      );
    }
    if (object.windowMinutes != null) {
      yield r'window_minutes';
      yield serializers.serialize(
        object.windowMinutes,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    InfraMetrics object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required InfraMetricsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'api_p50_ms':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.apiP50Ms = valueDes;
          break;
        case r'api_p95_ms':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.apiP95Ms = valueDes;
          break;
        case r'ws_connections':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.wsConnections = valueDes;
          break;
        case r'db_query_p99_ms':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.dbQueryP99Ms = valueDes;
          break;
        case r'sample_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.sampleCount = valueDes;
          break;
        case r'window_minutes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.windowMinutes = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  InfraMetrics deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = InfraMetricsBuilder();
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


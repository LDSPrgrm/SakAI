// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'dashboard_response.g.dart';

/// DashboardResponse
///
/// Properties:
/// * [activeRiders] 
/// * [totalRiders] 
/// * [ridersTrend] - Percentage change string (e.g. \"+12%\")
/// * [activeDrivers] 
/// * [totalDrivers] 
/// * [driversTrend] 
/// * [ridesToday] 
/// * [ridesTrend] 
/// * [revenueToday] 
/// * [revenueTrend] 
/// * [avgWaitTimeSeconds] 
/// * [avgWaitMinutes] 
/// * [waitTrend] 
/// * [systemUptime] 
/// * [platformUptime] 
@BuiltValue()
abstract class DashboardResponse implements Built<DashboardResponse, DashboardResponseBuilder> {
  @BuiltValueField(wireName: r'active_riders')
  int? get activeRiders;

  @BuiltValueField(wireName: r'total_riders')
  int? get totalRiders;

  /// Percentage change string (e.g. \"+12%\")
  @BuiltValueField(wireName: r'riders_trend')
  String? get ridersTrend;

  @BuiltValueField(wireName: r'active_drivers')
  int? get activeDrivers;

  @BuiltValueField(wireName: r'total_drivers')
  int? get totalDrivers;

  @BuiltValueField(wireName: r'drivers_trend')
  String? get driversTrend;

  @BuiltValueField(wireName: r'rides_today')
  int? get ridesToday;

  @BuiltValueField(wireName: r'rides_trend')
  String? get ridesTrend;

  @BuiltValueField(wireName: r'revenue_today')
  num? get revenueToday;

  @BuiltValueField(wireName: r'revenue_trend')
  String? get revenueTrend;

  @BuiltValueField(wireName: r'avg_wait_time_seconds')
  num? get avgWaitTimeSeconds;

  @BuiltValueField(wireName: r'avg_wait_minutes')
  num? get avgWaitMinutes;

  @BuiltValueField(wireName: r'wait_trend')
  String? get waitTrend;

  @BuiltValueField(wireName: r'system_uptime')
  num? get systemUptime;

  @BuiltValueField(wireName: r'platform_uptime')
  num? get platformUptime;

  DashboardResponse._();

  factory DashboardResponse([void updates(DashboardResponseBuilder b)]) = _$DashboardResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DashboardResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DashboardResponse> get serializer => _$DashboardResponseSerializer();
}

class _$DashboardResponseSerializer implements PrimitiveSerializer<DashboardResponse> {
  @override
  final Iterable<Type> types = const [DashboardResponse, _$DashboardResponse];

  @override
  final String wireName = r'DashboardResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DashboardResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.activeRiders != null) {
      yield r'active_riders';
      yield serializers.serialize(
        object.activeRiders,
        specifiedType: const FullType(int),
      );
    }
    if (object.totalRiders != null) {
      yield r'total_riders';
      yield serializers.serialize(
        object.totalRiders,
        specifiedType: const FullType(int),
      );
    }
    if (object.ridersTrend != null) {
      yield r'riders_trend';
      yield serializers.serialize(
        object.ridersTrend,
        specifiedType: const FullType(String),
      );
    }
    if (object.activeDrivers != null) {
      yield r'active_drivers';
      yield serializers.serialize(
        object.activeDrivers,
        specifiedType: const FullType(int),
      );
    }
    if (object.totalDrivers != null) {
      yield r'total_drivers';
      yield serializers.serialize(
        object.totalDrivers,
        specifiedType: const FullType(int),
      );
    }
    if (object.driversTrend != null) {
      yield r'drivers_trend';
      yield serializers.serialize(
        object.driversTrend,
        specifiedType: const FullType(String),
      );
    }
    if (object.ridesToday != null) {
      yield r'rides_today';
      yield serializers.serialize(
        object.ridesToday,
        specifiedType: const FullType(int),
      );
    }
    if (object.ridesTrend != null) {
      yield r'rides_trend';
      yield serializers.serialize(
        object.ridesTrend,
        specifiedType: const FullType(String),
      );
    }
    if (object.revenueToday != null) {
      yield r'revenue_today';
      yield serializers.serialize(
        object.revenueToday,
        specifiedType: const FullType(num),
      );
    }
    if (object.revenueTrend != null) {
      yield r'revenue_trend';
      yield serializers.serialize(
        object.revenueTrend,
        specifiedType: const FullType(String),
      );
    }
    if (object.avgWaitTimeSeconds != null) {
      yield r'avg_wait_time_seconds';
      yield serializers.serialize(
        object.avgWaitTimeSeconds,
        specifiedType: const FullType(num),
      );
    }
    if (object.avgWaitMinutes != null) {
      yield r'avg_wait_minutes';
      yield serializers.serialize(
        object.avgWaitMinutes,
        specifiedType: const FullType(num),
      );
    }
    if (object.waitTrend != null) {
      yield r'wait_trend';
      yield serializers.serialize(
        object.waitTrend,
        specifiedType: const FullType(String),
      );
    }
    if (object.systemUptime != null) {
      yield r'system_uptime';
      yield serializers.serialize(
        object.systemUptime,
        specifiedType: const FullType(num),
      );
    }
    if (object.platformUptime != null) {
      yield r'platform_uptime';
      yield serializers.serialize(
        object.platformUptime,
        specifiedType: const FullType(num),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    DashboardResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DashboardResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'active_riders':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.activeRiders = valueDes;
          break;
        case r'total_riders':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.totalRiders = valueDes;
          break;
        case r'riders_trend':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.ridersTrend = valueDes;
          break;
        case r'active_drivers':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.activeDrivers = valueDes;
          break;
        case r'total_drivers':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.totalDrivers = valueDes;
          break;
        case r'drivers_trend':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.driversTrend = valueDes;
          break;
        case r'rides_today':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.ridesToday = valueDes;
          break;
        case r'rides_trend':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.ridesTrend = valueDes;
          break;
        case r'revenue_today':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.revenueToday = valueDes;
          break;
        case r'revenue_trend':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.revenueTrend = valueDes;
          break;
        case r'avg_wait_time_seconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.avgWaitTimeSeconds = valueDes;
          break;
        case r'avg_wait_minutes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.avgWaitMinutes = valueDes;
          break;
        case r'wait_trend':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.waitTrend = valueDes;
          break;
        case r'system_uptime':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.systemUptime = valueDes;
          break;
        case r'platform_uptime':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.platformUptime = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DashboardResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DashboardResponseBuilder();
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


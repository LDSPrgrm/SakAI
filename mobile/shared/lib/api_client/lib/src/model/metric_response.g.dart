// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metric_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MetricResponseTrendEnum _$metricResponseTrendEnum_up =
    const MetricResponseTrendEnum._('up');
const MetricResponseTrendEnum _$metricResponseTrendEnum_down =
    const MetricResponseTrendEnum._('down');
const MetricResponseTrendEnum _$metricResponseTrendEnum_flat =
    const MetricResponseTrendEnum._('flat');

MetricResponseTrendEnum _$metricResponseTrendEnumValueOf(String name) {
  switch (name) {
    case 'up':
      return _$metricResponseTrendEnum_up;
    case 'down':
      return _$metricResponseTrendEnum_down;
    case 'flat':
      return _$metricResponseTrendEnum_flat;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<MetricResponseTrendEnum> _$metricResponseTrendEnumValues =
    BuiltSet<MetricResponseTrendEnum>(const <MetricResponseTrendEnum>[
      _$metricResponseTrendEnum_up,
      _$metricResponseTrendEnum_down,
      _$metricResponseTrendEnum_flat,
    ]);

Serializer<MetricResponseTrendEnum> _$metricResponseTrendEnumSerializer =
    _$MetricResponseTrendEnumSerializer();

class _$MetricResponseTrendEnumSerializer
    implements PrimitiveSerializer<MetricResponseTrendEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'up': 'up',
    'down': 'down',
    'flat': 'flat',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'up': 'up',
    'down': 'down',
    'flat': 'flat',
  };

  @override
  final Iterable<Type> types = const <Type>[MetricResponseTrendEnum];
  @override
  final String wireName = 'MetricResponseTrendEnum';

  @override
  Object serialize(
    Serializers serializers,
    MetricResponseTrendEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  MetricResponseTrendEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => MetricResponseTrendEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$MetricResponse extends MetricResponse {
  @override
  final num? current;
  @override
  final num? previous;
  @override
  final num? changePercent;
  @override
  final MetricResponseTrendEnum? trend;

  factory _$MetricResponse([void Function(MetricResponseBuilder)? updates]) =>
      (MetricResponseBuilder()..update(updates))._build();

  _$MetricResponse._({
    this.current,
    this.previous,
    this.changePercent,
    this.trend,
  }) : super._();
  @override
  MetricResponse rebuild(void Function(MetricResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MetricResponseBuilder toBuilder() => MetricResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MetricResponse &&
        current == other.current &&
        previous == other.previous &&
        changePercent == other.changePercent &&
        trend == other.trend;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, current.hashCode);
    _$hash = $jc(_$hash, previous.hashCode);
    _$hash = $jc(_$hash, changePercent.hashCode);
    _$hash = $jc(_$hash, trend.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MetricResponse')
          ..add('current', current)
          ..add('previous', previous)
          ..add('changePercent', changePercent)
          ..add('trend', trend))
        .toString();
  }
}

class MetricResponseBuilder
    implements Builder<MetricResponse, MetricResponseBuilder> {
  _$MetricResponse? _$v;

  num? _current;
  num? get current => _$this._current;
  set current(num? current) => _$this._current = current;

  num? _previous;
  num? get previous => _$this._previous;
  set previous(num? previous) => _$this._previous = previous;

  num? _changePercent;
  num? get changePercent => _$this._changePercent;
  set changePercent(num? changePercent) =>
      _$this._changePercent = changePercent;

  MetricResponseTrendEnum? _trend;
  MetricResponseTrendEnum? get trend => _$this._trend;
  set trend(MetricResponseTrendEnum? trend) => _$this._trend = trend;

  MetricResponseBuilder() {
    MetricResponse._defaults(this);
  }

  MetricResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _current = $v.current;
      _previous = $v.previous;
      _changePercent = $v.changePercent;
      _trend = $v.trend;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MetricResponse other) {
    _$v = other as _$MetricResponse;
  }

  @override
  void update(void Function(MetricResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MetricResponse build() => _build();

  _$MetricResponse _build() {
    final _$result =
        _$v ??
        _$MetricResponse._(
          current: current,
          previous: previous,
          changePercent: changePercent,
          trend: trend,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

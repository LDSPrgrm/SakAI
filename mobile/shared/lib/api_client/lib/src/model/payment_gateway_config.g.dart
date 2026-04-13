// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_gateway_config.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PaymentGatewayConfig extends PaymentGatewayConfig {
  @override
  final String? name;
  @override
  final LatLng? center;
  @override
  final double? radius;

  factory _$PaymentGatewayConfig(
          [void Function(PaymentGatewayConfigBuilder)? updates]) =>
      (PaymentGatewayConfigBuilder()..update(updates))._build();

  _$PaymentGatewayConfig._({this.name, this.center, this.radius}) : super._();
  @override
  PaymentGatewayConfig rebuild(
          void Function(PaymentGatewayConfigBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PaymentGatewayConfigBuilder toBuilder() =>
      PaymentGatewayConfigBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PaymentGatewayConfig &&
        name == other.name &&
        center == other.center &&
        radius == other.radius;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, center.hashCode);
    _$hash = $jc(_$hash, radius.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PaymentGatewayConfig')
          ..add('name', name)
          ..add('center', center)
          ..add('radius', radius))
        .toString();
  }
}

class PaymentGatewayConfigBuilder
    implements Builder<PaymentGatewayConfig, PaymentGatewayConfigBuilder> {
  _$PaymentGatewayConfig? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  LatLngBuilder? _center;
  LatLngBuilder get center => _$this._center ??= LatLngBuilder();
  set center(LatLngBuilder? center) => _$this._center = center;

  double? _radius;
  double? get radius => _$this._radius;
  set radius(double? radius) => _$this._radius = radius;

  PaymentGatewayConfigBuilder() {
    PaymentGatewayConfig._defaults(this);
  }

  PaymentGatewayConfigBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _center = $v.center?.toBuilder();
      _radius = $v.radius;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PaymentGatewayConfig other) {
    _$v = other as _$PaymentGatewayConfig;
  }

  @override
  void update(void Function(PaymentGatewayConfigBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PaymentGatewayConfig build() => _build();

  _$PaymentGatewayConfig _build() {
    _$PaymentGatewayConfig _$result;
    try {
      _$result = _$v ??
          _$PaymentGatewayConfig._(
            name: name,
            center: _center?.build(),
            radius: radius,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'center';
        _center?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PaymentGatewayConfig', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

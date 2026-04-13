// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sakai_api_client/src/model/lat_lng.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'payment_gateway_config.g.dart';

/// PaymentGatewayConfig
///
/// Properties:
/// * [name] 
/// * [center] 
/// * [radius] - Service radius in meters
@BuiltValue()
abstract class PaymentGatewayConfig implements Built<PaymentGatewayConfig, PaymentGatewayConfigBuilder> {
  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'center')
  LatLng? get center;

  /// Service radius in meters
  @BuiltValueField(wireName: r'radius')
  double? get radius;

  PaymentGatewayConfig._();

  factory PaymentGatewayConfig([void updates(PaymentGatewayConfigBuilder b)]) = _$PaymentGatewayConfig;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PaymentGatewayConfigBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PaymentGatewayConfig> get serializer => _$PaymentGatewayConfigSerializer();
}

class _$PaymentGatewayConfigSerializer implements PrimitiveSerializer<PaymentGatewayConfig> {
  @override
  final Iterable<Type> types = const [PaymentGatewayConfig, _$PaymentGatewayConfig];

  @override
  final String wireName = r'PaymentGatewayConfig';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PaymentGatewayConfig object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
    if (object.center != null) {
      yield r'center';
      yield serializers.serialize(
        object.center,
        specifiedType: const FullType(LatLng),
      );
    }
    if (object.radius != null) {
      yield r'radius';
      yield serializers.serialize(
        object.radius,
        specifiedType: const FullType(double),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PaymentGatewayConfig object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PaymentGatewayConfigBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'center':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(LatLng),
          ) as LatLng;
          result.center.replace(valueDes);
          break;
        case r'radius':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(double),
          ) as double;
          result.radius = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PaymentGatewayConfig deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PaymentGatewayConfigBuilder();
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


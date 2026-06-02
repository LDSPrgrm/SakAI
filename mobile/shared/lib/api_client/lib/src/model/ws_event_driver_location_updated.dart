// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sakai_api_client/src/model/lat_lng.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ws_event_driver_location_updated.g.dart';

/// **Event:** `driver.location_updated` **Direction:** server → passenger Pushed on every `PUT /driver/location` call during an active ride. Use to animate the driver pin on the passenger's map in real time.  Marked `x-high-frequency: true` — clients may use a hand-tuned fast-path deserializer (lat/lng/heading/ride_id only) instead of the full schema validator on the hot path. 
///
/// Properties:
/// * [rideId] 
/// * [location] 
/// * [heading] - Compass heading in degrees (0–360). Use to rotate driver icon.
@BuiltValue()
abstract class WsEventDriverLocationUpdated implements Built<WsEventDriverLocationUpdated, WsEventDriverLocationUpdatedBuilder> {
  @BuiltValueField(wireName: r'ride_id')
  String get rideId;

  @BuiltValueField(wireName: r'location')
  LatLng get location;

  /// Compass heading in degrees (0–360). Use to rotate driver icon.
  @BuiltValueField(wireName: r'heading')
  double? get heading;

  WsEventDriverLocationUpdated._();

  factory WsEventDriverLocationUpdated([void updates(WsEventDriverLocationUpdatedBuilder b)]) = _$WsEventDriverLocationUpdated;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WsEventDriverLocationUpdatedBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WsEventDriverLocationUpdated> get serializer => _$WsEventDriverLocationUpdatedSerializer();
}

class _$WsEventDriverLocationUpdatedSerializer implements PrimitiveSerializer<WsEventDriverLocationUpdated> {
  @override
  final Iterable<Type> types = const [WsEventDriverLocationUpdated, _$WsEventDriverLocationUpdated];

  @override
  final String wireName = r'WsEventDriverLocationUpdated';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    WsEventDriverLocationUpdated object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'ride_id';
    yield serializers.serialize(
      object.rideId,
      specifiedType: const FullType(String),
    );
    yield r'location';
    yield serializers.serialize(
      object.location,
      specifiedType: const FullType(LatLng),
    );
    if (object.heading != null) {
      yield r'heading';
      yield serializers.serialize(
        object.heading,
        specifiedType: const FullType.nullable(double),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    WsEventDriverLocationUpdated object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required WsEventDriverLocationUpdatedBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'ride_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.rideId = valueDes;
          break;
        case r'location':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(LatLng),
          ) as LatLng;
          result.location.replace(valueDes);
          break;
        case r'heading':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(double),
          ) as double?;
          if (valueDes == null) continue;
          result.heading = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  WsEventDriverLocationUpdated deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WsEventDriverLocationUpdatedBuilder();
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


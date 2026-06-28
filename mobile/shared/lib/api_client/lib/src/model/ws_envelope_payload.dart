// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sakai_api_client/src/model/fare_breakdown.dart';
import 'package:sakai_api_client/src/model/ws_event_no_drivers_available.dart';
import 'package:sakai_api_client/src/model/ws_event_ride_accepted.dart';
import 'package:sakai_api_client/src/model/ws_event_ride_offer_expired.dart';
import 'package:sakai_api_client/src/model/ws_event_conn_welcome.dart';
import 'package:sakai_api_client/src/model/driver_summary.dart';
import 'package:sakai_api_client/src/model/ws_event_incident_resolved.dart';
import 'package:sakai_api_client/src/model/ws_event_ride_sos_triggered.dart';
import 'package:sakai_api_client/src/model/ws_event_incident_assigned.dart';
import 'package:sakai_api_client/src/model/ws_event_ride_cancelled.dart';
import 'package:sakai_api_client/src/model/ws_event_ride_requested.dart';
import 'package:sakai_api_client/src/model/ws_event_ride_status_changed.dart';
import 'package:sakai_api_client/src/model/ws_event_ride_completed.dart';
import 'package:sakai_api_client/src/model/ride_status.dart';
import 'package:sakai_api_client/src/model/ws_event_ride_declined.dart';
import 'package:sakai_api_client/src/model/user_profile.dart';
import 'package:built_collection/built_collection.dart';
import 'package:sakai_api_client/src/model/ws_event_ride_state_sync.dart';
import 'package:sakai_api_client/src/model/lat_lng.dart';
import 'package:sakai_api_client/src/model/ws_event_driver_location_updated.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/one_of.dart';

part 'ws_envelope_payload.g.dart';

/// Event-specific payload — shape depends on `event`.
///
/// Properties:
/// * [rideId] 
/// * [passenger] 
/// * [origin] 
/// * [destination] 
/// * [originAddress] 
/// * [destinationAddress] 
/// * [notes] 
/// * [expiresAt] - Deadline to accept/decline. Driver UI should display a countdown.
/// * [driver] 
/// * [message] 
/// * [status] 
/// * [updatedAt] 
/// * [fare] - Total fare charged to the passenger in PHP.
/// * [fareBreakdown] 
/// * [paymentMethod] 
/// * [tipAmount] - Driver tip in PHP, when one was already received.
/// * [completedAt] 
/// * [cancelledBy] 
/// * [reason] - Free-text reason the trigger user supplied.
/// * [incidentId] 
/// * [triggeredBy] 
/// * [hasActiveRide] 
/// * [driverId] 
/// * [passengerId] 
/// * [assigneeId] 
/// * [assigneeName] - Display name of the assignee. Optional — publishers populate it only when the value can be resolved cheaply. 
/// * [assignedAt] 
/// * [resolutionNotes] - Operator notes. May be redacted before send.
/// * [resolvedAt] 
/// * [location] 
/// * [heading] - Compass heading in degrees (0–360). Use to rotate driver icon.
/// * [protocol] - Negotiated WebSocket subprotocol. Empty string for v1 clients, `\"sakai.v2\"` for v2. 
/// * [v] - Envelope protocol version supported by the server.
@BuiltValue()
abstract class WsEnvelopePayload implements Built<WsEnvelopePayload, WsEnvelopePayloadBuilder> {
  /// One Of [WsEventConnWelcome], [WsEventDriverLocationUpdated], [WsEventIncidentAssigned], [WsEventIncidentResolved], [WsEventNoDriversAvailable], [WsEventRideAccepted], [WsEventRideCancelled], [WsEventRideCompleted], [WsEventRideDeclined], [WsEventRideOfferExpired], [WsEventRideRequested], [WsEventRideSOSTriggered], [WsEventRideStateSync], [WsEventRideStatusChanged]
  OneOf get oneOf;

  WsEnvelopePayload._();

  factory WsEnvelopePayload([void updates(WsEnvelopePayloadBuilder b)]) = _$WsEnvelopePayload;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WsEnvelopePayloadBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WsEnvelopePayload> get serializer => _$WsEnvelopePayloadSerializer();
}

class _$WsEnvelopePayloadSerializer implements PrimitiveSerializer<WsEnvelopePayload> {
  @override
  final Iterable<Type> types = const [WsEnvelopePayload, _$WsEnvelopePayload];

  @override
  final String wireName = r'WsEnvelopePayload';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    WsEnvelopePayload object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
  }

  @override
  Object serialize(
    Serializers serializers,
    WsEnvelopePayload object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final oneOf = object.oneOf;
    return serializers.serialize(oneOf.value, specifiedType: FullType(oneOf.valueType))!;
  }

  @override
  WsEnvelopePayload deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WsEnvelopePayloadBuilder();
    Object? oneOfDataSrc;
    final targetType = const FullType(OneOf, [FullType(WsEventRideRequested), FullType(WsEventRideAccepted), FullType(WsEventRideDeclined), FullType(WsEventRideOfferExpired), FullType(WsEventRideStatusChanged), FullType(WsEventRideCompleted), FullType(WsEventRideCancelled), FullType(WsEventRideSOSTriggered), FullType(WsEventNoDriversAvailable), FullType(WsEventRideStateSync), FullType(WsEventIncidentAssigned), FullType(WsEventIncidentResolved), FullType(WsEventDriverLocationUpdated), FullType(WsEventConnWelcome), ]);
    oneOfDataSrc = serialized;
    result.oneOf = serializers.deserialize(oneOfDataSrc, specifiedType: targetType) as OneOf;
    return result.build();
  }
}

class WsEnvelopePayloadPaymentMethodEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'cash')
  static const WsEnvelopePayloadPaymentMethodEnum cash = _$wsEnvelopePayloadPaymentMethodEnum_cash;
  @BuiltValueEnumConst(wireName: r'gcash')
  static const WsEnvelopePayloadPaymentMethodEnum gcash = _$wsEnvelopePayloadPaymentMethodEnum_gcash;
  @BuiltValueEnumConst(wireName: r'paymaya')
  static const WsEnvelopePayloadPaymentMethodEnum paymaya = _$wsEnvelopePayloadPaymentMethodEnum_paymaya;
  @BuiltValueEnumConst(wireName: r'card')
  static const WsEnvelopePayloadPaymentMethodEnum card = _$wsEnvelopePayloadPaymentMethodEnum_card;

  static Serializer<WsEnvelopePayloadPaymentMethodEnum> get serializer => _$wsEnvelopePayloadPaymentMethodEnumSerializer;

  const WsEnvelopePayloadPaymentMethodEnum._(String name): super(name);

  static BuiltSet<WsEnvelopePayloadPaymentMethodEnum> get values => _$wsEnvelopePayloadPaymentMethodEnumValues;
  static WsEnvelopePayloadPaymentMethodEnum valueOf(String name) => _$wsEnvelopePayloadPaymentMethodEnumValueOf(name);
}

class WsEnvelopePayloadCancelledByEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'passenger')
  static const WsEnvelopePayloadCancelledByEnum passenger = _$wsEnvelopePayloadCancelledByEnum_passenger;
  @BuiltValueEnumConst(wireName: r'driver')
  static const WsEnvelopePayloadCancelledByEnum driver = _$wsEnvelopePayloadCancelledByEnum_driver;

  static Serializer<WsEnvelopePayloadCancelledByEnum> get serializer => _$wsEnvelopePayloadCancelledByEnumSerializer;

  const WsEnvelopePayloadCancelledByEnum._(String name): super(name);

  static BuiltSet<WsEnvelopePayloadCancelledByEnum> get values => _$wsEnvelopePayloadCancelledByEnumValues;
  static WsEnvelopePayloadCancelledByEnum valueOf(String name) => _$wsEnvelopePayloadCancelledByEnumValueOf(name);
}

class WsEnvelopePayloadTriggeredByEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'rider')
  static const WsEnvelopePayloadTriggeredByEnum rider = _$wsEnvelopePayloadTriggeredByEnum_rider;
  @BuiltValueEnumConst(wireName: r'driver')
  static const WsEnvelopePayloadTriggeredByEnum driver = _$wsEnvelopePayloadTriggeredByEnum_driver;

  static Serializer<WsEnvelopePayloadTriggeredByEnum> get serializer => _$wsEnvelopePayloadTriggeredByEnumSerializer;

  const WsEnvelopePayloadTriggeredByEnum._(String name): super(name);

  static BuiltSet<WsEnvelopePayloadTriggeredByEnum> get values => _$wsEnvelopePayloadTriggeredByEnumValues;
  static WsEnvelopePayloadTriggeredByEnum valueOf(String name) => _$wsEnvelopePayloadTriggeredByEnumValueOf(name);
}


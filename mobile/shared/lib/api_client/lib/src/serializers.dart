//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_import

import 'package:one_of_serializer/any_of_serializer.dart';
import 'package:one_of_serializer/one_of_serializer.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:built_value/iso_8601_date_time_serializer.dart';
import 'package:sakai_api_client/src/date_serializer.dart';
import 'package:sakai_api_client/src/model/date.dart';

import 'package:sakai_api_client/src/model/auth_response.dart';
import 'package:sakai_api_client/src/model/cancel_request.dart';
import 'package:sakai_api_client/src/model/driver_status_request.dart';
import 'package:sakai_api_client/src/model/driver_status_response.dart';
import 'package:sakai_api_client/src/model/driver_summary.dart';
import 'package:sakai_api_client/src/model/error_code.dart';
import 'package:sakai_api_client/src/model/error_response.dart';
import 'package:sakai_api_client/src/model/health_response.dart';
import 'package:sakai_api_client/src/model/health_response_dependencies.dart';
import 'package:sakai_api_client/src/model/lat_lng.dart';
import 'package:sakai_api_client/src/model/location_update_request.dart';
import 'package:sakai_api_client/src/model/login_request.dart';
import 'package:sakai_api_client/src/model/logout_request.dart';
import 'package:sakai_api_client/src/model/refresh_request.dart';
import 'package:sakai_api_client/src/model/register_request.dart';
import 'package:sakai_api_client/src/model/ride_request_body.dart';
import 'package:sakai_api_client/src/model/ride_response.dart';
import 'package:sakai_api_client/src/model/ride_status.dart';
import 'package:sakai_api_client/src/model/user_profile.dart';
import 'package:sakai_api_client/src/model/vehicle_info.dart';
import 'package:sakai_api_client/src/model/ws_envelope.dart';
import 'package:sakai_api_client/src/model/ws_event_driver_location_updated.dart';
import 'package:sakai_api_client/src/model/ws_event_no_drivers_available.dart';
import 'package:sakai_api_client/src/model/ws_event_ride_accepted.dart';
import 'package:sakai_api_client/src/model/ws_event_ride_cancelled.dart';
import 'package:sakai_api_client/src/model/ws_event_ride_declined.dart';
import 'package:sakai_api_client/src/model/ws_event_ride_offer_expired.dart';
import 'package:sakai_api_client/src/model/ws_event_ride_requested.dart';
import 'package:sakai_api_client/src/model/ws_event_ride_status_changed.dart';

part 'serializers.g.dart';

@SerializersFor([
  AuthResponse,
  CancelRequest,
  DriverStatusRequest,
  DriverStatusResponse,
  DriverSummary,
  ErrorCode,
  ErrorResponse,
  HealthResponse,
  HealthResponseDependencies,
  LatLng,
  LocationUpdateRequest,
  LoginRequest,
  LogoutRequest,
  RefreshRequest,
  RegisterRequest,
  RideRequestBody,
  RideResponse,
  RideStatus,
  UserProfile,
  VehicleInfo,
  WsEnvelope,
  WsEventDriverLocationUpdated,
  WsEventNoDriversAvailable,
  WsEventRideAccepted,
  WsEventRideCancelled,
  WsEventRideDeclined,
  WsEventRideOfferExpired,
  WsEventRideRequested,
  WsEventRideStatusChanged,
])
Serializers serializers = (_$serializers.toBuilder()
      ..add(const OneOfSerializer())
      ..add(const AnyOfSerializer())
      ..add(const DateSerializer())
      ..add(Iso8601DateTimeSerializer())
    ).build();

Serializers standardSerializers =
    (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();

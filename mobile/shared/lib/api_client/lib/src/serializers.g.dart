// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'serializers.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializers _$serializers =
    (Serializers().toBuilder()
          ..add(AdminFaresResponse.serializer)
          ..add(AuditLog.serializer)
          ..add(AuditLogResponse.serializer)
          ..add(AuthResponse.serializer)
          ..add(BlackoutHour.serializer)
          ..add(CancelRequest.serializer)
          ..add(CreateAdminRequest.serializer)
          ..add(CreateAdminRequestRoleEnum.serializer)
          ..add(DashboardResponse.serializer)
          ..add(DriverStatusRequest.serializer)
          ..add(DriverStatusRequestStatusEnum.serializer)
          ..add(DriverStatusResponse.serializer)
          ..add(DriverStatusResponseStatusEnum.serializer)
          ..add(DriverSummary.serializer)
          ..add(ErrorCode.serializer)
          ..add(ErrorResponse.serializer)
          ..add(FareConfig.serializer)
          ..add(FareSimulationRequest.serializer)
          ..add(FareSimulationResponse.serializer)
          ..add(GeoJSONFeature.serializer)
          ..add(GeoJSONFeatureCollection.serializer)
          ..add(GeoJSONFeatureCollectionTypeEnum.serializer)
          ..add(GeoJSONFeatureTypeEnum.serializer)
          ..add(GeoJSONGeometry.serializer)
          ..add(GeoJSONMultiPolygon.serializer)
          ..add(GeoJSONMultiPolygonTypeEnum.serializer)
          ..add(GeoJSONPoint.serializer)
          ..add(GeoJSONPointTypeEnum.serializer)
          ..add(GeoJSONPolygon.serializer)
          ..add(GeoJSONPolygonTypeEnum.serializer)
          ..add(HealthResponse.serializer)
          ..add(HealthResponseDependencies.serializer)
          ..add(HealthResponseDependenciesDatabaseEnum.serializer)
          ..add(HealthResponseDependenciesRedisEnum.serializer)
          ..add(HealthResponseStatusEnum.serializer)
          ..add(Incident.serializer)
          ..add(IncidentResolveRequest.serializer)
          ..add(IncidentStatusEnum.serializer)
          ..add(LatLng.serializer)
          ..add(LocationUpdateRequest.serializer)
          ..add(LoginRequest.serializer)
          ..add(LogoutRequest.serializer)
          ..add(RefreshRequest.serializer)
          ..add(RegisterRequest.serializer)
          ..add(RegisterRequestRoleEnum.serializer)
          ..add(RideRequestBody.serializer)
          ..add(RideResponse.serializer)
          ..add(RideResponseCancelledByEnum.serializer)
          ..add(RideStatus.serializer)
          ..add(SurgeConfig.serializer)
          ..add(UpdateAdminStatusRequest.serializer)
          ..add(UpdateAdminStatusRequestRoleEnum.serializer)
          ..add(UserProfile.serializer)
          ..add(UserProfileRoleEnum.serializer)
          ..add(VehicleInfo.serializer)
          ..add(WsEnvelope.serializer)
          ..add(WsEventDriverLocationUpdated.serializer)
          ..add(WsEventNoDriversAvailable.serializer)
          ..add(WsEventRideAccepted.serializer)
          ..add(WsEventRideCancelled.serializer)
          ..add(WsEventRideCancelledCancelledByEnum.serializer)
          ..add(WsEventRideDeclined.serializer)
          ..add(WsEventRideOfferExpired.serializer)
          ..add(WsEventRideRequested.serializer)
          ..add(WsEventRideStatusChanged.serializer)
          ..addBuilderFactory(
            const FullType(BuiltList, const [const FullType(AuditLog)]),
            () => ListBuilder<AuditLog>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [const FullType(BlackoutHour)]),
            () => ListBuilder<BlackoutHour>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(BuiltList, const [
                const FullType(BuiltList, const [
                  const FullType(BuiltList, const [const FullType(num)]),
                ]),
              ]),
            ]),
            () => ListBuilder<BuiltList<BuiltList<BuiltList<num>>>>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(BuiltList, const [
                const FullType(BuiltList, const [const FullType(num)]),
              ]),
            ]),
            () => ListBuilder<BuiltList<BuiltList<num>>>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [const FullType(FareConfig)]),
            () => ListBuilder<FareConfig>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [const FullType(GeoJSONFeature)]),
            () => ListBuilder<GeoJSONFeature>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [const FullType(num)]),
            () => ListBuilder<num>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltMap, const [
              const FullType(String),
              const FullType.nullable(JsonObject),
            ]),
            () => MapBuilder<String, JsonObject?>(),
          ))
        .build();

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

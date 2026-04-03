// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'serializers.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializers _$serializers =
    (Serializers().toBuilder()
          ..add(AdminExportReport200Response.serializer)
          ..add(AdminFaresResponse.serializer)
          ..add(AdminUpdateFeatureFlagRequest.serializer)
          ..add(AdminUpdateKycStatusRequest.serializer)
          ..add(AdminUpdateKycStatusRequestStatusEnum.serializer)
          ..add(AdminUpdateNotificationTemplateRequest.serializer)
          ..add(AuditLog.serializer)
          ..add(AuditLogResponse.serializer)
          ..add(AuthResponse.serializer)
          ..add(BlackoutHour.serializer)
          ..add(CancelRequest.serializer)
          ..add(CommissionConfig.serializer)
          ..add(CommissionConfigRates.serializer)
          ..add(CreateAdminRequest.serializer)
          ..add(CreateAdminRequestRoleEnum.serializer)
          ..add(DashboardResponse.serializer)
          ..add(DriverPayout.serializer)
          ..add(DriverPayoutStatusEnum.serializer)
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
          ..add(FeatureFlag.serializer)
          ..add(GeoJSONFeatureCollection.serializer)
          ..add(GeoJSONFeatureCollectionFeaturesInner.serializer)
          ..add(GeoJSONFeatureCollectionFeaturesInnerGeometry.serializer)
          ..add(
            GeoJSONFeatureCollectionFeaturesInnerGeometryTypeEnum.serializer,
          )
          ..add(GeoJSONFeatureCollectionFeaturesInnerTypeEnum.serializer)
          ..add(GeoJSONFeatureCollectionTypeEnum.serializer)
          ..add(HealthResponse.serializer)
          ..add(HealthResponseDependencies.serializer)
          ..add(HealthResponseDependenciesDatabaseEnum.serializer)
          ..add(HealthResponseDependenciesRedisEnum.serializer)
          ..add(HealthResponseStatusEnum.serializer)
          ..add(Incident.serializer)
          ..add(IncidentResolveRequest.serializer)
          ..add(Integration.serializer)
          ..add(IntegrationStatusEnum.serializer)
          ..add(KycEntry.serializer)
          ..add(KycEntryStatusEnum.serializer)
          ..add(LatLng.serializer)
          ..add(LocationUpdateRequest.serializer)
          ..add(LoginRequest.serializer)
          ..add(LogoutRequest.serializer)
          ..add(NotificationTemplate.serializer)
          ..add(NotificationTemplateChannelEnum.serializer)
          ..add(PaymentSummary.serializer)
          ..add(RefreshRequest.serializer)
          ..add(RegisterRequest.serializer)
          ..add(RegisterRequestRoleEnum.serializer)
          ..add(ReportDefinition.serializer)
          ..add(RideRequestBody.serializer)
          ..add(RideResponse.serializer)
          ..add(RideResponseCancelledByEnum.serializer)
          ..add(RideStatus.serializer)
          ..add(SurgeConfig.serializer)
          ..add(SystemService.serializer)
          ..add(SystemServiceStatusEnum.serializer)
          ..add(Transaction.serializer)
          ..add(TransactionPaymentMethodEnum.serializer)
          ..add(TransactionStatusEnum.serializer)
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
            const FullType(BuiltList, const [
              const FullType(GeoJSONFeatureCollectionFeaturesInner),
            ]),
            () => ListBuilder<GeoJSONFeatureCollectionFeaturesInner>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [const FullType(String)]),
            () => ListBuilder<String>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltMap, const [
              const FullType(String),
              const FullType(String),
            ]),
            () => MapBuilder<String, String>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltMap, const [
              const FullType(String),
              const FullType.nullable(JsonObject),
            ]),
            () => MapBuilder<String, JsonObject?>(),
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

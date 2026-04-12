// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'serializers.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializers _$serializers =
    (Serializers().toBuilder()
          ..add($RideResponse.serializer)
          ..add($UserProfile.serializer)
          ..add(AddPaymentMethodRequest.serializer)
          ..add(AddRideTipRequest.serializer)
          ..add(AdminBatchApprovePayouts200Response.serializer)
          ..add(AdminBatchKyc200Response.serializer)
          ..add(AdminExportReport200Response.serializer)
          ..add(AdminFaresResponse.serializer)
          ..add(AdminRideItem.serializer)
          ..add(AdminRideListResponse.serializer)
          ..add(AdminUpdateFeatureFlagRequest.serializer)
          ..add(AdminUpdateKycStatusRequest.serializer)
          ..add(AdminUpdateKycStatusRequestStatusEnum.serializer)
          ..add(AdminUpdateNotificationTemplateRequest.serializer)
          ..add(AdminUser.serializer)
          ..add(AdminUserListResponse.serializer)
          ..add(AdminUserStatusEnum.serializer)
          ..add(AuditLog.serializer)
          ..add(AuditLogResponse.serializer)
          ..add(AuthResponse.serializer)
          ..add(BatchApproveRequest.serializer)
          ..add(BlackoutHour.serializer)
          ..add(CancelRequest.serializer)
          ..add(CardDetails.serializer)
          ..add(ChangePasswordRequest.serializer)
          ..add(CommissionConfig.serializer)
          ..add(CommissionConfigRates.serializer)
          ..add(ComplianceData.serializer)
          ..add(ComplianceDataAccreditationStatusEnum.serializer)
          ..add(CreateAdminRequest.serializer)
          ..add(CreateAdminRequestRoleEnum.serializer)
          ..add(CreateRoleRequest.serializer)
          ..add(DashboardResponse.serializer)
          ..add(DocumentType.serializer)
          ..add(DriverDocumentResponse.serializer)
          ..add(DriverDocumentsListResponse.serializer)
          ..add(DriverPayout.serializer)
          ..add(DriverPayoutStatusEnum.serializer)
          ..add(DriverStatusRequest.serializer)
          ..add(DriverStatusRequestStatusEnum.serializer)
          ..add(DriverStatusResponse.serializer)
          ..add(DriverStatusResponseStatusEnum.serializer)
          ..add(DriverSummary.serializer)
          ..add(EWalletDetails.serializer)
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
          ..add(IncidentSeverityEnum.serializer)
          ..add(IncidentStatusEnum.serializer)
          ..add(IncidentTriggeredByEnum.serializer)
          ..add(IncidentTypeEnum.serializer)
          ..add(Integration.serializer)
          ..add(IntegrationStatusEnum.serializer)
          ..add(IntegrationTestResult.serializer)
          ..add(IntegrationTestResultStatusEnum.serializer)
          ..add(KycBatchRequest.serializer)
          ..add(KycBatchRequestStatusEnum.serializer)
          ..add(KycEntry.serializer)
          ..add(KycEntryStatusEnum.serializer)
          ..add(LatLng.serializer)
          ..add(LocationUpdateRequest.serializer)
          ..add(LoginRequest.serializer)
          ..add(LogoutRequest.serializer)
          ..add(MetricResponse.serializer)
          ..add(MetricResponseTrendEnum.serializer)
          ..add(NearbyDriver.serializer)
          ..add(NearbyDriverProviderEnum.serializer)
          ..add(NearbyDriversResponse.serializer)
          ..add(NotificationTemplate.serializer)
          ..add(NotificationTemplateChannelEnum.serializer)
          ..add(PaginationMeta.serializer)
          ..add(PaymentFailureResponse.serializer)
          ..add(PaymentFailureResponseCodeEnum.serializer)
          ..add(PaymentGatewayConfig.serializer)
          ..add(PaymentMethod.serializer)
          ..add(PaymentMethodDetails.serializer)
          ..add(PaymentMethodListResponse.serializer)
          ..add(PaymentMethodType.serializer)
          ..add(PaymentProcessRequest.serializer)
          ..add(PaymentResponse.serializer)
          ..add(PaymentStatus.serializer)
          ..add(PaymentSummary.serializer)
          ..add(RatingResponse.serializer)
          ..add(ReceiptResponse.serializer)
          ..add(RefreshRequest.serializer)
          ..add(RegisterRequest.serializer)
          ..add(RegisterRequestRoleEnum.serializer)
          ..add(ReportDefinition.serializer)
          ..add(RideRequestBody.serializer)
          ..add(RideResponseCancelledByEnum.serializer)
          ..add(RideResponsePaymentMethodEnum.serializer)
          ..add(RideStatus.serializer)
          ..add(Role.serializer)
          ..add(RoleNameEnum.serializer)
          ..add(RolePermission.serializer)
          ..add(RolePermissionPermissionKeyEnum.serializer)
          ..add(ServiceArea.serializer)
          ..add(ServiceAreaResponse.serializer)
          ..add(SubmitRatingRequest.serializer)
          ..add(SurgeConfig.serializer)
          ..add(SystemService.serializer)
          ..add(SystemServiceStatusEnum.serializer)
          ..add(TipResponse.serializer)
          ..add(Transaction.serializer)
          ..add(TransactionPaymentMethodEnum.serializer)
          ..add(TransactionStatusEnum.serializer)
          ..add(UpdateAdminStatusRequest.serializer)
          ..add(UpdateAdminStatusRequestRoleEnum.serializer)
          ..add(UpdatePaymentConfigRequest.serializer)
          ..add(UpdateRoleRequest.serializer)
          ..add(UploadStatus.serializer)
          ..add(UserProfileRoleEnum.serializer)
          ..add(UserRatingResponse.serializer)
          ..add(UserRideItem.serializer)
          ..add(UserRideItemPaymentMethodEnum.serializer)
          ..add(UserRideListResponse.serializer)
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
            const FullType(BuiltList, const [const FullType(AdminRideItem)]),
            () => ListBuilder<AdminRideItem>(),
          )
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
            const FullType(BuiltList, const [
              const FullType(DriverDocumentResponse),
            ]),
            () => ListBuilder<DriverDocumentResponse>(),
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
            const FullType(BuiltList, const [const FullType(NearbyDriver)]),
            () => ListBuilder<NearbyDriver>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(PaymentMethodDetails),
            ]),
            () => ListBuilder<PaymentMethodDetails>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [const FullType(RolePermission)]),
            () => ListBuilder<RolePermission>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [const FullType(RolePermission)]),
            () => ListBuilder<RolePermission>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [const FullType(RolePermission)]),
            () => ListBuilder<RolePermission>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [const FullType(RolePermission)]),
            () => ListBuilder<RolePermission>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [const FullType(ServiceArea)]),
            () => ListBuilder<ServiceArea>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [const FullType(String)]),
            () => ListBuilder<String>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [const FullType(String)]),
            () => ListBuilder<String>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [const FullType(String)]),
            () => ListBuilder<String>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [const FullType(UserProfile)]),
            () => ListBuilder<UserProfile>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [const FullType(UserRideItem)]),
            () => ListBuilder<UserRideItem>(),
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
              const FullType(String),
            ]),
            () => MapBuilder<String, String>(),
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

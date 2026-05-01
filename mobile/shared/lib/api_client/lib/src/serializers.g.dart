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
          ..add(AdminAssignIncidentRequest.serializer)
          ..add(AdminBatchApprovePayouts200Response.serializer)
          ..add(AdminBatchKyc200Response.serializer)
          ..add(AdminExportReport200Response.serializer)
          ..add(AdminFaresResponse.serializer)
          ..add(AdminListDriverRides200Response.serializer)
          ..add(AdminRideItem.serializer)
          ..add(AdminRideListResponse.serializer)
          ..add(AdminUpdateFeatureFlagRequest.serializer)
          ..add(AdminUpdateKycStatusRequest.serializer)
          ..add(AdminUpdateKycStatusRequestStatusEnum.serializer)
          ..add(AdminUpdateNotificationTemplateRequest.serializer)
          ..add(AdminUser.serializer)
          ..add(AdminUserListResponse.serializer)
          ..add(AdminUserStatusEnum.serializer)
          ..add(AlertEvent.serializer)
          ..add(AlertRule.serializer)
          ..add(AlertRuleInput.serializer)
          ..add(AlertRuleInputTypeEnum.serializer)
          ..add(AlertRuleTypeEnum.serializer)
          ..add(AuditLog.serializer)
          ..add(AuditLogResponse.serializer)
          ..add(AuthResponse.serializer)
          ..add(BatchApproveRequest.serializer)
          ..add(BlackoutHour.serializer)
          ..add(CancelRequest.serializer)
          ..add(CancelRequestReasonCodeEnum.serializer)
          ..add(CardDetails.serializer)
          ..add(ChangePasswordRequest.serializer)
          ..add(CommissionConfig.serializer)
          ..add(CommissionConfigRates.serializer)
          ..add(ComplianceData.serializer)
          ..add(ComplianceDataAccreditationStatusEnum.serializer)
          ..add(CreateAdminRequest.serializer)
          ..add(CreateAdminRequestRoleEnum.serializer)
          ..add(CreateAuditEntryRequest.serializer)
          ..add(CreateAuditEntryRequestActionEnum.serializer)
          ..add(CreateRoleRequest.serializer)
          ..add(DashboardResponse.serializer)
          ..add(DocumentType.serializer)
          ..add(DriverDocumentResponse.serializer)
          ..add(DriverDocumentsListResponse.serializer)
          ..add(DriverGetEarnings200Response.serializer)
          ..add(DriverHeatmap.serializer)
          ..add(DriverPayout.serializer)
          ..add(DriverPayoutStatusEnum.serializer)
          ..add(DriverStatusRequest.serializer)
          ..add(DriverStatusRequestStatusEnum.serializer)
          ..add(DriverStatusResponse.serializer)
          ..add(DriverStatusResponseStatusEnum.serializer)
          ..add(DriverSummary.serializer)
          ..add(EWalletDetails.serializer)
          ..add(EarningsItem.serializer)
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
          ..add(GetNearbyDrivers200Response.serializer)
          ..add(HealthResponse.serializer)
          ..add(HealthResponseDependencies.serializer)
          ..add(HealthResponseDependenciesDatabaseEnum.serializer)
          ..add(HealthResponseDependenciesRedisEnum.serializer)
          ..add(HealthResponseStatusEnum.serializer)
          ..add(HeatmapBounds.serializer)
          ..add(HeatmapPosition.serializer)
          ..add(HeatmapPositionVehicleTypeEnum.serializer)
          ..add(Incident.serializer)
          ..add(IncidentDetail.serializer)
          ..add(IncidentLocationPoint.serializer)
          ..add(IncidentResolveRequest.serializer)
          ..add(IncidentSeverityEnum.serializer)
          ..add(IncidentStatusEnum.serializer)
          ..add(IncidentStatusEvent.serializer)
          ..add(IncidentTriggeredByEnum.serializer)
          ..add(IncidentTypeEnum.serializer)
          ..add(InfraMetrics.serializer)
          ..add(Integration.serializer)
          ..add(IntegrationStatusEnum.serializer)
          ..add(IntegrationTestResult.serializer)
          ..add(IntegrationTestResultStatusEnum.serializer)
          ..add(KycBatchRequest.serializer)
          ..add(KycBatchRequestStatusEnum.serializer)
          ..add(KycDocument.serializer)
          ..add(KycEntry.serializer)
          ..add(KycEntryStatusEnum.serializer)
          ..add(LGUPartnership.serializer)
          ..add(LGUPartnershipInput.serializer)
          ..add(LGUPartnershipInputStatusEnum.serializer)
          ..add(LGUPartnershipStatusEnum.serializer)
          ..add(LatLng.serializer)
          ..add(LocationUpdateRequest.serializer)
          ..add(LoginRequest.serializer)
          ..add(LogoutRequest.serializer)
          ..add(MetricResponse.serializer)
          ..add(MetricResponseTrendEnum.serializer)
          ..add(NearbyDriver.serializer)
          ..add(NearbyDriverVehicleTypeEnum.serializer)
          ..add(NearbyDriversResponse.serializer)
          ..add(NotificationTemplate.serializer)
          ..add(NotificationTemplateChannelEnum.serializer)
          ..add(PaginationMeta.serializer)
          ..add(PaymentFailureResponse.serializer)
          ..add(PaymentFailureResponseCodeEnum.serializer)
          ..add(PaymentGatewayConfig.serializer)
          ..add(PaymentGatewayConfigProviderEnum.serializer)
          ..add(PaymentMethod.serializer)
          ..add(PaymentMethodDetails.serializer)
          ..add(PaymentMethodListResponse.serializer)
          ..add(PaymentMethodType.serializer)
          ..add(PaymentProcessRequest.serializer)
          ..add(PaymentResponse.serializer)
          ..add(PaymentStatus.serializer)
          ..add(PaymentSummary.serializer)
          ..add(Promotion.serializer)
          ..add(PromotionDiscountTypeEnum.serializer)
          ..add(PromotionValidateRequest.serializer)
          ..add(RatingResponse.serializer)
          ..add(ReceiptResponse.serializer)
          ..add(RefreshRequest.serializer)
          ..add(RegisterRequest.serializer)
          ..add(RegisterRequestRoleEnum.serializer)
          ..add(ReportDefinition.serializer)
          ..add(ResetPasswordRequest.serializer)
          ..add(RideArriveRequest.serializer)
          ..add(RideCompleteRequest.serializer)
          ..add(RideEventPayload.serializer)
          ..add(RideEventPayloadStatusEnum.serializer)
          ..add(RideRequestBody.serializer)
          ..add(RideRequestBodyPaymentMethodEnum.serializer)
          ..add(RideRequestBodyRideTypeEnum.serializer)
          ..add(RideResponseCancelledByEnum.serializer)
          ..add(RideResponsePaymentMethodEnum.serializer)
          ..add(RideResponseRideTypeEnum.serializer)
          ..add(RideStatus.serializer)
          ..add(Role.serializer)
          ..add(RolePermission.serializer)
          ..add(RolePermissionPermissionKeyEnum.serializer)
          ..add(SavedPlace.serializer)
          ..add(SavedPlaceCreateRequest.serializer)
          ..add(SavedPlaceCreateRequestTypeEnum.serializer)
          ..add(SavedPlaceTypeEnum.serializer)
          ..add(ServiceArea.serializer)
          ..add(ServiceAreaInput.serializer)
          ..add(ServiceAreaResponse.serializer)
          ..add(SubmitRatingRequest.serializer)
          ..add(SurgeConfig.serializer)
          ..add(SurgeZone.serializer)
          ..add(SystemService.serializer)
          ..add(SystemServiceStatusEnum.serializer)
          ..add(TipResponse.serializer)
          ..add(Transaction.serializer)
          ..add(TransactionPaymentMethodEnum.serializer)
          ..add(TransactionStatusEnum.serializer)
          ..add(TriggerSOSRequest.serializer)
          ..add(UpdateAdminStatusRequest.serializer)
          ..add(UpdatePaymentConfigRequest.serializer)
          ..add(UpdateRoleRequest.serializer)
          ..add(UploadStatus.serializer)
          ..add(UserProfileRoleEnum.serializer)
          ..add(UserRatingResponse.serializer)
          ..add(UserRideItem.serializer)
          ..add(UserRideItemPaymentMethodEnum.serializer)
          ..add(UserRideListResponse.serializer)
          ..add(VehicleInfo.serializer)
          ..add(VehicleInput.serializer)
          ..add(VehicleInputVehicleTypeEnum.serializer)
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
            const FullType(BuiltList, const [
              const FullType(BuiltList, const [
                const FullType(BuiltList, const [const FullType(num)]),
              ]),
            ]),
            () => ListBuilder<BuiltList<BuiltList<num>>>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(BuiltList, const [const FullType(num)]),
            ]),
            () => ListBuilder<BuiltList<num>>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(DriverDocumentResponse),
            ]),
            () => ListBuilder<DriverDocumentResponse>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [const FullType(EarningsItem)]),
            () => ListBuilder<EarningsItem>(),
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
            const FullType(BuiltList, const [const FullType(HeatmapPosition)]),
            () => ListBuilder<HeatmapPosition>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(IncidentStatusEvent),
            ]),
            () => ListBuilder<IncidentStatusEvent>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(IncidentLocationPoint),
            ]),
            () => ListBuilder<IncidentLocationPoint>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [const FullType(KycDocument)]),
            () => ListBuilder<KycDocument>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [const FullType(NearbyDriver)]),
            () => ListBuilder<NearbyDriver>(),
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
            const FullType(BuiltList, const [const FullType(RideResponse)]),
            () => ListBuilder<RideResponse>(),
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
            const FullType(BuiltList, const [const FullType(SurgeZone)]),
            () => ListBuilder<SurgeZone>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [const FullType(BlackoutHour)]),
            () => ListBuilder<BlackoutHour>(),
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

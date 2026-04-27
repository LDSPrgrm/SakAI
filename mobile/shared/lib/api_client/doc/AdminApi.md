# sakai_api_client.api.AdminApi

## Load the API package
```dart
import 'package:sakai_api_client/api.dart';
```

All URIs are relative to *http://localhost:8080/api*

Method | HTTP request | Description
------------- | ------------- | -------------
[**adminApprovePayout**](AdminApi.md#adminapprovepayout) | **PUT** /admin/payments/payouts/{id}/approve | Approve a driver payout
[**adminAssignIncident**](AdminApi.md#adminassignincident) | **PUT** /admin/incidents/{id}/assign | Reassign an incident
[**adminAuditExport**](AdminApi.md#adminauditexport) | **GET** /admin/audit/export | Export audit log as CSV
[**adminBatchApprovePayouts**](AdminApi.md#adminbatchapprovepayouts) | **POST** /admin/payments/payouts/approve | Batch approve driver payouts
[**adminBatchKyc**](AdminApi.md#adminbatchkyc) | **POST** /admin/safety/kyc/batch | Batch approve or reject KYC submissions
[**adminChangePassword**](AdminApi.md#adminchangepassword) | **PUT** /admin/auth/password | Change own password
[**adminCreateAlertRule**](AdminApi.md#admincreatealertrule) | **POST** /admin/alerts/rules | Create an alert rule
[**adminCreateAuditEntry**](AdminApi.md#admincreateauditentry) | **POST** /admin/audit | Write an audit log entry
[**adminCreateLGUPartnership**](AdminApi.md#admincreatelgupartnership) | **POST** /admin/lgu-partnerships | Create an LGU partnership
[**adminCreateRole**](AdminApi.md#admincreaterole) | **POST** /admin/roles | Create a custom role
[**adminCreateServiceArea**](AdminApi.md#admincreateservicearea) | **POST** /admin/service-areas | Create a service area
[**adminCreateUser**](AdminApi.md#admincreateuser) | **POST** /admin/users | Create a new administrator
[**adminDeactivateUser**](AdminApi.md#admindeactivateuser) | **DELETE** /admin/users/{id} | Deactivate an administrator
[**adminDeleteAlertRule**](AdminApi.md#admindeletealertrule) | **DELETE** /admin/alerts/rules/{id} | Delete an alert rule
[**adminDeleteLGUPartnership**](AdminApi.md#admindeletelgupartnership) | **DELETE** /admin/lgu-partnerships/{id} | Delete an LGU partnership
[**adminDeleteRole**](AdminApi.md#admindeleterole) | **DELETE** /admin/roles/{id} | Delete a role
[**adminDeleteServiceArea**](AdminApi.md#admindeleteservicearea) | **DELETE** /admin/service-areas/{id} | Delete a service area
[**adminDriverHeatmap**](AdminApi.md#admindriverheatmap) | **GET** /admin/drivers/heatmap | Driver supply heatmap
[**adminDuplicateRole**](AdminApi.md#adminduplicaterole) | **POST** /admin/roles/{id}/duplicate | Duplicate a role
[**adminExportReport**](AdminApi.md#adminexportreport) | **POST** /admin/reports/export/{type} | Generate a report export
[**adminGetCommissionConfig**](AdminApi.md#admingetcommissionconfig) | **GET** /admin/payments/commission-config | Get commission configuration
[**adminGetCompliance**](AdminApi.md#admingetcompliance) | **GET** /admin/safety/compliance | LTFRB compliance dashboard data
[**adminGetDashboard**](AdminApi.md#admingetdashboard) | **GET** /admin/dashboard | Get platform dashboard metrics
[**adminGetFares**](AdminApi.md#admingetfares) | **GET** /admin/fares | Get fare configurations
[**adminGetFeatureFlags**](AdminApi.md#admingetfeatureflags) | **GET** /admin/system/feature-flags | Get all feature flags
[**adminGetIncident**](AdminApi.md#admingetincident) | **GET** /admin/incidents/{id} | Get incident detail with SOS status-history timeline
[**adminGetInfraMetrics**](AdminApi.md#admingetinframetrics) | **GET** /admin/system/infra-metrics | Get infrastructure performance metrics
[**adminGetIntegrations**](AdminApi.md#admingetintegrations) | **GET** /admin/system/integrations | Get 3rd party integrations
[**adminGetKycQueue**](AdminApi.md#admingetkycqueue) | **GET** /admin/safety/kyc | Get KYC queue
[**adminGetLGUPartnership**](AdminApi.md#admingetlgupartnership) | **GET** /admin/lgu-partnerships/{id} | Get an LGU partnership
[**adminGetMe**](AdminApi.md#admingetme) | **GET** /admin/users/me | Get the authenticated admin&#39;s own profile
[**adminGetMyPermissions**](AdminApi.md#admingetmypermissions) | **GET** /admin/me/permissions | Get the authenticated admin&#39;s own role and permissions
[**adminGetNotificationTemplates**](AdminApi.md#admingetnotificationtemplates) | **GET** /admin/system/notification-templates | Get notification templates
[**adminGetPaymentConfig**](AdminApi.md#admingetpaymentconfig) | **GET** /admin/payments/config | Get payment gateway configurations
[**adminGetPaymentSummary**](AdminApi.md#admingetpaymentsummary) | **GET** /admin/payments/summary | Get financial summary
[**adminGetPayouts**](AdminApi.md#admingetpayouts) | **GET** /admin/payments/payouts | Get pending driver payouts
[**adminGetReportChart**](AdminApi.md#admingetreportchart) | **GET** /admin/reports/chart/{type} | Get data for a specific report chart
[**adminGetReportList**](AdminApi.md#admingetreportlist) | **GET** /admin/reports/list | Get available reports
[**adminGetRole**](AdminApi.md#admingetrole) | **GET** /admin/roles/{id} | Get role with permissions
[**adminGetRoleAdmins**](AdminApi.md#admingetroleadmins) | **GET** /admin/roles/{id}/admins | List admins assigned to a role
[**adminGetRolePermissions**](AdminApi.md#admingetrolepermissions) | **GET** /admin/roles/{id}/permissions | Get permission set for a role
[**adminGetServices**](AdminApi.md#admingetservices) | **GET** /admin/system/services | Get system services health
[**adminGetSurge**](AdminApi.md#admingetsurge) | **GET** /admin/fares/surge | Get surge pricing configuration
[**adminGetTransactions**](AdminApi.md#admingettransactions) | **GET** /admin/payments/transactions | Get recent transactions
[**adminGetUserActivity**](AdminApi.md#admingetuseractivity) | **GET** /admin/users/{id}/activity | Get admin activity log
[**adminListAlertEvents**](AdminApi.md#adminlistalertevents) | **GET** /admin/alerts/events | List recent alert events
[**adminListAlertRules**](AdminApi.md#adminlistalertrules) | **GET** /admin/alerts/rules | List alert rules
[**adminListAudit**](AdminApi.md#adminlistaudit) | **GET** /admin/audit | List audit logs
[**adminListDrivers**](AdminApi.md#adminlistdrivers) | **GET** /admin/users/drivers | List all drivers
[**adminListIncidents**](AdminApi.md#adminlistincidents) | **GET** /admin/incidents | List system incidents
[**adminListLGUPartnerships**](AdminApi.md#adminlistlgupartnerships) | **GET** /admin/lgu-partnerships | List LGU partnerships
[**adminListPassengers**](AdminApi.md#adminlistpassengers) | **GET** /admin/users/passengers | List all passengers
[**adminListRides**](AdminApi.md#adminlistrides) | **GET** /admin/rides | List all rides (Admin Browse)
[**adminListRoles**](AdminApi.md#adminlistroles) | **GET** /admin/roles | List all roles
[**adminListServiceAreas**](AdminApi.md#adminlistserviceareas) | **GET** /admin/service-areas | List service areas (admin — includes inactive)
[**adminListUsers**](AdminApi.md#adminlistusers) | **GET** /admin/users | List all administrators
[**adminMetricsDrivers**](AdminApi.md#adminmetricsdrivers) | **GET** /admin/metrics/drivers | Active driver count with trend
[**adminMetricsRevenue**](AdminApi.md#adminmetricsrevenue) | **GET** /admin/metrics/revenue | Revenue for a period (PHP)
[**adminMetricsRiders**](AdminApi.md#adminmetricsriders) | **GET** /admin/metrics/riders | Active rider count with trend
[**adminMetricsRides**](AdminApi.md#adminmetricsrides) | **GET** /admin/metrics/rides | Ride count for a period
[**adminMetricsWaitTime**](AdminApi.md#adminmetricswaittime) | **GET** /admin/metrics/wait-time | Average wait time stats
[**adminResetUserPassword**](AdminApi.md#adminresetuserpassword) | **PUT** /admin/users/{id}/password | Reset another admin&#39;s password
[**adminResolveIncident**](AdminApi.md#adminresolveincident) | **PUT** /admin/incidents/{id}/resolve | Resolve an incident
[**adminSimulateFare**](AdminApi.md#adminsimulatefare) | **POST** /admin/fares/simulate | Simulate a ride fare
[**adminTestIntegration**](AdminApi.md#admintestintegration) | **POST** /admin/system/integrations/{service}/test | Test integration health
[**adminUpdateAlertRule**](AdminApi.md#adminupdatealertrule) | **PUT** /admin/alerts/rules/{id} | Update an alert rule
[**adminUpdateCommissionConfig**](AdminApi.md#adminupdatecommissionconfig) | **PUT** /admin/payments/commission-config | Update commission configuration
[**adminUpdateFares**](AdminApi.md#adminupdatefares) | **PUT** /admin/fares | Update base fares
[**adminUpdateFeatureFlag**](AdminApi.md#adminupdatefeatureflag) | **PUT** /admin/system/feature-flags/{key} | Update a feature flag
[**adminUpdateIntegration**](AdminApi.md#adminupdateintegration) | **PUT** /admin/system/integrations/{service} | Update integration settings
[**adminUpdateKycStatus**](AdminApi.md#adminupdatekycstatus) | **PUT** /admin/safety/kyc/{id} | Update KYC status
[**adminUpdateLGUPartnership**](AdminApi.md#adminupdatelgupartnership) | **PUT** /admin/lgu-partnerships/{id} | Update an LGU partnership
[**adminUpdateNotificationTemplate**](AdminApi.md#adminupdatenotificationtemplate) | **PUT** /admin/system/notification-templates/{event} | Update a notification template
[**adminUpdatePaymentConfig**](AdminApi.md#adminupdatepaymentconfig) | **PUT** /admin/payments/config/{provider} | Update payment gateway config
[**adminUpdateRole**](AdminApi.md#adminupdaterole) | **PUT** /admin/roles/{id} | Update role
[**adminUpdateServiceArea**](AdminApi.md#adminupdateservicearea) | **PUT** /admin/service-areas/{id} | Update a service area
[**adminUpdateSurge**](AdminApi.md#adminupdatesurge) | **PUT** /admin/surge | Update surge configuration
[**adminUpdateUser**](AdminApi.md#adminupdateuser) | **PUT** /admin/users/{id} | Update administrator status


# **adminApprovePayout**
> adminApprovePayout(id)

Approve a driver payout

Authorizes a specific batch payout for processing. Requires Superadmin or Finance role.

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    api.adminApprovePayout(id);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminApprovePayout: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminAssignIncident**
> adminAssignIncident(id, adminAssignIncidentRequest)

Reassign an incident

Sets `assigned_to`. The DB trigger records the change in incident_status_history so the timeline reflects the reassignment. Body `{\"assignee_id\": \"<uuid>\" | null}`. 

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final AdminAssignIncidentRequest adminAssignIncidentRequest = ; // AdminAssignIncidentRequest | 

try {
    api.adminAssignIncident(id, adminAssignIncidentRequest);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminAssignIncident: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **adminAssignIncidentRequest** | [**AdminAssignIncidentRequest**](AdminAssignIncidentRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminAuditExport**
> Uint8List adminAuditExport(format)

Export audit log as CSV

Returns a CSV file of audit log entries matching optional filters.

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();
final String format = format_example; // String | 

try {
    final response = api.adminAuditExport(format);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminAuditExport: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **format** | **String**|  | [optional] [default to 'csv']

### Return type

[**Uint8List**](Uint8List.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: text/csv, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminBatchApprovePayouts**
> AdminBatchApprovePayouts200Response adminBatchApprovePayouts(batchApproveRequest)

Batch approve driver payouts

Approves multiple payouts in a single request.

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();
final BatchApproveRequest batchApproveRequest = ; // BatchApproveRequest | 

try {
    final response = api.adminBatchApprovePayouts(batchApproveRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminBatchApprovePayouts: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **batchApproveRequest** | [**BatchApproveRequest**](BatchApproveRequest.md)|  | 

### Return type

[**AdminBatchApprovePayouts200Response**](AdminBatchApprovePayouts200Response.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminBatchKyc**
> AdminBatchKyc200Response adminBatchKyc(kycBatchRequest)

Batch approve or reject KYC submissions

Processes multiple driver KYC submissions in a single batch operation.

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();
final KycBatchRequest kycBatchRequest = ; // KycBatchRequest | 

try {
    final response = api.adminBatchKyc(kycBatchRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminBatchKyc: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **kycBatchRequest** | [**KycBatchRequest**](KycBatchRequest.md)|  | 

### Return type

[**AdminBatchKyc200Response**](AdminBatchKyc200Response.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminChangePassword**
> adminChangePassword(changePasswordRequest)

Change own password

Authenticated admin changes their password by providing the current one.

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();
final ChangePasswordRequest changePasswordRequest = ; // ChangePasswordRequest | 

try {
    api.adminChangePassword(changePasswordRequest);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminChangePassword: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **changePasswordRequest** | [**ChangePasswordRequest**](ChangePasswordRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminCreateAlertRule**
> AlertRule adminCreateAlertRule(alertRuleInput)

Create an alert rule

Creates a new alert rule. Once active, matching metric conditions will generate alert events consumed by the admin alerts tab. 

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();
final AlertRuleInput alertRuleInput = ; // AlertRuleInput | 

try {
    final response = api.adminCreateAlertRule(alertRuleInput);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminCreateAlertRule: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **alertRuleInput** | [**AlertRuleInput**](AlertRuleInput.md)|  | 

### Return type

[**AlertRule**](AlertRule.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminCreateAuditEntry**
> adminCreateAuditEntry(createAuditEntryRequest)

Write an audit log entry

Records an admin action in the audit trail. Called by the frontend after high-impact mutations (fare changes, role edits, payout approvals). Requires any admin role. 

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();
final CreateAuditEntryRequest createAuditEntryRequest = ; // CreateAuditEntryRequest | 

try {
    api.adminCreateAuditEntry(createAuditEntryRequest);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminCreateAuditEntry: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createAuditEntryRequest** | [**CreateAuditEntryRequest**](CreateAuditEntryRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminCreateLGUPartnership**
> LGUPartnership adminCreateLGUPartnership(lGUPartnershipInput)

Create an LGU partnership

Registers a new LGU partnership, optionally linking it to an existing service area via `service_area_id`. 

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();
final LGUPartnershipInput lGUPartnershipInput = ; // LGUPartnershipInput | 

try {
    final response = api.adminCreateLGUPartnership(lGUPartnershipInput);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminCreateLGUPartnership: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **lGUPartnershipInput** | [**LGUPartnershipInput**](LGUPartnershipInput.md)|  | 

### Return type

[**LGUPartnership**](LGUPartnership.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminCreateRole**
> Role adminCreateRole(createRoleRequest)

Create a custom role

Creates a new role with a permission set. Requires Superadmin role.

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();
final CreateRoleRequest createRoleRequest = ; // CreateRoleRequest | 

try {
    final response = api.adminCreateRole(createRoleRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminCreateRole: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createRoleRequest** | [**CreateRoleRequest**](CreateRoleRequest.md)|  | 

### Return type

[**Role**](Role.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminCreateServiceArea**
> ServiceArea adminCreateServiceArea(serviceAreaInput)

Create a service area

Creates a new service area with an associated boundary polygon. The boundary is reused by the fare calculator for point-in-polygon origin lookups. 

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();
final ServiceAreaInput serviceAreaInput = ; // ServiceAreaInput | 

try {
    final response = api.adminCreateServiceArea(serviceAreaInput);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminCreateServiceArea: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **serviceAreaInput** | [**ServiceAreaInput**](ServiceAreaInput.md)|  | 

### Return type

[**ServiceArea**](ServiceArea.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminCreateUser**
> UserProfile adminCreateUser(createAdminRequest)

Create a new administrator

Requires Superadmin role.

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();
final CreateAdminRequest createAdminRequest = ; // CreateAdminRequest | 

try {
    final response = api.adminCreateUser(createAdminRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminCreateUser: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createAdminRequest** | [**CreateAdminRequest**](CreateAdminRequest.md)|  | 

### Return type

[**UserProfile**](UserProfile.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminDeactivateUser**
> adminDeactivateUser(id)

Deactivate an administrator

Permanently deactivates the admin account. Account is preserved for audit trail. Requires Superadmin role.

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    api.adminDeactivateUser(id);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminDeactivateUser: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminDeleteAlertRule**
> adminDeleteAlertRule(id)

Delete an alert rule

Permanently removes an alert rule. Historical alert events raised by the rule are retained. 

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    api.adminDeleteAlertRule(id);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminDeleteAlertRule: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminDeleteLGUPartnership**
> adminDeleteLGUPartnership(id)

Delete an LGU partnership

Permanently removes an LGU partnership record. Does not affect the linked service area. 

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    api.adminDeleteLGUPartnership(id);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminDeleteLGUPartnership: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminDeleteRole**
> adminDeleteRole(id)

Delete a role

Fails if any admin is assigned this role. Cannot delete system roles.

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    api.adminDeleteRole(id);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminDeleteRole: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminDeleteServiceArea**
> adminDeleteServiceArea(id)

Delete a service area

Permanently removes a service area. Any LGU partnerships pointing at this area have their `service_area_id` cleared. 

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    api.adminDeleteServiceArea(id);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminDeleteServiceArea: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminDriverHeatmap**
> DriverHeatmap adminDriverHeatmap()

Driver supply heatmap

One position per online driver with last-known PostGIS coordinates, vehicle type, and ride availability. Returned bounds are the actual extents of the positions (Metro Manila default if list is empty). 

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();

try {
    final response = api.adminDriverHeatmap();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminDriverHeatmap: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**DriverHeatmap**](DriverHeatmap.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminDuplicateRole**
> Role adminDuplicateRole(id)

Duplicate a role

Creates a copy of the given role with \"Copy of [name]\" as the new name. Permissions are copied verbatim. The new role is not a system role. Requires Superadmin role. 

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.adminDuplicateRole(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminDuplicateRole: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**Role**](Role.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminExportReport**
> AdminExportReport200Response adminExportReport(type)

Generate a report export

Commands the background queue to format a formal, complete CSV reporting log format based on parameter type.

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();
final String type = type_example; // String | 

try {
    final response = api.adminExportReport(type);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminExportReport: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **type** | **String**|  | 

### Return type

[**AdminExportReport200Response**](AdminExportReport200Response.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminGetCommissionConfig**
> CommissionConfig adminGetCommissionConfig()

Get commission configuration

Returns the current global commission rates. Requires Superadmin or Finance role.

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();

try {
    final response = api.adminGetCommissionConfig();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminGetCommissionConfig: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**CommissionConfig**](CommissionConfig.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminGetCompliance**
> ComplianceData adminGetCompliance()

LTFRB compliance dashboard data

Returns aggregated metrics and stats for LTFRB compliance reporting.

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();

try {
    final response = api.adminGetCompliance();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminGetCompliance: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ComplianceData**](ComplianceData.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminGetDashboard**
> DashboardResponse adminGetDashboard()

Get platform dashboard metrics

Returns platform-wide metrics. Requires Admin, Operations, Finance, or Support role.

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();

try {
    final response = api.adminGetDashboard();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminGetDashboard: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**DashboardResponse**](DashboardResponse.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminGetFares**
> AdminFaresResponse adminGetFares()

Get fare configurations

Requires Superadmin or Finance role.

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();

try {
    final response = api.adminGetFares();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminGetFares: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**AdminFaresResponse**](AdminFaresResponse.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminGetFeatureFlags**
> BuiltList<FeatureFlag> adminGetFeatureFlags()

Get all feature flags

Returns active toggles controlling logic behaviors. Requires Superadmin or Operations role.

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();

try {
    final response = api.adminGetFeatureFlags();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminGetFeatureFlags: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;FeatureFlag&gt;**](FeatureFlag.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminGetIncident**
> IncidentDetail adminGetIncident(id)

Get incident detail with SOS status-history timeline

Returns the full incident record plus the ordered status-history timeline for a single SOS/incident, used by the admin incident detail modal. 

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.adminGetIncident(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminGetIncident: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**IncidentDetail**](IncidentDetail.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminGetInfraMetrics**
> InfraMetrics adminGetInfraMetrics()

Get infrastructure performance metrics

Aggregated p50/p95 request latency, WebSocket connection count, and DB query p99 latency used by the System Health page. Values are derived from the perf-timing middleware and health-probe goroutine — no more hardcoded SystemHealth.tsx constants. 

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();

try {
    final response = api.adminGetInfraMetrics();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminGetInfraMetrics: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**InfraMetrics**](InfraMetrics.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminGetIntegrations**
> BuiltList<Integration> adminGetIntegrations()

Get 3rd party integrations

Fetch connected external webhook systems. Requires Superadmin or Operations role.

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();

try {
    final response = api.adminGetIntegrations();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminGetIntegrations: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;Integration&gt;**](Integration.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminGetKycQueue**
> BuiltList<KycEntry> adminGetKycQueue()

Get KYC queue

Returns the driver compliance approval queue. Requires Superadmin, Support or Operations role.

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();

try {
    final response = api.adminGetKycQueue();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminGetKycQueue: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;KycEntry&gt;**](KycEntry.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminGetLGUPartnership**
> LGUPartnership adminGetLGUPartnership(id)

Get an LGU partnership

Returns a single LGU partnership record by id, including linked service area and contact details. 

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.adminGetLGUPartnership(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminGetLGUPartnership: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**LGUPartnership**](LGUPartnership.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminGetMe**
> AdminUser adminGetMe()

Get the authenticated admin's own profile

Returns the current admin's profile including role_id, role_name, and status. Call on admin app cold-start to re-hydrate session state. 

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();

try {
    final response = api.adminGetMe();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminGetMe: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**AdminUser**](AdminUser.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminGetMyPermissions**
> Role adminGetMyPermissions()

Get the authenticated admin's own role and permissions

Returns the caller's role (id, name, permissions) used by the admin app to drive sidebar visibility and write-gating. No specific role is required: any authenticated user may call this for themselves. Users with no assigned role_id (e.g. passengers/drivers that reach this endpoint) receive a role envelope with an empty permissions array. 

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();

try {
    final response = api.adminGetMyPermissions();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminGetMyPermissions: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**Role**](Role.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminGetNotificationTemplates**
> BuiltList<NotificationTemplate> adminGetNotificationTemplates()

Get notification templates

Retrieves Email and SMS message configurations. Requires Superadmin or Operations role.

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();

try {
    final response = api.adminGetNotificationTemplates();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminGetNotificationTemplates: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;NotificationTemplate&gt;**](NotificationTemplate.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminGetPaymentConfig**
> BuiltList<PaymentGatewayConfig> adminGetPaymentConfig()

Get payment gateway configurations

API keys are masked (last 4 characters only). Requires Superadmin.

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();

try {
    final response = api.adminGetPaymentConfig();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminGetPaymentConfig: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;PaymentGatewayConfig&gt;**](PaymentGatewayConfig.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminGetPaymentSummary**
> PaymentSummary adminGetPaymentSummary()

Get financial summary

Returns a high-level overview of revenue, payouts, and commissions. Requires Superadmin or Finance role.

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();

try {
    final response = api.adminGetPaymentSummary();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminGetPaymentSummary: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**PaymentSummary**](PaymentSummary.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminGetPayouts**
> BuiltList<DriverPayout> adminGetPayouts()

Get pending driver payouts

Returns a list of batch driver payouts pending review. Requires Superadmin or Finance role.

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();

try {
    final response = api.adminGetPayouts();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminGetPayouts: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;DriverPayout&gt;**](DriverPayout.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminGetReportChart**
> BuiltList<BuiltMap<String, JsonObject>> adminGetReportChart(type)

Get data for a specific report chart

Returns structural graph and chart representation data mapping string to number values for display purposes.

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();
final String type = type_example; // String | 

try {
    final response = api.adminGetReportChart(type);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminGetReportChart: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **type** | **String**|  | 

### Return type

[**BuiltList&lt;BuiltMap&lt;String, JsonObject&gt;&gt;**](BuiltMap.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminGetReportList**
> BuiltList<ReportDefinition> adminGetReportList()

Get available reports

Retrieves available reporting configurations describing structural tables. Requires Superadmin, Finance, Operations, or Support role.

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();

try {
    final response = api.adminGetReportList();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminGetReportList: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;ReportDefinition&gt;**](ReportDefinition.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminGetRole**
> Role adminGetRole(id)

Get role with permissions

Returns the details of a specific role, including its associated permissions.

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.adminGetRole(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminGetRole: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**Role**](Role.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminGetRoleAdmins**
> BuiltList<UserProfile> adminGetRoleAdmins(id)

List admins assigned to a role

Returns a list of administrators who have been assigned the specified role.

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.adminGetRoleAdmins(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminGetRoleAdmins: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**BuiltList&lt;UserProfile&gt;**](UserProfile.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminGetRolePermissions**
> BuiltList<RolePermission> adminGetRolePermissions(id)

Get permission set for a role

Returns the list of permissions assigned to the specified role.

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.adminGetRolePermissions(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminGetRolePermissions: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**BuiltList&lt;RolePermission&gt;**](RolePermission.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminGetServices**
> BuiltList<SystemService> adminGetServices()

Get system services health

Evaluates status of 3rd-party internal services running the core infrastructure. Requires Superadmin or Operations role.

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();

try {
    final response = api.adminGetServices();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminGetServices: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;SystemService&gt;**](SystemService.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminGetSurge**
> SurgeConfig adminGetSurge()

Get surge pricing configuration

Returns the current global surge pricing settings and multipliers.

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();

try {
    final response = api.adminGetSurge();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminGetSurge: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**SurgeConfig**](SurgeConfig.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminGetTransactions**
> BuiltList<Transaction> adminGetTransactions()

Get recent transactions

Returns a list of recently completed ride and tip transactions. Requires Superadmin, Finance, or Operations role.

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();

try {
    final response = api.adminGetTransactions();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminGetTransactions: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;Transaction&gt;**](Transaction.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminGetUserActivity**
> AuditLogResponse adminGetUserActivity(id)

Get admin activity log

Returns audit log entries where this admin was the actor. Requires Superadmin role.

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.adminGetUserActivity(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminGetUserActivity: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**AuditLogResponse**](AuditLogResponse.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminListAlertEvents**
> BuiltList<AlertEvent> adminListAlertEvents(limit)

List recent alert events

Returns the most recent alert events raised by configured rules, newest first, capped by the optional `limit` query parameter. 

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();
final int limit = 56; // int | 

try {
    final response = api.adminListAlertEvents(limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminListAlertEvents: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **limit** | **int**|  | [optional] [default to 100]

### Return type

[**BuiltList&lt;AlertEvent&gt;**](AlertEvent.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminListAlertRules**
> BuiltList<AlertRule> adminListAlertRules()

List alert rules

Returns all configured alert rules evaluated against platform metrics (e.g. cancellation spikes, driver supply drops). 

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();

try {
    final response = api.adminListAlertRules();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminListAlertRules: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;AlertRule&gt;**](AlertRule.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminListAudit**
> AuditLogResponse adminListAudit(limit, offset, actorId)

List audit logs

Requires Superadmin role.

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();
final int limit = 56; // int | 
final int offset = 56; // int | 
final String actorId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Filter entries to those created by this admin UUID

try {
    final response = api.adminListAudit(limit, offset, actorId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminListAudit: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **limit** | **int**|  | [optional] [default to 50]
 **offset** | **int**|  | [optional] [default to 0]
 **actorId** | **String**| Filter entries to those created by this admin UUID | [optional] 

### Return type

[**AuditLogResponse**](AuditLogResponse.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminListDrivers**
> AdminUserListResponse adminListDrivers(q, page, limit)

List all drivers

Returns a paginated list of drivers. Supports name/email search. Requires Admin, Operations, or Support role. 

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();
final String q = q_example; // String | Search by name or email (partial match)
final int page = 56; // int | 
final int limit = 56; // int | 

try {
    final response = api.adminListDrivers(q, page, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminListDrivers: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **q** | **String**| Search by name or email (partial match) | [optional] 
 **page** | **int**|  | [optional] [default to 1]
 **limit** | **int**|  | [optional] [default to 20]

### Return type

[**AdminUserListResponse**](AdminUserListResponse.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminListIncidents**
> BuiltList<Incident> adminListIncidents(status)

List system incidents

Requires Superadmin, Operations, or Support role.

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();
final String status = status_example; // String | 

try {
    final response = api.adminListIncidents(status);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminListIncidents: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **status** | **String**|  | [optional] 

### Return type

[**BuiltList&lt;Incident&gt;**](Incident.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminListLGUPartnerships**
> BuiltList<LGUPartnership> adminListLGUPartnerships()

List LGU partnerships

Returns all Local Government Unit (LGU) partnership records used to track compliance engagements and contact info per city or municipality. 

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();

try {
    final response = api.adminListLGUPartnerships();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminListLGUPartnerships: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;LGUPartnership&gt;**](LGUPartnership.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminListPassengers**
> AdminUserListResponse adminListPassengers(q, page, limit)

List all passengers

Returns a paginated list of passengers. Supports name/email search. Requires Admin, Operations, or Support role. 

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();
final String q = q_example; // String | Search by name or email (partial match)
final int page = 56; // int | 
final int limit = 56; // int | 

try {
    final response = api.adminListPassengers(q, page, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminListPassengers: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **q** | **String**| Search by name or email (partial match) | [optional] 
 **page** | **int**|  | [optional] [default to 1]
 **limit** | **int**|  | [optional] [default to 20]

### Return type

[**AdminUserListResponse**](AdminUserListResponse.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminListRides**
> AdminRideListResponse adminListRides(status, page, limit)

List all rides (Admin Browse)

Returns a paginated list of all rides. Supports filtering by status. Requires Admin, Operations, Finance, or Support role. 

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();
final RideStatus status = ; // RideStatus | 
final int page = 56; // int | 
final int limit = 56; // int | 

try {
    final response = api.adminListRides(status, page, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminListRides: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **status** | [**RideStatus**](.md)|  | [optional] 
 **page** | **int**|  | [optional] [default to 1]
 **limit** | **int**|  | [optional] [default to 20]

### Return type

[**AdminRideListResponse**](AdminRideListResponse.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminListRoles**
> BuiltList<Role> adminListRoles()

List all roles

Returns built-in and custom roles. Requires Superadmin role.

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();

try {
    final response = api.adminListRoles();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminListRoles: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;Role&gt;**](Role.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminListServiceAreas**
> BuiltList<ServiceArea> adminListServiceAreas()

List service areas (admin — includes inactive)

Returns every configured service area, including inactive ones, for admin management views. Unlike the public list, this endpoint does not filter by `active` status. 

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();

try {
    final response = api.adminListServiceAreas();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminListServiceAreas: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;ServiceArea&gt;**](ServiceArea.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminListUsers**
> BuiltList<UserProfile> adminListUsers()

List all administrators

Requires Superadmin role.

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();

try {
    final response = api.adminListUsers();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminListUsers: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;UserProfile&gt;**](UserProfile.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminMetricsDrivers**
> MetricResponse adminMetricsDrivers()

Active driver count with trend

Returns the current number of active drivers and the trend compared to the previous period.

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();

try {
    final response = api.adminMetricsDrivers();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminMetricsDrivers: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**MetricResponse**](MetricResponse.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminMetricsRevenue**
> MetricResponse adminMetricsRevenue(period)

Revenue for a period (PHP)

Returns the total revenue generated within the specified period in Philippine Pesos.

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();
final String period = today; // String | 

try {
    final response = api.adminMetricsRevenue(period);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminMetricsRevenue: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **period** | **String**|  | [optional] 

### Return type

[**MetricResponse**](MetricResponse.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminMetricsRiders**
> MetricResponse adminMetricsRiders()

Active rider count with trend

Returns the current number of active riders and the trend compared to the previous period.

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();

try {
    final response = api.adminMetricsRiders();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminMetricsRiders: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**MetricResponse**](MetricResponse.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminMetricsRides**
> MetricResponse adminMetricsRides(period)

Ride count for a period

Returns the total number of rides completed within the specified period.

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();
final String period = today; // String | 

try {
    final response = api.adminMetricsRides(period);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminMetricsRides: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **period** | **String**|  | [optional] 

### Return type

[**MetricResponse**](MetricResponse.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminMetricsWaitTime**
> MetricResponse adminMetricsWaitTime()

Average wait time stats

Returns the average wait time for passengers across the platform.

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();

try {
    final response = api.adminMetricsWaitTime();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminMetricsWaitTime: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**MetricResponse**](MetricResponse.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminResetUserPassword**
> adminResetUserPassword(id, resetPasswordRequest)

Reset another admin's password

Superadmin sets a new password for another admin account. Distinct from `PUT /admin/auth/password` which is self-service. Requires Superadmin role. 

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final ResetPasswordRequest resetPasswordRequest = ; // ResetPasswordRequest | 

try {
    api.adminResetUserPassword(id, resetPasswordRequest);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminResetUserPassword: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **resetPasswordRequest** | [**ResetPasswordRequest**](ResetPasswordRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminResolveIncident**
> adminResolveIncident(id, incidentResolveRequest)

Resolve an incident

Requires Superadmin or Operations role.

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final IncidentResolveRequest incidentResolveRequest = ; // IncidentResolveRequest | 

try {
    api.adminResolveIncident(id, incidentResolveRequest);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminResolveIncident: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **incidentResolveRequest** | [**IncidentResolveRequest**](IncidentResolveRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminSimulateFare**
> FareSimulationResponse adminSimulateFare(fareSimulationRequest)

Simulate a ride fare

Requires Superadmin role.

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();
final FareSimulationRequest fareSimulationRequest = ; // FareSimulationRequest | 

try {
    final response = api.adminSimulateFare(fareSimulationRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminSimulateFare: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **fareSimulationRequest** | [**FareSimulationRequest**](FareSimulationRequest.md)|  | 

### Return type

[**FareSimulationResponse**](FareSimulationResponse.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminTestIntegration**
> IntegrationTestResult adminTestIntegration(service)

Test integration health

Pings the external service and returns latency and status.

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();
final String service = service_example; // String | 

try {
    final response = api.adminTestIntegration(service);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminTestIntegration: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **service** | **String**|  | 

### Return type

[**IntegrationTestResult**](IntegrationTestResult.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminUpdateAlertRule**
> adminUpdateAlertRule(id, alertRuleInput)

Update an alert rule

Updates the threshold, severity, or enabled flag of an existing alert rule. Historical alert events are not modified. 

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final AlertRuleInput alertRuleInput = ; // AlertRuleInput | 

try {
    api.adminUpdateAlertRule(id, alertRuleInput);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminUpdateAlertRule: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **alertRuleInput** | [**AlertRuleInput**](AlertRuleInput.md)|  | 

### Return type

void (empty response body)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminUpdateCommissionConfig**
> adminUpdateCommissionConfig(commissionConfig)

Update commission configuration

Modifies platform commission settings. Requires Superadmin role.

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();
final CommissionConfig commissionConfig = ; // CommissionConfig | 

try {
    api.adminUpdateCommissionConfig(commissionConfig);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminUpdateCommissionConfig: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **commissionConfig** | [**CommissionConfig**](CommissionConfig.md)|  | 

### Return type

void (empty response body)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminUpdateFares**
> adminUpdateFares(fareConfig)

Update base fares

Requires Superadmin role.

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();
final BuiltList<FareConfig> fareConfig = ; // BuiltList<FareConfig> | 

try {
    api.adminUpdateFares(fareConfig);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminUpdateFares: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **fareConfig** | [**BuiltList&lt;FareConfig&gt;**](FareConfig.md)|  | 

### Return type

void (empty response body)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminUpdateFeatureFlag**
> adminUpdateFeatureFlag(key, adminUpdateFeatureFlagRequest)

Update a feature flag

Enable or disable a feature flag. Requires Superadmin role.

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();
final String key = key_example; // String | 
final AdminUpdateFeatureFlagRequest adminUpdateFeatureFlagRequest = ; // AdminUpdateFeatureFlagRequest | 

try {
    api.adminUpdateFeatureFlag(key, adminUpdateFeatureFlagRequest);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminUpdateFeatureFlag: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 
 **adminUpdateFeatureFlagRequest** | [**AdminUpdateFeatureFlagRequest**](AdminUpdateFeatureFlagRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminUpdateIntegration**
> adminUpdateIntegration(service, requestBody)

Update integration settings

Modifies secure settings like generic API keys per service. Requires Superadmin role.

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();
final String service = service_example; // String | 
final BuiltMap<String, String> requestBody = ; // BuiltMap<String, String> | 

try {
    api.adminUpdateIntegration(service, requestBody);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminUpdateIntegration: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **service** | **String**|  | 
 **requestBody** | [**BuiltMap&lt;String, String&gt;**](String.md)|  | 

### Return type

void (empty response body)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminUpdateKycStatus**
> adminUpdateKycStatus(id, adminUpdateKycStatusRequest)

Update KYC status

Resolves driver compliance document submission (e.g. accepts or rejects). Requires Superadmin or Support role.

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final AdminUpdateKycStatusRequest adminUpdateKycStatusRequest = ; // AdminUpdateKycStatusRequest | 

try {
    api.adminUpdateKycStatus(id, adminUpdateKycStatusRequest);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminUpdateKycStatus: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **adminUpdateKycStatusRequest** | [**AdminUpdateKycStatusRequest**](AdminUpdateKycStatusRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminUpdateLGUPartnership**
> adminUpdateLGUPartnership(id, lGUPartnershipInput)

Update an LGU partnership

Updates LGU partnership fields such as status, contact info, or linked service area. 

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final LGUPartnershipInput lGUPartnershipInput = ; // LGUPartnershipInput | 

try {
    api.adminUpdateLGUPartnership(id, lGUPartnershipInput);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminUpdateLGUPartnership: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **lGUPartnershipInput** | [**LGUPartnershipInput**](LGUPartnershipInput.md)|  | 

### Return type

void (empty response body)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminUpdateNotificationTemplate**
> adminUpdateNotificationTemplate(event, adminUpdateNotificationTemplateRequest)

Update a notification template

Upgrades the literal content of a notification template event. Requires Superadmin role.

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();
final String event = event_example; // String | 
final AdminUpdateNotificationTemplateRequest adminUpdateNotificationTemplateRequest = ; // AdminUpdateNotificationTemplateRequest | 

try {
    api.adminUpdateNotificationTemplate(event, adminUpdateNotificationTemplateRequest);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminUpdateNotificationTemplate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **event** | **String**|  | 
 **adminUpdateNotificationTemplateRequest** | [**AdminUpdateNotificationTemplateRequest**](AdminUpdateNotificationTemplateRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminUpdatePaymentConfig**
> adminUpdatePaymentConfig(provider, updatePaymentConfigRequest)

Update payment gateway config

Requires Superadmin and password re-confirmation.

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();
final String provider = provider_example; // String | 
final UpdatePaymentConfigRequest updatePaymentConfigRequest = ; // UpdatePaymentConfigRequest | 

try {
    api.adminUpdatePaymentConfig(provider, updatePaymentConfigRequest);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminUpdatePaymentConfig: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **provider** | **String**|  | 
 **updatePaymentConfigRequest** | [**UpdatePaymentConfigRequest**](UpdatePaymentConfigRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminUpdateRole**
> Role adminUpdateRole(id, updateRoleRequest)

Update role

Cannot modify the super_admin built-in role.

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final UpdateRoleRequest updateRoleRequest = ; // UpdateRoleRequest | 

try {
    final response = api.adminUpdateRole(id, updateRoleRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminUpdateRole: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **updateRoleRequest** | [**UpdateRoleRequest**](UpdateRoleRequest.md)|  | 

### Return type

[**Role**](Role.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminUpdateServiceArea**
> adminUpdateServiceArea(id, serviceAreaInput)

Update a service area

Updates the name, LGU code, boundary polygon, and/or active flag of an existing service area. Boundary changes take effect on the next fare calculation. 

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final ServiceAreaInput serviceAreaInput = ; // ServiceAreaInput | 

try {
    api.adminUpdateServiceArea(id, serviceAreaInput);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminUpdateServiceArea: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **serviceAreaInput** | [**ServiceAreaInput**](ServiceAreaInput.md)|  | 

### Return type

void (empty response body)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminUpdateSurge**
> adminUpdateSurge(surgeConfig)

Update surge configuration

Requires Superadmin role.

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();
final SurgeConfig surgeConfig = ; // SurgeConfig | 

try {
    api.adminUpdateSurge(surgeConfig);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminUpdateSurge: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **surgeConfig** | [**SurgeConfig**](SurgeConfig.md)|  | 

### Return type

void (empty response body)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminUpdateUser**
> adminUpdateUser(id, updateAdminStatusRequest)

Update administrator status

Requires Superadmin role.

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final UpdateAdminStatusRequest updateAdminStatusRequest = ; // UpdateAdminStatusRequest | 

try {
    api.adminUpdateUser(id, updateAdminStatusRequest);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminUpdateUser: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **updateAdminStatusRequest** | [**UpdateAdminStatusRequest**](UpdateAdminStatusRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)


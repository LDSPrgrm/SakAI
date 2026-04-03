# sakai_api_client.api.AdminApi

## Load the API package
```dart
import 'package:sakai_api_client/api.dart';
```

All URIs are relative to *http://localhost:8080/api*

Method | HTTP request | Description
------------- | ------------- | -------------
[**adminApprovePayout**](AdminApi.md#adminapprovepayout) | **PUT** /admin/payments/payouts/{id}/approve | Approve a driver payout
[**adminCreateUser**](AdminApi.md#admincreateuser) | **POST** /admin/users | Create a new administrator
[**adminExportReport**](AdminApi.md#adminexportreport) | **POST** /admin/reports/export/{type} | Generate a report export
[**adminGetCommissionConfig**](AdminApi.md#admingetcommissionconfig) | **GET** /admin/payments/commission-config | Get commission configuration
[**adminGetDashboard**](AdminApi.md#admingetdashboard) | **GET** /admin/dashboard | Get platform dashboard metrics
[**adminGetFares**](AdminApi.md#admingetfares) | **GET** /admin/fares | Get fare configurations
[**adminGetFeatureFlags**](AdminApi.md#admingetfeatureflags) | **GET** /admin/system/feature-flags | Get all feature flags
[**adminGetIntegrations**](AdminApi.md#admingetintegrations) | **GET** /admin/system/integrations | Get 3rd party integrations
[**adminGetKycQueue**](AdminApi.md#admingetkycqueue) | **GET** /admin/safety/kyc | Get KYC queue
[**adminGetNotificationTemplates**](AdminApi.md#admingetnotificationtemplates) | **GET** /admin/system/notification-templates | Get notification templates
[**adminGetPaymentSummary**](AdminApi.md#admingetpaymentsummary) | **GET** /admin/payments/summary | Get financial summary
[**adminGetPayouts**](AdminApi.md#admingetpayouts) | **GET** /admin/payments/payouts | Get pending driver payouts
[**adminGetReportChart**](AdminApi.md#admingetreportchart) | **GET** /admin/reports/chart/{type} | Get data for a specific report chart
[**adminGetReportList**](AdminApi.md#admingetreportlist) | **GET** /admin/reports/list | Get available reports
[**adminGetServices**](AdminApi.md#admingetservices) | **GET** /admin/system/services | Get system services health
[**adminGetTransactions**](AdminApi.md#admingettransactions) | **GET** /admin/payments/transactions | Get recent transactions
[**adminListAudit**](AdminApi.md#adminlistaudit) | **GET** /admin/audit | List audit logs
[**adminListIncidents**](AdminApi.md#adminlistincidents) | **GET** /admin/incidents | List system incidents
[**adminListUsers**](AdminApi.md#adminlistusers) | **GET** /admin/users | List all administrators
[**adminResolveIncident**](AdminApi.md#adminresolveincident) | **PUT** /admin/incidents/{id}/resolve | Resolve an incident
[**adminSimulateFare**](AdminApi.md#adminsimulatefare) | **POST** /admin/fares/simulate | Simulate a ride fare
[**adminUpdateCommissionConfig**](AdminApi.md#adminupdatecommissionconfig) | **PUT** /admin/payments/commission-config | Update commission configuration
[**adminUpdateFares**](AdminApi.md#adminupdatefares) | **PUT** /admin/fares | Update base fares
[**adminUpdateFeatureFlag**](AdminApi.md#adminupdatefeatureflag) | **PUT** /admin/system/feature-flags/{key} | Update a feature flag
[**adminUpdateIntegration**](AdminApi.md#adminupdateintegration) | **PUT** /admin/system/integrations/{service} | Update integration settings
[**adminUpdateKycStatus**](AdminApi.md#adminupdatekycstatus) | **PUT** /admin/safety/kyc/{id} | Update KYC status
[**adminUpdateNotificationTemplate**](AdminApi.md#adminupdatenotificationtemplate) | **PUT** /admin/system/notification-templates/{event} | Update a notification template
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

# **adminListAudit**
> AuditLogResponse adminListAudit()

List audit logs

Requires Superadmin role.

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();

try {
    final response = api.adminListAudit();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminListAudit: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**AuditLogResponse**](AuditLogResponse.md)

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


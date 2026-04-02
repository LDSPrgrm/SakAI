# sakai_api_client.api.AdminApi

## Load the API package
```dart
import 'package:sakai_api_client/api.dart';
```

All URIs are relative to *http://localhost:8080*

Method | HTTP request | Description
------------- | ------------- | -------------
[**adminCreateAdmin**](AdminApi.md#admincreateadmin) | **POST** /api/admin/users | Create a new administrator
[**adminGetDashboard**](AdminApi.md#admingetdashboard) | **GET** /api/admin/dashboard | Get platform dashboard metrics
[**adminGetFares**](AdminApi.md#admingetfares) | **GET** /api/admin/fares | Get fare configurations
[**adminListAdmins**](AdminApi.md#adminlistadmins) | **GET** /api/admin/users | List all administrators
[**adminListAuditLogs**](AdminApi.md#adminlistauditlogs) | **GET** /api/admin/audit | List system audit logs
[**adminListIncidents**](AdminApi.md#adminlistincidents) | **GET** /api/admin/incidents | List safety and support incidents
[**adminResolveIncident**](AdminApi.md#adminresolveincident) | **PUT** /api/admin/incidents/{incidentId}/resolve | Resolve an incident
[**adminSimulateFare**](AdminApi.md#adminsimulatefare) | **POST** /api/admin/fares/simulate | Simulate a ride fare
[**adminUpdateAdminStatus**](AdminApi.md#adminupdateadminstatus) | **PUT** /api/admin/users/{userId} | Update admin status or role
[**adminUpdateFares**](AdminApi.md#adminupdatefares) | **PUT** /api/admin/fares | Update base fares
[**adminUpdateSurge**](AdminApi.md#adminupdatesurge) | **PUT** /api/admin/surge | Update surge pricing configuration


# **adminCreateAdmin**
> UserProfile adminCreateAdmin(createAdminRequest)

Create a new administrator

Provisions a new administrative user with a specific role. Super Admin only.

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();
final CreateAdminRequest createAdminRequest = ; // CreateAdminRequest | 

try {
    final response = api.adminCreateAdmin(createAdminRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminCreateAdmin: $e\n');
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

# **adminGetDashboard**
> DashboardResponse adminGetDashboard()

Get platform dashboard metrics

Returns real-time platform statistics for administrators.

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

Returns the current base fare settings for all vehicle types and surge configuration.

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

# **adminListAdmins**
> BuiltList<UserProfile> adminListAdmins()

List all administrators

Returns a list of all administrative users. Super Admin only.

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();

try {
    final response = api.adminListAdmins();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminListAdmins: $e\n');
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

# **adminListAuditLogs**
> AuditLogResponse adminListAuditLogs()

List system audit logs

Returns a paginated list of audit records for security monitoring. Super Admin only.

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();

try {
    final response = api.adminListAuditLogs();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminListAuditLogs: $e\n');
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

List safety and support incidents

Returns a list of incidents, optionally filtered by status.

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

# **adminResolveIncident**
> adminResolveIncident(incidentId, incidentResolveRequest)

Resolve an incident

Marks an incident as resolved with provided notes.

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();
final String incidentId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final IncidentResolveRequest incidentResolveRequest = ; // IncidentResolveRequest | 

try {
    api.adminResolveIncident(incidentId, incidentResolveRequest);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminResolveIncident: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **incidentId** | **String**|  | 
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

Calculates an estimated fare based on input parameters without creating a ride.

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

# **adminUpdateAdminStatus**
> adminUpdateAdminStatus(userId, updateAdminStatusRequest)

Update admin status or role

Modifies an existing administrator's role or status. Super Admin only.

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAdminApi();
final String userId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final UpdateAdminStatusRequest updateAdminStatusRequest = ; // UpdateAdminStatusRequest | 

try {
    api.adminUpdateAdminStatus(userId, updateAdminStatusRequest);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminUpdateAdminStatus: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **String**|  | 
 **updateAdminStatusRequest** | [**UpdateAdminStatusRequest**](UpdateAdminStatusRequest.md)|  | 

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

Overwrites base fare configurations for vehicle types. Super Admin only.

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

# **adminUpdateSurge**
> adminUpdateSurge(surgeConfig)

Update surge pricing configuration

Modifies surge multipliers, zones, and blackout periods. Super Admin only.

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


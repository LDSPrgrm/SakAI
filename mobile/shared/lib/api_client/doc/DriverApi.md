# sakai_api_client.api.DriverApi

## Load the API package
```dart
import 'package:sakai_api_client/api.dart';
```

All URIs are relative to *http://localhost:8080*

Method | HTTP request | Description
------------- | ------------- | -------------
[**driverGetIncomingRide**](DriverApi.md#drivergetincomingride) | **GET** /api/driver/rides/incoming | Get the current pending ride offer for this driver
[**driverSetStatus**](DriverApi.md#driversetstatus) | **PUT** /api/driver/status | Set driver online/offline status
[**driverUpdateLocation**](DriverApi.md#driverupdatelocation) | **PUT** /api/driver/location | Update driver&#39;s current location


# **driverGetIncomingRide**
> RideResponse driverGetIncomingRide()

Get the current pending ride offer for this driver

Returns the ride offer currently assigned to the driver, if any. Use this as a **polling fallback** when the WebSocket event may have been missed (e.g., app just reconnected). Returns `404` if no offer is pending. 

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getDriverApi();

try {
    final response = api.driverGetIncomingRide();
    print(response);
} on DioException catch (e) {
    print('Exception when calling DriverApi->driverGetIncomingRide: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**RideResponse**](RideResponse.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **driverSetStatus**
> DriverStatusResponse driverSetStatus(driverStatusRequest)

Set driver online/offline status

Toggles the driver's availability. Only users with `role=driver` may call this. Setting to `online` enters the driver into the matching pool. Setting to `offline` removes the driver immediately — they will not receive new rides. Cannot go offline while a ride is `in_progress`. 

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getDriverApi();
final DriverStatusRequest driverStatusRequest = ; // DriverStatusRequest | 

try {
    final response = api.driverSetStatus(driverStatusRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DriverApi->driverSetStatus: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **driverStatusRequest** | [**DriverStatusRequest**](DriverStatusRequest.md)|  | 

### Return type

[**DriverStatusResponse**](DriverStatusResponse.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **driverUpdateLocation**
> driverUpdateLocation(locationUpdateRequest)

Update driver's current location

Called periodically by the driver app (recommended every 3–5 seconds) while the driver is online. Location is stored in PostGIS and used for geospatial proximity matching.  **Rate limit:** 30 requests/min per driver. Exceeding this returns `429`.  During an active ride, each update also pushes a `driver.location_updated` WebSocket event to the passenger. 

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getDriverApi();
final LocationUpdateRequest locationUpdateRequest = ; // LocationUpdateRequest | 

try {
    api.driverUpdateLocation(locationUpdateRequest);
} on DioException catch (e) {
    print('Exception when calling DriverApi->driverUpdateLocation: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **locationUpdateRequest** | [**LocationUpdateRequest**](LocationUpdateRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)


# sakai_api_client.api.DriverApi

## Load the API package
```dart
import 'package:sakai_api_client/api.dart';
```

All URIs are relative to *http://localhost:8080/api*

Method | HTTP request | Description
------------- | ------------- | -------------
[**driverGetDocumentStatus**](DriverApi.md#drivergetdocumentstatus) | **GET** /drivers/documents/{documentId} | Get status of a specific document
[**driverGetEarnings**](DriverApi.md#drivergetearnings) | **GET** /driver/earnings | Get driver earnings history
[**driverGetIncomingRide**](DriverApi.md#drivergetincomingride) | **GET** /driver/rides/incoming | Get the current pending ride offer for this driver
[**driverListDocuments**](DriverApi.md#driverlistdocuments) | **GET** /drivers/documents | List all uploaded documents for the authenticated driver
[**driverSetStatus**](DriverApi.md#driversetstatus) | **PUT** /driver/status | Set driver online/offline status
[**driverUpdateLocation**](DriverApi.md#driverupdatelocation) | **PUT** /driver/location | Update driver&#39;s current location
[**driverUploadDocument**](DriverApi.md#driveruploaddocument) | **POST** /drivers/documents | Upload a driver verification document
[**getNearbyDrivers**](DriverApi.md#getnearbydrivers) | **GET** /drivers/nearby | Get nearby available drivers by ride type


# **driverGetDocumentStatus**
> DriverDocumentResponse driverGetDocumentStatus(documentId)

Get status of a specific document

Retrieve the status and details of an uploaded document. Only the document owner can access this endpoint. 

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getDriverApi();
final String documentId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | UUID of the document

try {
    final response = api.driverGetDocumentStatus(documentId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DriverApi->driverGetDocumentStatus: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **documentId** | **String**| UUID of the document | 

### Return type

[**DriverDocumentResponse**](DriverDocumentResponse.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **driverGetEarnings**
> DriverGetEarnings200Response driverGetEarnings(from, to, page, limit)

Get driver earnings history

Returns a paginated list of earnings for the authenticated driver. Only `role=driver` may call this. Supports filtering by date range. 

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getDriverApi();
final Date from = 2013-10-20; // Date | Start date (YYYY-MM-DD). Defaults to 30 days ago.
final Date to = 2013-10-20; // Date | End date (YYYY-MM-DD). Defaults to today.
final int page = 56; // int | Page number (1-based)
final int limit = 56; // int | Items per page (max 50)

try {
    final response = api.driverGetEarnings(from, to, page, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DriverApi->driverGetEarnings: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **from** | **Date**| Start date (YYYY-MM-DD). Defaults to 30 days ago. | [optional] 
 **to** | **Date**| End date (YYYY-MM-DD). Defaults to today. | [optional] 
 **page** | **int**| Page number (1-based) | [optional] [default to 1]
 **limit** | **int**| Items per page (max 50) | [optional] [default to 20]

### Return type

[**DriverGetEarnings200Response**](DriverGetEarnings200Response.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

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

# **driverListDocuments**
> DriverDocumentsListResponse driverListDocuments()

List all uploaded documents for the authenticated driver

Returns all documents uploaded by the authenticated driver with their current verification status. 

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getDriverApi();

try {
    final response = api.driverListDocuments();
    print(response);
} on DioException catch (e) {
    print('Exception when calling DriverApi->driverListDocuments: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**DriverDocumentsListResponse**](DriverDocumentsListResponse.md)

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

# **driverUploadDocument**
> DriverDocumentResponse driverUploadDocument(documentType, documentNumber, image, expiryDate)

Upload a driver verification document

Upload a driver verification document (license, registration, or insurance). Requires `role=driver`. Uploaded documents enter `uploaded` status and await admin review. Images must be JPEG or PNG, max 10MB. 

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getDriverApi();
final String documentType = documentType_example; // String | Type of document being uploaded
final String documentNumber = documentNumber_example; // String | Document identifier (license number, registration number, etc.)
final MultipartFile image = BINARY_DATA_HERE; // MultipartFile | Document image file (JPEG/PNG, max 10MB)
final Date expiryDate = 2013-10-20; // Date | Document expiration date (optional)

try {
    final response = api.driverUploadDocument(documentType, documentNumber, image, expiryDate);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DriverApi->driverUploadDocument: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **documentType** | **String**| Type of document being uploaded | 
 **documentNumber** | **String**| Document identifier (license number, registration number, etc.) | 
 **image** | **MultipartFile**| Document image file (JPEG/PNG, max 10MB) | 
 **expiryDate** | **Date**| Document expiration date (optional) | [optional] 

### Return type

[**DriverDocumentResponse**](DriverDocumentResponse.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getNearbyDrivers**
> GetNearbyDrivers200Response getNearbyDrivers(lat, lng, rideType, radiusM)

Get nearby available drivers by ride type

Returns a list of online drivers within the specified radius and vehicle type. Used by the passenger app to show available ride options with driver counts. 

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getDriverApi();
final double lat = 1.2; // double | 
final double lng = 1.2; // double | 
final String rideType = rideType_example; // String | 
final double radiusM = 1.2; // double | 

try {
    final response = api.getNearbyDrivers(lat, lng, rideType, radiusM);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DriverApi->getNearbyDrivers: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **lat** | **double**|  | 
 **lng** | **double**|  | 
 **rideType** | **String**|  | 
 **radiusM** | **double**|  | [optional] [default to 5000]

### Return type

[**GetNearbyDrivers200Response**](GetNearbyDrivers200Response.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)


# sakai_api_client.api.RidesApi

## Load the API package
```dart
import 'package:sakai_api_client/api.dart';
```

All URIs are relative to *http://localhost:8080/api*

Method | HTTP request | Description
------------- | ------------- | -------------
[**addRideTip**](RidesApi.md#addridetip) | **POST** /rides/{rideId}/tip | Add a tip to a completed ride
[**getRideReceipt**](RidesApi.md#getridereceipt) | **GET** /rides/{rideId}/receipt | Get payment receipt for a completed ride
[**paymentProcess**](RidesApi.md#paymentprocess) | **POST** /payments/process | Process a card payment for a completed ride
[**rideAccept**](RidesApi.md#rideaccept) | **POST** /rides/{rideId}/accept | Driver accepts the ride offer
[**rideArrive**](RidesApi.md#ridearrive) | **POST** /rides/{rideId}/arrive | Driver signals arrival at pickup
[**rideCancel**](RidesApi.md#ridecancel) | **POST** /rides/{rideId}/cancel | Cancel an active ride
[**rideComplete**](RidesApi.md#ridecomplete) | **POST** /rides/{rideId}/complete | Driver completes the ride at dropoff
[**rideDecline**](RidesApi.md#ridedecline) | **POST** /rides/{rideId}/decline | Driver declines the ride offer
[**rideGet**](RidesApi.md#rideget) | **GET** /rides/{rideId} | Get ride details by ID
[**rideGetActive**](RidesApi.md#ridegetactive) | **GET** /rides/active | Get the caller&#39;s current active ride
[**rideList**](RidesApi.md#ridelist) | **GET** /rides | List user&#39;s ride history
[**rideRequest**](RidesApi.md#riderequest) | **POST** /rides | Request a new ride
[**rideStart**](RidesApi.md#ridestart) | **POST** /rides/{rideId}/start | Driver starts the ride after passenger boards
[**submitRating**](RidesApi.md#submitrating) | **POST** /rides/{rideId}/rating | Submit a rating for the other party in a ride


# **addRideTip**
> TipResponse addRideTip(rideId, addRideTipRequest)

Add a tip to a completed ride

Add an optional tip to a completed ride's payment. Only the passenger associated with the ride can add a tip. Tips can only be added after ride completion. Maximum tip amount is 50% of base fare. 

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getRidesApi();
final String rideId = d4e5f6a7-b8c9-0123-def4-567890abcdef; // String | UUID of the ride
final AddRideTipRequest addRideTipRequest = ; // AddRideTipRequest | 

try {
    final response = api.addRideTip(rideId, addRideTipRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RidesApi->addRideTip: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **rideId** | **String**| UUID of the ride | 
 **addRideTipRequest** | [**AddRideTipRequest**](AddRideTipRequest.md)|  | 

### Return type

[**TipResponse**](TipResponse.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getRideReceipt**
> ReceiptResponse getRideReceipt(rideId)

Get payment receipt for a completed ride

Retrieve the payment receipt for a completed ride. Accessible by both the passenger and driver associated with the ride. 

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getRidesApi();
final String rideId = d4e5f6a7-b8c9-0123-def4-567890abcdef; // String | UUID of the ride

try {
    final response = api.getRideReceipt(rideId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RidesApi->getRideReceipt: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **rideId** | **String**| UUID of the ride | 

### Return type

[**ReceiptResponse**](ReceiptResponse.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **paymentProcess**
> PaymentResponse paymentProcess(idempotencyKey, paymentProcessRequest)

Process a card payment for a completed ride

Process a card payment using a tokenized payment from the mobile SDK (e.g., Stripe). Requires `Idempotency-Key` header for safe retry handling. Only the passenger associated with the ride can process payment. 

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getRidesApi();
final String idempotencyKey = 550e8400-e29b-41d4-a716-446655440000; // String | Client-generated UUID to prevent duplicate ride creation on retries. Generate once per request attempt and store until a definitive response is received. 
final PaymentProcessRequest paymentProcessRequest = ; // PaymentProcessRequest | 

try {
    final response = api.paymentProcess(idempotencyKey, paymentProcessRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RidesApi->paymentProcess: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| Client-generated UUID to prevent duplicate ride creation on retries. Generate once per request attempt and store until a definitive response is received.  | 
 **paymentProcessRequest** | [**PaymentProcessRequest**](PaymentProcessRequest.md)|  | 

### Return type

[**PaymentResponse**](PaymentResponse.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **rideAccept**
> RideResponse rideAccept(rideId)

Driver accepts the ride offer

Transitions: `requested` → `accepted`. Only the driver currently assigned to this ride may call this. Must be called before `expires_at` from the `ride.requested` WS event — otherwise the offer has already been reassigned and this returns `409`. Triggers: `ride.accepted` WebSocket event → passenger. 

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getRidesApi();
final String rideId = d4e5f6a7-b8c9-0123-def4-567890abcdef; // String | UUID of the ride

try {
    final response = api.rideAccept(rideId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RidesApi->rideAccept: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **rideId** | **String**| UUID of the ride | 

### Return type

[**RideResponse**](RideResponse.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **rideArrive**
> RideResponse rideArrive(rideId)

Driver signals arrival at pickup

Transitions: `accepted` → `arrived`. Triggers: `ride.status_changed` WebSocket event → both parties. 

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getRidesApi();
final String rideId = d4e5f6a7-b8c9-0123-def4-567890abcdef; // String | UUID of the ride

try {
    final response = api.rideArrive(rideId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RidesApi->rideArrive: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **rideId** | **String**| UUID of the ride | 

### Return type

[**RideResponse**](RideResponse.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **rideCancel**
> RideResponse rideCancel(rideId, cancelRequest)

Cancel an active ride

Permitted cancellation states: `requested`, `accepted`, `arrived`. Cancellation is **not permitted** once the ride is `in_progress`. Either the passenger or the assigned driver may cancel. Triggers: `ride.cancelled` WebSocket event → both parties. 

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getRidesApi();
final String rideId = d4e5f6a7-b8c9-0123-def4-567890abcdef; // String | UUID of the ride
final CancelRequest cancelRequest = ; // CancelRequest | 

try {
    final response = api.rideCancel(rideId, cancelRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RidesApi->rideCancel: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **rideId** | **String**| UUID of the ride | 
 **cancelRequest** | [**CancelRequest**](CancelRequest.md)|  | [optional] 

### Return type

[**RideResponse**](RideResponse.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **rideComplete**
> RideResponse rideComplete(rideId)

Driver completes the ride at dropoff

Transitions: `in_progress` → `completed`. Driver status automatically returns to `online` after completion. Triggers: `ride.status_changed` WebSocket event → both parties. 

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getRidesApi();
final String rideId = d4e5f6a7-b8c9-0123-def4-567890abcdef; // String | UUID of the ride

try {
    final response = api.rideComplete(rideId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RidesApi->rideComplete: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **rideId** | **String**| UUID of the ride | 

### Return type

[**RideResponse**](RideResponse.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **rideDecline**
> RideResponse rideDecline(rideId)

Driver declines the ride offer

Transitions: ride returns to `requested` and the matching engine finds another driver. Triggers: `ride.declined` WebSocket event → passenger (informs re-matching is in progress). 

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getRidesApi();
final String rideId = d4e5f6a7-b8c9-0123-def4-567890abcdef; // String | UUID of the ride

try {
    final response = api.rideDecline(rideId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RidesApi->rideDecline: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **rideId** | **String**| UUID of the ride | 

### Return type

[**RideResponse**](RideResponse.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **rideGet**
> RideResponse rideGet(rideId)

Get ride details by ID

Returns current state and full details for the given ride. Both the passenger and the assigned driver may access.

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getRidesApi();
final String rideId = d4e5f6a7-b8c9-0123-def4-567890abcdef; // String | UUID of the ride

try {
    final response = api.rideGet(rideId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RidesApi->rideGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **rideId** | **String**| UUID of the ride | 

### Return type

[**RideResponse**](RideResponse.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **rideGetActive**
> RideResponse rideGetActive()

Get the caller's current active ride

Returns the active ride for the authenticated user — whether they are the passenger or driver. A ride is \"active\" if its status is `requested`, `accepted`, `arrived`, or `in_progress`.  **Call this on app launch / WebSocket reconnect** to re-hydrate local state before subscribing to WebSocket events. Returns `404` if no active ride exists. 

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getRidesApi();

try {
    final response = api.rideGetActive();
    print(response);
} on DioException catch (e) {
    print('Exception when calling RidesApi->rideGetActive: $e\n');
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

# **rideList**
> UserRideListResponse rideList(page, limit, status)

List user's ride history

Returns a paginated list of the authenticated user's past rides. Only `role=passenger` may call this. Supports filtering by status. 

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getRidesApi();
final int page = 56; // int | Page number (1-based)
final int limit = 56; // int | Items per page (max 50)
final String status = status_example; // String | Filter by status (comma-separated): completed,cancelled

try {
    final response = api.rideList(page, limit, status);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RidesApi->rideList: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **page** | **int**| Page number (1-based) | [optional] [default to 1]
 **limit** | **int**| Items per page (max 50) | [optional] [default to 20]
 **status** | **String**| Filter by status (comma-separated): completed,cancelled | [optional] 

### Return type

[**UserRideListResponse**](UserRideListResponse.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **rideRequest**
> RideResponse rideRequest(idempotencyKey, rideRequestBody)

Request a new ride

Creates a ride in `requested` status and triggers the matching engine to find the nearest available driver. Only `role=passenger` may call this.  **Idempotency:** Include a client-generated UUID in the `Idempotency-Key` header. Retries with the same key return the cached response for 24h without creating a duplicate ride. Omitting this header returns `400`.  Returns `503` if no drivers are available within the matching radius. 

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getRidesApi();
final String idempotencyKey = 550e8400-e29b-41d4-a716-446655440000; // String | Client-generated UUID to prevent duplicate ride creation on retries. Generate once per request attempt and store until a definitive response is received. 
final RideRequestBody rideRequestBody = ; // RideRequestBody | 

try {
    final response = api.rideRequest(idempotencyKey, rideRequestBody);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RidesApi->rideRequest: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| Client-generated UUID to prevent duplicate ride creation on retries. Generate once per request attempt and store until a definitive response is received.  | 
 **rideRequestBody** | [**RideRequestBody**](RideRequestBody.md)|  | 

### Return type

[**RideResponse**](RideResponse.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **rideStart**
> RideResponse rideStart(rideId)

Driver starts the ride after passenger boards

Transitions: `arrived` → `in_progress`. Triggers: `ride.status_changed` WebSocket event → both parties. 

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getRidesApi();
final String rideId = d4e5f6a7-b8c9-0123-def4-567890abcdef; // String | UUID of the ride

try {
    final response = api.rideStart(rideId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RidesApi->rideStart: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **rideId** | **String**| UUID of the ride | 

### Return type

[**RideResponse**](RideResponse.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **submitRating**
> RatingResponse submitRating(rideId, submitRatingRequest)

Submit a rating for the other party in a ride

Submit a rating (1-5 stars) with optional written feedback. Each user can rate once per ride. Both passengers and drivers can rate. 

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getRidesApi();
final String rideId = d4e5f6a7-b8c9-0123-def4-567890abcdef; // String | UUID of the ride
final SubmitRatingRequest submitRatingRequest = ; // SubmitRatingRequest | 

try {
    final response = api.submitRating(rideId, submitRatingRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RidesApi->submitRating: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **rideId** | **String**| UUID of the ride | 
 **submitRatingRequest** | [**SubmitRatingRequest**](SubmitRatingRequest.md)|  | 

### Return type

[**RatingResponse**](RatingResponse.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)


# sakai_api_client.api.SystemApi

## Load the API package
```dart
import 'package:sakai_api_client/api.dart';
```

All URIs are relative to *http://localhost:8080/api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**healthCheck**](SystemApi.md#healthcheck) | **GET** /health | Health check


# **healthCheck**
> HealthResponse healthCheck()

Health check

Returns server health. Used by Docker health checks, load balancers, and CI smoke tests. Does not require authentication. 

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getSystemApi();

try {
    final response = api.healthCheck();
    print(response);
} on DioException catch (e) {
    print('Exception when calling SystemApi->healthCheck: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**HealthResponse**](HealthResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)


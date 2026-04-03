# sakai_api_client.api.UsersApi

## Load the API package
```dart
import 'package:sakai_api_client/api.dart';
```

All URIs are relative to *http://localhost:8080/api*

Method | HTTP request | Description
------------- | ------------- | -------------
[**usersGetMe**](UsersApi.md#usersgetme) | **GET** /users/me | Get the authenticated user&#39;s profile


# **usersGetMe**
> UserProfile usersGetMe()

Get the authenticated user's profile

Returns the current user's profile based on the bearer token. Call this on app cold-start after restoring a stored token to re-hydrate session state. For drivers, includes vehicle information. 

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getUsersApi();

try {
    final response = api.usersGetMe();
    print(response);
} on DioException catch (e) {
    print('Exception when calling UsersApi->usersGetMe: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**UserProfile**](UserProfile.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)


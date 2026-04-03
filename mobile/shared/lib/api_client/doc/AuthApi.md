# sakai_api_client.api.AuthApi

## Load the API package
```dart
import 'package:sakai_api_client/api.dart';
```

All URIs are relative to *http://localhost:8080/api*

Method | HTTP request | Description
------------- | ------------- | -------------
[**authLogin**](AuthApi.md#authlogin) | **POST** /auth/login | Login and receive tokens
[**authLogout**](AuthApi.md#authlogout) | **POST** /auth/logout | Logout and invalidate tokens
[**authRefresh**](AuthApi.md#authrefresh) | **POST** /auth/refresh | Refresh the access token
[**authRegister**](AuthApi.md#authregister) | **POST** /auth/register | Register a new user


# **authLogin**
> AuthResponse authLogin(loginRequest)

Login and receive tokens

Returns a short-lived access token and a long-lived refresh token.

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAuthApi();
final LoginRequest loginRequest = ; // LoginRequest | 

try {
    final response = api.authLogin(loginRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->authLogin: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **loginRequest** | [**LoginRequest**](LoginRequest.md)|  | 

### Return type

[**AuthResponse**](AuthResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authLogout**
> authLogout(logoutRequest)

Logout and invalidate tokens

Invalidates the refresh token server-side. The access token will remain technically valid until its expiry — clients should discard it immediately. Call this on explicit user logout. 

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAuthApi();
final LogoutRequest logoutRequest = ; // LogoutRequest | 

try {
    api.authLogout(logoutRequest);
} on DioException catch (e) {
    print('Exception when calling AuthApi->authLogout: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **logoutRequest** | [**LogoutRequest**](LogoutRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authRefresh**
> AuthResponse authRefresh(refreshRequest)

Refresh the access token

Exchanges a valid refresh token for a new access token (and rotated refresh token). Call this silently before the access token expires — typically at 80% of its TTL. Refresh token rotation means the old refresh token is invalidated on use. 

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAuthApi();
final RefreshRequest refreshRequest = ; // RefreshRequest | 

try {
    final response = api.authRefresh(refreshRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->authRefresh: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **refreshRequest** | [**RefreshRequest**](RefreshRequest.md)|  | 

### Return type

[**AuthResponse**](AuthResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authRegister**
> AuthResponse authRegister(registerRequest)

Register a new user

Creates a passenger or driver account. Role is fixed at registration. Returns an access token and refresh token immediately — no separate login needed. 

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getAuthApi();
final RegisterRequest registerRequest = ; // RegisterRequest | 

try {
    final response = api.authRegister(registerRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->authRegister: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **registerRequest** | [**RegisterRequest**](RegisterRequest.md)|  | 

### Return type

[**AuthResponse**](AuthResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)


# sakai_api_client.api.UsersApi

## Load the API package
```dart
import 'package:sakai_api_client/api.dart';
```

All URIs are relative to *http://localhost:8080/api*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getUserRating**](UsersApi.md#getuserrating) | **GET** /users/{userId}/rating | Get average rating for a user
[**paymentMethodsAdd**](UsersApi.md#paymentmethodsadd) | **POST** /users/me/payment-methods | Add a new payment method
[**paymentMethodsList**](UsersApi.md#paymentmethodslist) | **GET** /users/me/payment-methods | List user&#39;s saved payment methods
[**paymentMethodsRemove**](UsersApi.md#paymentmethodsremove) | **DELETE** /users/me/payment-methods/{paymentMethodId} | Remove a payment method
[**paymentMethodsSetDefault**](UsersApi.md#paymentmethodssetdefault) | **PUT** /users/me/payment-methods/{paymentMethodId}/default | Set default payment method
[**usersGetMe**](UsersApi.md#usersgetme) | **GET** /users/me | Get the authenticated user&#39;s profile


# **getUserRating**
> UserRatingResponse getUserRating(userId)

Get average rating for a user

Retrieve the average rating and rating count for any user. Any authenticated user can access this endpoint. 

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getUsersApi();
final String userId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | UUID of the user

try {
    final response = api.getUserRating(userId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling UsersApi->getUserRating: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **String**| UUID of the user | 

### Return type

[**UserRatingResponse**](UserRatingResponse.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **paymentMethodsAdd**
> PaymentMethodDetails paymentMethodsAdd(addPaymentMethodRequest)

Add a new payment method

Adds a new payment method to the user's account. For cards, requires a tokenized payment method ID from the payment gateway (e.g., Stripe). Only `role=passenger` may call this. 

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getUsersApi();
final AddPaymentMethodRequest addPaymentMethodRequest = ; // AddPaymentMethodRequest | 

try {
    final response = api.paymentMethodsAdd(addPaymentMethodRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling UsersApi->paymentMethodsAdd: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **addPaymentMethodRequest** | [**AddPaymentMethodRequest**](AddPaymentMethodRequest.md)|  | 

### Return type

[**PaymentMethodDetails**](PaymentMethodDetails.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **paymentMethodsList**
> PaymentMethodListResponse paymentMethodsList()

List user's saved payment methods

Returns all payment methods saved by the authenticated user. Only `role=passenger` may call this. 

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getUsersApi();

try {
    final response = api.paymentMethodsList();
    print(response);
} on DioException catch (e) {
    print('Exception when calling UsersApi->paymentMethodsList: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**PaymentMethodListResponse**](PaymentMethodListResponse.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **paymentMethodsRemove**
> paymentMethodsRemove(paymentMethodId)

Remove a payment method

Removes a saved payment method. Cannot remove the last payment method. Only `role=passenger` may call this. 

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getUsersApi();
final String paymentMethodId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | ID of the payment method to remove

try {
    api.paymentMethodsRemove(paymentMethodId);
} on DioException catch (e) {
    print('Exception when calling UsersApi->paymentMethodsRemove: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **paymentMethodId** | **String**| ID of the payment method to remove | 

### Return type

void (empty response body)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **paymentMethodsSetDefault**
> PaymentMethodDetails paymentMethodsSetDefault(paymentMethodId)

Set default payment method

Sets a payment method as the default for future rides. Only `role=passenger` may call this. 

### Example
```dart
import 'package:sakai_api_client/api.dart';

final api = SakaiApiClient().getUsersApi();
final String paymentMethodId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | ID of the payment method to set as default

try {
    final response = api.paymentMethodsSetDefault(paymentMethodId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling UsersApi->paymentMethodsSetDefault: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **paymentMethodId** | **String**| ID of the payment method to set as default | 

### Return type

[**PaymentMethodDetails**](PaymentMethodDetails.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

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


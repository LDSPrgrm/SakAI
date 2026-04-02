# sakai_api_client.model.AuthResponse

## Load the model package
```dart
import 'package:sakai_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**accessToken** | **String** | Short-lived JWT (60 min). Include as `Authorization: Bearer <access_token>`.  | 
**refreshToken** | **String** | Long-lived opaque token (30 days). Store securely (e.g., flutter_secure_storage). Use with `POST /auth/refresh` to silently obtain new access tokens. Rotated on every use — old token is invalidated.  | 
**accessTokenExpiresAt** | [**DateTime**](DateTime.md) | UTC expiry of the access token. Refresh before this time. | 
**user** | [**UserProfile**](UserProfile.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)



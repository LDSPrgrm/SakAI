# sakai_api_client.model.AdminUser

## Load the model package
```dart
import 'package:sakai_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | 
**name** | **String** |  | 
**email** | **String** |  | 
**role** | **String** |  | 
**vehicle** | [**VehicleInfo**](VehicleInfo.md) | Present only when `role=driver`. Null for passengers. | [optional] 
**createdAt** | [**DateTime**](DateTime.md) |  | 
**roleId** | **String** |  | [optional] 
**roleName** | **String** |  | [optional] 
**status** | **String** |  | [optional] 
**createdBy** | **String** |  | [optional] 
**lastLoginAt** | [**DateTime**](DateTime.md) |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)



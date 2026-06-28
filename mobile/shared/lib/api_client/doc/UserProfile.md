# sakai_api_client.model.UserProfile

## Load the model package
```dart
import 'package:sakai_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | 
**seq** | **int** |  | [optional] 
**displayId** | **String** | Human-readable reference (e.g. USR-0042). | [optional] 
**name** | **String** |  | 
**email** | **String** |  | 
**role** | **String** |  | 
**vehicle** | [**VehicleInfo**](VehicleInfo.md) | Present only when `role=driver`. Null for passengers. | [optional] 
**createdAt** | [**DateTime**](DateTime.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)



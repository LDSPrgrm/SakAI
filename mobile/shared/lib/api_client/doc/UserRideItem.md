# sakai_api_client.model.UserRideItem

## Load the model package
```dart
import 'package:sakai_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | 
**status** | [**RideStatus**](RideStatus.md) |  | 
**originAddress** | **String** |  | 
**destinationAddress** | **String** |  | 
**fare** | **double** | Final fare (null if not completed) | [optional] 
**estimatedFare** | **double** |  | [optional] 
**driver** | [**DriverSummary**](DriverSummary.md) |  | [optional] 
**paymentMethod** | **String** |  | 
**createdAt** | [**DateTime**](DateTime.md) |  | 
**updatedAt** | [**DateTime**](DateTime.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)



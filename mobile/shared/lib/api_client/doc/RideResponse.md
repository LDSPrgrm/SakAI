# sakai_api_client.model.RideResponse

## Load the model package
```dart
import 'package:sakai_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | 
**status** | [**RideStatus**](RideStatus.md) |  | 
**passenger** | [**UserProfile**](UserProfile.md) |  | 
**driver** | [**DriverSummary**](DriverSummary.md) | Null until a driver is matched and accepts. | [optional] 
**origin** | [**LatLng**](LatLng.md) |  | 
**destination** | [**LatLng**](LatLng.md) |  | 
**originAddress** | **String** |  | [optional] 
**destinationAddress** | **String** |  | [optional] 
**notes** | **String** |  | [optional] 
**fare** | **double** | Final fare amount (null if ride not completed) | [optional] 
**estimatedFare** | **double** | Estimated fare at request time | [optional] 
**actualFare** | **double** | Actual fare after completion | [optional] 
**fareBreakdown** | [**BuiltMap&lt;String, JsonObject&gt;**](JsonObject.md) | JSONB breakdown of fare components | [optional] 
**rideType** | **String** | Vehicle type for this ride | [optional] 
**paymentMethod** | **String** | Payment method used for ride | [optional] 
**cancelledBy** | **String** | Set only when status is `cancelled` | [optional] 
**cancellationReason** | **String** | Predefined cancellation reason code | [optional] 
**cancellationReasonText** | **String** | Free-text cancellation reason | [optional] 
**createdAt** | [**DateTime**](DateTime.md) |  | 
**updatedAt** | [**DateTime**](DateTime.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)



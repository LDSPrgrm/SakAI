# sakai_api_client.model.RideRequestBody

## Load the model package
```dart
import 'package:sakai_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**origin** | [**LatLng**](LatLng.md) |  | 
**destination** | [**LatLng**](LatLng.md) |  | 
**originAddress** | **String** | Human-readable pickup address (for display only) | [optional] 
**destinationAddress** | **String** | Human-readable dropoff address (for display only) | [optional] 
**notes** | **String** | Optional instructions for the driver | [optional] 
**rideType** | **String** | Passenger's selected vehicle type | [default to 'car']
**paymentMethod** | **String** | Payment method for this ride | [optional] [default to 'cash']

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)



# sakai_api_client.model.WsEventRideRequested

## Load the model package
```dart
import 'package:sakai_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**rideId** | **String** |  | 
**passenger** | [**UserProfile**](UserProfile.md) |  | 
**origin** | [**LatLng**](LatLng.md) |  | 
**destination** | [**LatLng**](LatLng.md) |  | 
**originAddress** | **String** |  | [optional] 
**destinationAddress** | **String** |  | [optional] 
**notes** | **String** |  | [optional] 
**expiresAt** | [**DateTime**](DateTime.md) | Deadline to accept/decline. Driver UI should display a countdown. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)



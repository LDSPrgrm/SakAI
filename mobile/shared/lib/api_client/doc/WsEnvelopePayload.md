# sakai_api_client.model.WsEnvelopePayload

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
**driver** | [**DriverSummary**](DriverSummary.md) |  | 
**message** | **String** |  | [optional] 
**status** | [**RideStatus**](RideStatus.md) |  | 
**updatedAt** | [**DateTime**](DateTime.md) |  | 
**fare** | **double** | Total fare charged to the passenger in PHP. | 
**fareBreakdown** | [**FareBreakdown**](FareBreakdown.md) |  | [optional] 
**paymentMethod** | **String** |  | 
**tipAmount** | **double** | Driver tip in PHP, when one was already received. | [optional] 
**completedAt** | [**DateTime**](DateTime.md) |  | 
**cancelledBy** | **String** |  | 
**reason** | **String** | Free-text reason the trigger user supplied. | [optional] 
**incidentId** | **String** |  | 
**triggeredBy** | **String** |  | 
**hasActiveRide** | **bool** |  | 
**driverId** | **String** |  | [optional] 
**passengerId** | **String** |  | [optional] 
**assigneeId** | **String** |  | [optional] 
**assigneeName** | **String** | Display name of the assignee. Optional — publishers populate it only when the value can be resolved cheaply.  | [optional] 
**assignedAt** | [**DateTime**](DateTime.md) |  | 
**resolutionNotes** | **String** | Operator notes. May be redacted before send. | [optional] 
**resolvedAt** | [**DateTime**](DateTime.md) |  | 
**location** | [**LatLng**](LatLng.md) |  | 
**heading** | **double** | Compass heading in degrees (0–360). Use to rotate driver icon. | [optional] 
**protocol** | **String** | Negotiated WebSocket subprotocol. Empty string for v1 clients, `\"sakai.v2\"` for v2.  | [optional] 
**v** | **int** | Envelope protocol version supported by the server. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)



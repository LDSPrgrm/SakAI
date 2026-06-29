# sakai_api_client.model.Incident

## Load the model package
```dart
import 'package:sakai_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | [optional] 
**seq** | **int** | Postgres-assigned monotonic counter; the source for display_id. | [optional] 
**displayId** | **String** | Human-readable reference (e.g. INC-0042) derived from seq. | [optional] 
**rideId** | **String** |  | [optional] 
**rideDisplayId** | **String** | Human-readable reference for the linked ride (e.g. RIDE-000123). | [optional] 
**type** | **String** |  | [optional] 
**severity** | **String** | Operator-assigned urgency level | [optional] 
**status** | **String** |  | [optional] 
**triggeredBy** | **String** |  | [optional] 
**riderId** | **String** |  | [optional] 
**riderName** | **String** |  | [optional] 
**driverId** | **String** |  | [optional] 
**driverName** | **String** |  | [optional] 
**assignedTo** | **String** |  | [optional] 
**assignedToName** | **String** | Display name of the assignee user, resolved via JOIN. Empty when unassigned. | [optional] 
**createdAt** | [**DateTime**](DateTime.md) |  | [optional] 
**resolvedAt** | [**DateTime**](DateTime.md) |  | [optional] 
**resolutionNotes** | **String** |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)



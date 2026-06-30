# sakai_api_client.model.IncidentDetail

## Load the model package
```dart
import 'package:sakai_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**incident** | [**Incident**](Incident.md) |  | 
**statusHistory** | [**BuiltList&lt;IncidentStatusEvent&gt;**](IncidentStatusEvent.md) |  | 
**locationTrail** | [**BuiltList&lt;IncidentLocationPoint&gt;**](IncidentLocationPoint.md) | GPS pings captured during the incident's active window (between created_at and resolved_at). Populated by the driver_location_history write-path while the driver has an unresolved incident; empty when no pings were recorded.  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)



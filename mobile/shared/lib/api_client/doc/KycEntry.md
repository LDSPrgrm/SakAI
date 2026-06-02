# sakai_api_client.model.KycEntry

## Load the model package
```dart
import 'package:sakai_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | [optional] 
**driverId** | **String** |  | [optional] 
**driverDisplayId** | **String** | Human-readable reference for the driver user (e.g. USR-0042), resolved server-side via JOIN. Empty when the user row is missing. | [optional] 
**driverName** | **String** |  | [optional] 
**submittedAt** | [**DateTime**](DateTime.md) |  | [optional] 
**docs** | [**BuiltList&lt;KycDocument&gt;**](KycDocument.md) |  | [optional] 
**status** | **String** |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)



# sakai_api_client.model.AuditLog

## Load the model package
```dart
import 'package:sakai_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | [optional] 
**seq** | **int** |  | [optional] 
**displayId** | **String** | Human-readable reference (e.g. AUD-0042). | [optional] 
**timestamp** | [**DateTime**](DateTime.md) |  | [optional] 
**actorId** | **String** |  | [optional] 
**actorDisplayId** | **String** | Human-readable reference for the actor user (e.g. USR-0042). | [optional] 
**actorName** | **String** | Display name of the actor user, resolved server-side via JOIN. Empty when the actor is missing or anonymous. | [optional] 
**ipAddress** | **String** |  | [optional] 
**action** | **String** |  | [optional] 
**resourceType** | **String** |  | [optional] 
**resourceId** | **String** |  | [optional] 
**beforeState** | [**BuiltMap&lt;String, JsonObject&gt;**](JsonObject.md) |  | [optional] 
**afterState** | [**BuiltMap&lt;String, JsonObject&gt;**](JsonObject.md) |  | [optional] 
**reason** | **String** |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)



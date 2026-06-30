# sakai_api_client.model.SurgeConfig

## Load the model package
```dart
import 'package:sakai_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | [optional] 
**enabled** | **bool** |  | [optional] 
**maxMultiplier** | **num** |  | [optional] 
**triggerRatio** | **num** |  | [optional] 
**zones** | [**BuiltList&lt;SurgeZone&gt;**](SurgeZone.md) | Named polygons with per-zone multipliers. The fare calculator does origin-in-polygon (ray-casting) against this list during SimulateFare; falls back to max_multiplier when no zone matches.  | [optional] 
**blackoutHours** | [**BuiltList&lt;BlackoutHour&gt;**](BlackoutHour.md) |  | [optional] 
**updatedAt** | [**DateTime**](DateTime.md) |  | [optional] 
**updatedBy** | **String** |  | [optional] 
**updatedByName** | **String** | Admin display name resolved via LEFT JOIN users on updated_by. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)



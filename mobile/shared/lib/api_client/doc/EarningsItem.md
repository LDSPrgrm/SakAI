# sakai_api_client.model.EarningsItem

## Load the model package
```dart
import 'package:sakai_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | 
**rideId** | **String** |  | 
**fareAmount** | **double** | Driver's share of the fare (before commission) | 
**tipAmount** | **double** | Tip amount (0 if no tip) | 
**totalAmount** | **double** | Total earnings for this ride (fare + tip) | 
**currency** | **String** | ISO 4217 currency code | [optional] [default to 'USD']
**completedAt** | [**DateTime**](DateTime.md) | When the ride was completed | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)



# sakai_api_client.model.PaymentResponse

## Load the model package
```dart
import 'package:sakai_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | 
**rideId** | **String** |  | 
**amount** | **double** |  | 
**currency** | **String** |  | 
**method** | [**PaymentMethod**](PaymentMethod.md) |  | 
**status** | [**PaymentStatus**](PaymentStatus.md) |  | 
**gatewayTransactionId** | **String** | External payment gateway reference (e.g., Stripe PaymentIntent ID) | [optional] 
**failureReason** | **String** | Error message or code when payment fails | [optional] 
**processedAt** | [**DateTime**](DateTime.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)



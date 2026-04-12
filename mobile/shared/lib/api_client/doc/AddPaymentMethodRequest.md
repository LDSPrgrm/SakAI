# sakai_api_client.model.AddPaymentMethodRequest

## Load the model package
```dart
import 'package:sakai_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**type** | [**PaymentMethodType**](PaymentMethodType.md) |  | 
**cardToken** | **String** | Payment gateway token for card (required if type == \"card\") | [optional] 
**provider** | **String** | E-wallet provider name (required if type == \"e_wallet\") | [optional] 
**accountId** | **String** | E-wallet account ID (required if type == \"e_wallet\") | [optional] 
**setAsDefault** | **bool** | Set as default payment method | [optional] [default to false]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)



# sakai_api_client.model.PaymentMethodDetails

## Load the model package
```dart
import 'package:sakai_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | 
**type** | [**PaymentMethodType**](PaymentMethodType.md) |  | 
**isDefault** | **bool** | Whether this is the default payment method | 
**createdAt** | [**DateTime**](DateTime.md) |  | 
**card** | [**CardDetails**](CardDetails.md) | Present only if type == \"card\" | [optional] 
**eWallet** | [**EWalletDetails**](EWalletDetails.md) | Present only if type == \"e_wallet\" | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)



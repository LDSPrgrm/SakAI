# sakai_api_client.model.Role

## Load the model package
```dart
import 'package:sakai_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | 
**name** | **String** |  | 
**description** | **String** |  | [optional] 
**isSystem** | **bool** | True for built-in roles that cannot be deleted | [optional] 
**permissions** | [**BuiltList&lt;RolePermission&gt;**](RolePermission.md) |  | 
**adminCount** | **int** | Number of active admins with this role | [optional] 
**createdBy** | **String** |  | [optional] 
**createdAt** | [**DateTime**](DateTime.md) |  | [optional] 
**updatedAt** | [**DateTime**](DateTime.md) |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)



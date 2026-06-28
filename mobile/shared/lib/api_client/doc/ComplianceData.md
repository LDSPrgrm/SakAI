# sakai_api_client.model.ComplianceData

## Load the model package
```dart
import 'package:sakai_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**accreditationStatus** | **String** |  | [optional] 
**accreditationExpiry** | [**DateTime**](DateTime.md) |  | [optional] 
**driverComplianceRate** | **num** | Percentage of drivers with valid documents (0–100) | [optional] 
**violationCount** | **int** | LTFRB-reportable violations in current period (alias of violations_open) | [optional] 
**violationsOpen** | **int** | Count of open regulatory violations | [optional] 
**violationsResolved** | **int** | Count of resolved regulatory violations in current period | [optional] 
**lastAuditAt** | [**DateTime**](DateTime.md) | Timestamp of the last LTFRB audit, null if never audited | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)



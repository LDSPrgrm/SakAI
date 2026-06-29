# sakai_api_client.model.InfraMetrics

## Load the model package
```dart
import 'package:sakai_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**apiP50Ms** | **num** | HTTP request latency p50 over window_minutes | [optional] 
**apiP95Ms** | **num** | HTTP request latency p95 over window_minutes | [optional] 
**wsConnections** | **int** | Current connected WebSocket client count from latest probe | [optional] 
**dbQueryP99Ms** | **num** | Database probe latency p99 over last 24h | [optional] 
**sampleCount** | **int** | Number of HTTP samples contributing to p50/p95 | [optional] 
**windowMinutes** | **int** | Size of the rolling window used for HTTP percentiles | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)



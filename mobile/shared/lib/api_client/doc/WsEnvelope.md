# sakai_api_client.model.WsEnvelope

## Load the model package
```dart
import 'package:sakai_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**event** | [**WsEventType**](WsEventType.md) |  | 
**payload** | [**WsEnvelopePayload**](WsEnvelopePayload.md) |  | 
**timestamp** | [**DateTime**](DateTime.md) | RFC3339 UTC timestamp stamped by the server. Optional for backward compatibility — older servers omit it.  | [optional] 
**eventId** | **String** | UUIDv7 stamped by the server. Enables client-side idempotency. Optional for backward compatibility.  | [optional] 
**v** | **int** | Envelope protocol version. Present only when the client negotiated the `sakai.v2` subprotocol. RFC v2 §4.1.  | [optional] 
**seq** | **int** | Monotonic per-user sequence number. Clients use this to detect gaps and request replay. v2-only. RFC v2 §4.2.  | [optional] 
**corrId** | **String** | Correlation ID propagated from the originating HTTP request (or internal job). Lets clients/operators link a UI event back to the API call that produced it. v2-only. RFC v2 §4.3 / §12.4.  | [optional] 
**ackRequired** | **bool** | When true, the client must emit `{type:\"ack\", event_id}` after applying the event. Set for critical events (ride.requested, ride.accepted, ride.completed, …). RFC v2 §4.4.  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)



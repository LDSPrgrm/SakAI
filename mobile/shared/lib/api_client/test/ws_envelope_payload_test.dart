import 'package:test/test.dart';
import 'package:sakai_api_client/sakai_api_client.dart';

// tests for WsEnvelopePayload
void main() {
  final instance = WsEnvelopePayloadBuilder();
  // TODO add properties to the builder and call build()

  group(WsEnvelopePayload, () {
    // String rideId
    test('to test the property `rideId`', () async {
      // TODO
    });

    // UserProfile passenger
    test('to test the property `passenger`', () async {
      // TODO
    });

    // LatLng origin
    test('to test the property `origin`', () async {
      // TODO
    });

    // LatLng destination
    test('to test the property `destination`', () async {
      // TODO
    });

    // String originAddress
    test('to test the property `originAddress`', () async {
      // TODO
    });

    // String destinationAddress
    test('to test the property `destinationAddress`', () async {
      // TODO
    });

    // String notes
    test('to test the property `notes`', () async {
      // TODO
    });

    // Deadline to accept/decline. Driver UI should display a countdown.
    // DateTime expiresAt
    test('to test the property `expiresAt`', () async {
      // TODO
    });

    // DriverSummary driver
    test('to test the property `driver`', () async {
      // TODO
    });

    // String message
    test('to test the property `message`', () async {
      // TODO
    });

    // RideStatus status
    test('to test the property `status`', () async {
      // TODO
    });

    // DateTime updatedAt
    test('to test the property `updatedAt`', () async {
      // TODO
    });

    // Total fare charged to the passenger in PHP.
    // double fare
    test('to test the property `fare`', () async {
      // TODO
    });

    // FareBreakdown fareBreakdown
    test('to test the property `fareBreakdown`', () async {
      // TODO
    });

    // String paymentMethod
    test('to test the property `paymentMethod`', () async {
      // TODO
    });

    // Driver tip in PHP, when one was already received.
    // double tipAmount
    test('to test the property `tipAmount`', () async {
      // TODO
    });

    // DateTime completedAt
    test('to test the property `completedAt`', () async {
      // TODO
    });

    // String cancelledBy
    test('to test the property `cancelledBy`', () async {
      // TODO
    });

    // Free-text reason the trigger user supplied.
    // String reason
    test('to test the property `reason`', () async {
      // TODO
    });

    // String incidentId
    test('to test the property `incidentId`', () async {
      // TODO
    });

    // String triggeredBy
    test('to test the property `triggeredBy`', () async {
      // TODO
    });

    // bool hasActiveRide
    test('to test the property `hasActiveRide`', () async {
      // TODO
    });

    // String driverId
    test('to test the property `driverId`', () async {
      // TODO
    });

    // String passengerId
    test('to test the property `passengerId`', () async {
      // TODO
    });

    // String assigneeId
    test('to test the property `assigneeId`', () async {
      // TODO
    });

    // Display name of the assignee. Optional — publishers populate it only when the value can be resolved cheaply. 
    // String assigneeName
    test('to test the property `assigneeName`', () async {
      // TODO
    });

    // DateTime assignedAt
    test('to test the property `assignedAt`', () async {
      // TODO
    });

    // Operator notes. May be redacted before send.
    // String resolutionNotes
    test('to test the property `resolutionNotes`', () async {
      // TODO
    });

    // DateTime resolvedAt
    test('to test the property `resolvedAt`', () async {
      // TODO
    });

    // LatLng location
    test('to test the property `location`', () async {
      // TODO
    });

    // Compass heading in degrees (0–360). Use to rotate driver icon.
    // double heading
    test('to test the property `heading`', () async {
      // TODO
    });

    // Negotiated WebSocket subprotocol. Empty string for v1 clients, `\"sakai.v2\"` for v2. 
    // String protocol
    test('to test the property `protocol`', () async {
      // TODO
    });

    // Envelope protocol version supported by the server.
    // int v
    test('to test the property `v`', () async {
      // TODO
    });

  });
}

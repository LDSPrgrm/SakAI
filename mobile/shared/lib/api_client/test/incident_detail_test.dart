import 'package:test/test.dart';
import 'package:sakai_api_client/sakai_api_client.dart';

// tests for IncidentDetail
void main() {
  final instance = IncidentDetailBuilder();
  // TODO add properties to the builder and call build()

  group(IncidentDetail, () {
    // Incident incident
    test('to test the property `incident`', () async {
      // TODO
    });

    // BuiltList<IncidentStatusEvent> statusHistory
    test('to test the property `statusHistory`', () async {
      // TODO
    });

    // GPS pings captured during the incident's active window (between created_at and resolved_at). Populated by the driver_location_history write-path while the driver has an unresolved incident; empty when no pings were recorded. 
    // BuiltList<IncidentLocationPoint> locationTrail
    test('to test the property `locationTrail`', () async {
      // TODO
    });

  });
}

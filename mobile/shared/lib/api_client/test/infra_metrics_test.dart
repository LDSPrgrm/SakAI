import 'package:test/test.dart';
import 'package:sakai_api_client/sakai_api_client.dart';

// tests for InfraMetrics
void main() {
  final instance = InfraMetricsBuilder();
  // TODO add properties to the builder and call build()

  group(InfraMetrics, () {
    // HTTP request latency p50 over window_minutes
    // num apiP50Ms
    test('to test the property `apiP50Ms`', () async {
      // TODO
    });

    // HTTP request latency p95 over window_minutes
    // num apiP95Ms
    test('to test the property `apiP95Ms`', () async {
      // TODO
    });

    // Current connected WebSocket client count from latest probe
    // int wsConnections
    test('to test the property `wsConnections`', () async {
      // TODO
    });

    // Database probe latency p99 over last 24h
    // num dbQueryP99Ms
    test('to test the property `dbQueryP99Ms`', () async {
      // TODO
    });

    // Number of HTTP samples contributing to p50/p95
    // int sampleCount
    test('to test the property `sampleCount`', () async {
      // TODO
    });

    // Size of the rolling window used for HTTP percentiles
    // int windowMinutes
    test('to test the property `windowMinutes`', () async {
      // TODO
    });

  });
}

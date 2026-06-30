import 'package:test/test.dart';
import 'package:sakai_api_client/sakai_api_client.dart';

// tests for KycDocument
void main() {
  final instance = KycDocumentBuilder();
  // TODO add properties to the builder and call build()

  group(KycDocument, () {
    // Machine-readable document type (e.g. drivers_license, vehicle_registration, insurance).
    // String type
    test('to test the property `type`', () async {
      // TODO
    });

    // Human-readable name displayed in the UI.
    // String label
    test('to test the property `label`', () async {
      // TODO
    });

    // Signed URL to the uploaded image/PDF. Absent when not yet uploaded.
    // String url
    test('to test the property `url`', () async {
      // TODO
    });

  });
}

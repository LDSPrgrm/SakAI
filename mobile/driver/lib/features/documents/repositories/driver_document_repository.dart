import 'package:sakai_api_client/sakai_api_client.dart';

/// Repository interface for driver document management.
abstract class DriverDocumentRepository {
  /// Lists all documents uploaded by the authenticated driver.
  Future<List<DriverDocumentResponse>> listDocuments();

  /// Uploads a new document image.
  Future<DriverDocumentResponse> uploadDocument({
    required String documentType,
    required String documentNumber,
    required String imagePath,
    DateTime? expiryDate,
  });

  /// Retrieves the status of a specific document.
  Future<DriverDocumentResponse> getDocumentStatus(String documentId);
}

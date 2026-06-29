import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sakai_api_client/sakai_api_client.dart';
import 'package:http_parser/http_parser.dart';
import 'driver_document_repository.dart';

class DriverDocumentRepositoryImpl implements DriverDocumentRepository {
  final SakaiApiClient _apiClient;

  DriverDocumentRepositoryImpl(this._apiClient);

  @override
  Future<List<DriverDocumentResponse>> listDocuments() async {
    try {
      final response = await _apiClient.getDriverApi().driverListDocuments();
      return response.data?.documents.toList() ?? [];
    } on DioException catch (e) {
      debugPrint('[DOC_REPO] listDocuments failed: ${e.response?.statusCode} ${e.message}');
      throw _fromDio(e);
    }
  }

  @override
  Future<DriverDocumentResponse> uploadDocument({
    required String documentType,
    required String documentNumber,
    required String imagePath,
    DateTime? expiryDate,
  }) async {
    try {
      final fileName = imagePath.split('/').last;
      final imageFile = await MultipartFile.fromFile(
        imagePath,
        filename: fileName,
        contentType: MediaType('image', fileName.endsWith('png') ? 'png' : 'jpeg'),
      );

      final response = await _apiClient.getDriverApi().driverUploadDocument(
        documentType: documentType,
        documentNumber: documentNumber,
        image: imageFile,
        expiryDate: expiryDate?.toDate(),
      );

      if (response.data == null) {
        throw Exception('Upload failed: Empty response');
      }

      return response.data!;
    } on DioException catch (e) {
      debugPrint('[DOC_REPO] uploadDocument failed: ${e.response?.statusCode} ${e.message}');
      throw _fromDio(e);
    }
  }

  @override
  Future<DriverDocumentResponse> getDocumentStatus(String documentId) async {
    try {
      final response = await _apiClient.getDriverApi().driverGetDocumentStatus(
        documentId: documentId,
      );
      if (response.data == null) {
        throw Exception('Get status failed: Empty response');
      }
      return response.data!;
    } on DioException catch (e) {
      debugPrint('[DOC_REPO] getDocumentStatus failed: ${e.response?.statusCode} ${e.message}');
      throw _fromDio(e);
    }
  }

  Exception _fromDio(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'] as String?;
      if (message != null && message.isNotEmpty) {
        return Exception(message);
      }
    }
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return Exception('No connection. Check network or server URL.');
    }
    return Exception(e.message ?? 'Something went wrong. Try again.');
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sakai_api_client/sakai_api_client.dart';
import 'package:driver/features/documents/repositories/driver_document_repository_impl.dart';
import 'package:dio/dio.dart';
import 'dart:io';

import 'driver_document_repository_test.mocks.dart';

@GenerateNiceMocks([MockSpec<SakaiApiClient>(), MockSpec<DriverApi>()])
void main() {
  late SakaiApiClient mockClient;
  late MockDriverApi mockDriverApi;
  late DriverDocumentRepositoryImpl repository;

  setUpAll(() {
    provideDummy<MultipartFile>(MultipartFile.fromBytes([]));
  });

  setUp(() {
    mockClient = MockSakaiApiClient();
    mockDriverApi = MockDriverApi();
    repository = DriverDocumentRepositoryImpl(mockClient);

    when(mockClient.getDriverApi()).thenReturn(mockDriverApi);
  });

  group('DriverDocumentRepository.listDocuments', () {
    test('returns list of documents on success', () async {
      final mockResponse = DriverDocumentsListResponse(
        (b) => b
          ..documents.addAll([
            DriverDocumentResponse(
              (b) => b
                ..id = '1'
                ..driverId = 'driver1'
                ..documentType = DocumentType.license
                ..documentNumber = 'DL12345'
                ..imageUrl = 'http://example.com/image.jpg'
                ..uploadStatus = UploadStatus.approved
                ..uploadedAt = DateTime.now().toUtc(),
            ),
          ]),
      );

      when(mockDriverApi.driverListDocuments()).thenAnswer(
        (_) async => Response(
          data: mockResponse,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final result = await repository.listDocuments();

      expect(result.length, 1);
      expect(result.first.id, '1');
      expect(result.first.documentType, DocumentType.license);
      verify(mockDriverApi.driverListDocuments()).called(1);
    });

    test('throws Exception on API error', () async {
      when(mockDriverApi.driverListDocuments()).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            statusCode: 401,
            data: {'message': 'Unauthorized'},
            requestOptions: RequestOptions(path: ''),
          ),
        ),
      );

      expect(() => repository.listDocuments(), throwsException);
    });
  });

  group('DriverDocumentRepository.uploadDocument', () {
    test('calls upload API and returns document on success', () async {
      final mockDoc = DriverDocumentResponse(
        (b) => b
          ..id = '2'
          ..driverId = 'driver1'
          ..documentType = DocumentType.registration
          ..documentNumber = 'REG5678'
          ..imageUrl = 'http://example.com/image2.jpg'
          ..uploadStatus = UploadStatus.underReview
          ..uploadedAt = DateTime.now().toUtc(),
      );

      when(
        mockDriverApi.driverUploadDocument(
          documentType: anyNamed('documentType'),
          documentNumber: anyNamed('documentNumber'),
          image: anyNamed('image'),
          expiryDate: anyNamed('expiryDate'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: mockDoc,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final file = File('test_image.jpg');
      await file.writeAsBytes([0, 1, 2]);

      try {
        final result = await repository.uploadDocument(
          documentType: 'registration',
          documentNumber: 'REG5678',
          imagePath: file.path,
        );

        expect(result.id, equals('2'));
        expect(result.documentType, equals(DocumentType.registration));
      } finally {
        if (await file.exists()) await file.delete();
      }
    });
  });

  group('DriverDocumentRepository.getDocumentStatus', () {
    test('returns document on success', () async {
      final mockDoc = DriverDocumentResponse(
        (b) => b
          ..id = '1'
          ..driverId = 'driver1'
          ..documentType = DocumentType.license
          ..documentNumber = 'DL12345'
          ..imageUrl = 'http://example.com/image.jpg'
          ..uploadStatus = UploadStatus.approved
          ..uploadedAt = DateTime.now().toUtc(),
      );

      when(
        mockDriverApi.driverGetDocumentStatus(
          documentId: anyNamed('documentId'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: mockDoc,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final result = await repository.getDocumentStatus('1');

      expect(result.id, equals('1'));
      expect(result.uploadStatus, equals(UploadStatus.approved));
    });
  });
}

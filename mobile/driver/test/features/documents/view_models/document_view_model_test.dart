import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sakai_api_client/sakai_api_client.dart';
import 'package:driver/features/documents/repositories/driver_document_repository.dart';
import 'package:driver/features/documents/view_models/document_view_model.dart';
import 'package:driver/app/providers.dart';

import 'document_view_model_test.mocks.dart';

@GenerateMocks([DriverDocumentRepository])
void main() {
  late MockDriverDocumentRepository mockRepository;

  setUp(() {
    mockRepository = MockDriverDocumentRepository();
    // Default stub for initial fetch triggered by build()
    when(mockRepository.listDocuments()).thenAnswer((_) async => []);
  });

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        driverDocumentRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('DocumentState', () {
    test('copyWith updates fields correctly', () {
      const state = DocumentState(
        documents: [],
        isLoading: false,
        isUploading: false,
        errorMessage: 'Initial Error',
        successMessage: 'Initial Success',
      );

      final updated = state.copyWith(
        isLoading: true,
        errorMessage: 'New Error',
      );

      expect(updated.isLoading, true);
      expect(updated.errorMessage, 'New Error');
      expect(updated.successMessage, 'Initial Success');
    });

    test('copyWith clearError and clearSuccess work', () {
      const state = DocumentState(
        errorMessage: 'Error',
        successMessage: 'Success',
      );

      final cleared = state.copyWith(clearError: true, clearSuccess: true);

      expect(cleared.errorMessage, isNull);
      expect(cleared.successMessage, isNull);
    });

    test('copyWith prioritizes clear flags over new values', () {
      const state = DocumentState(errorMessage: 'Old Error');

      final result = state.copyWith(
        errorMessage: 'New Error',
        clearError: true,
      );

      expect(result.errorMessage, isNull);
    });
  });

  group('DocumentViewModel', () {
    test('initial state is correct and fetchDocuments is called', () async {
      when(mockRepository.listDocuments()).thenAnswer((_) async => []);

      final container = createContainer();
      final state = container.read(documentViewModelProvider);

      expect(state.isLoading, false);
      expect(state.documents, isEmpty);

      // fetchDocuments is called in build via Future.microtask
      await Future.delayed(Duration.zero);
      verify(mockRepository.listDocuments()).called(1);
    });

    test('fetchDocuments successfully updates state and clears error', () async {
      final doc = DriverDocumentResponse((b) => b
        ..id = '1'
        ..driverId = 'driver-1'
        ..documentType = DocumentType.license
        ..imageUrl = 'http://example.com/image.jpg'
        ..uploadStatus = UploadStatus.underReview
        ..documentNumber = 'ABC123'
        ..uploadedAt = DateTime.now());

      when(mockRepository.listDocuments()).thenAnswer((_) async => [doc]);

      final container = createContainer();
      final notifier = container.read(documentViewModelProvider.notifier);
      
      // Set an initial error
      when(mockRepository.listDocuments()).thenThrow(Exception('Fail 1'));
      await notifier.fetchDocuments();
      expect(container.read(documentViewModelProvider).errorMessage, 'Fail 1');

      // Now fetch successfully
      when(mockRepository.listDocuments()).thenAnswer((_) async => [doc]);
      await notifier.fetchDocuments();

      final state = container.read(documentViewModelProvider);
      expect(state.documents.length, 1);
      expect(state.errorMessage, isNull);
      expect(state.isLoading, false);
    });

    test('uploadDocument clears previous messages', () async {
      final doc = DriverDocumentResponse((b) => b
        ..id = '1'
        ..driverId = 'driver-1'
        ..documentType = DocumentType.license
        ..imageUrl = 'http://example.com/image.jpg'
        ..uploadStatus = UploadStatus.underReview
        ..documentNumber = 'ABC123'
        ..uploadedAt = DateTime.now());

      when(mockRepository.uploadDocument(
        documentType: anyNamed('documentType'),
        documentNumber: anyNamed('documentNumber'),
        imagePath: anyNamed('imagePath'),
        expiryDate: anyNamed('expiryDate'),
      )).thenAnswer((_) async => doc);

      when(mockRepository.listDocuments()).thenAnswer((_) async => [doc]);

      final container = createContainer();
      final notifier = container.read(documentViewModelProvider.notifier);
      await Future.delayed(Duration.zero); // Ensure initial fetch finishes

      // Set initial messages by failing once
      when(mockRepository.uploadDocument(
        documentType: anyNamed('documentType'),
        documentNumber: anyNamed('documentNumber'),
        imagePath: anyNamed('imagePath'),
        expiryDate: anyNamed('expiryDate'),
      )).thenThrow(Exception('Initial Error'));
      
      await notifier.uploadDocument(
        documentType: 'license',
        documentNumber: 'ABC123',
        imagePath: 'path',
      );
      expect(container.read(documentViewModelProvider).errorMessage, 'Initial Error');

      // Successful upload
      when(mockRepository.uploadDocument(
        documentType: anyNamed('documentType'),
        documentNumber: anyNamed('documentNumber'),
        imagePath: anyNamed('imagePath'),
        expiryDate: anyNamed('expiryDate'),
      )).thenAnswer((_) async => doc);

      await notifier.uploadDocument(
        documentType: 'license',
        documentNumber: 'ABC123',
        imagePath: 'path',
      );

      final state = container.read(documentViewModelProvider);
      expect(state.errorMessage, isNull);
      expect(state.successMessage, contains('successfully'));
    });

    test('clearMessages clears messages', () async {
      final container = createContainer();
      final notifier = container.read(documentViewModelProvider.notifier);
      
      // Induce an error
      when(mockRepository.listDocuments()).thenThrow(Exception('Error'));
      await notifier.fetchDocuments();
      expect(container.read(documentViewModelProvider).errorMessage, isNotNull);
      
      notifier.clearMessages();
      
      final state = container.read(documentViewModelProvider);
      expect(state.errorMessage, isNull);
      expect(state.successMessage, isNull);
    });
  });
}

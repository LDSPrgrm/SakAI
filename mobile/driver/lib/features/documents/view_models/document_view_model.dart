import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sakai_api_client/sakai_api_client.dart';
import '../../../app/providers.dart';
import '../repositories/driver_document_repository.dart';

class DocumentState {
  final List<DriverDocumentResponse> documents;
  final bool isLoading;
  final bool isUploading;
  final String? errorMessage;
  final String? successMessage;

  const DocumentState({
    this.documents = const [],
    this.isLoading = false,
    this.isUploading = false,
    this.errorMessage,
    this.successMessage,
  });

  DocumentState copyWith({
    List<DriverDocumentResponse>? documents,
    bool? isLoading,
    bool? isUploading,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return DocumentState(
      documents: documents ?? this.documents,
      isLoading: isLoading ?? this.isLoading,
      isUploading: isUploading ?? this.isUploading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}

final documentViewModelProvider =
    NotifierProvider<DocumentViewModel, DocumentState>(DocumentViewModel.new);

class DocumentViewModel extends Notifier<DocumentState> {
  @override
  DocumentState build() {
    // Initial fetch
    Future.microtask(() => fetchDocuments());
    return const DocumentState();
  }

  DriverDocumentRepository get _repository => ref.read(driverDocumentRepositoryProvider);

  Future<void> fetchDocuments() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final documents = await _repository.listDocuments();
      state = state.copyWith(documents: documents, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<bool> uploadDocument({
    required String documentType,
    required String documentNumber,
    required String imagePath,
    DateTime? expiryDate,
  }) async {
    state = state.copyWith(isUploading: true, clearError: true, clearSuccess: true);
    try {
      await _repository.uploadDocument(
        documentType: documentType,
        documentNumber: documentNumber,
        imagePath: imagePath,
        expiryDate: expiryDate,
      );
      state = state.copyWith(
        isUploading: false,
        successMessage: 'Document uploaded successfully. It is now under review.',
      );
      await fetchDocuments();
      return true;
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }
}

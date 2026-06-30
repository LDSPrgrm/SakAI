library;

/// Task 15 — structural smoke coverage for the driver "My Documents" screen
/// under `ThemeMode.dark` (driver app is forced dark — see Task 3/4).
///
/// Pixel goldens are not used here: `mobile/shared`'s golden suite has 8
/// pre-existing environment-only failures (GoogleFonts/rendering in this
/// sandbox — see Task 3 stash A/B). New coverage instead asserts structure:
/// the screen pumps without throwing, uses the real `SakaiAppBar` (not a
/// bare `AppBar`), and renders the empty-state copy when there are no
/// documents yet.
import 'package:driver/app/providers.dart';
import 'package:driver/features/documents/repositories/driver_document_repository.dart';
import 'package:driver/features/documents/views/documents_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakai_api_client/sakai_api_client.dart';
import 'package:sakai_shared/sakai_shared.dart';

final _themeConfig = SakaiThemeConfig.driver();

/// Avoids the real network call `DocumentViewModel.build()` schedules via
/// `Future.microtask(() => fetchDocuments())`.
class _FakeDriverDocumentRepository extends DriverDocumentRepository {
  @override
  Future<List<DriverDocumentResponse>> listDocuments() async => const [];

  @override
  Future<DriverDocumentResponse> uploadDocument({
    required String documentType,
    required String documentNumber,
    required String imagePath,
    DateTime? expiryDate,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<DriverDocumentResponse> getDocumentStatus(String documentId) {
    throw UnimplementedError();
  }
}

void main() {
  testWidgets(
    'DocumentsScreen pumps under dark theme with the themed SakaiAppBar, '
    'not a bare AppBar',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            driverDocumentRepositoryProvider.overrideWithValue(
              _FakeDriverDocumentRepository(),
            ),
          ],
          child: MaterialApp(
            theme: SakaiTheme.dark(_themeConfig),
            home: const DocumentsScreen(),
          ),
        ),
      );
      await tester.pump();

      // Real themed app bar, never the bare default-themed AppBar.
      expect(find.byType(SakaiAppBar), findsOneWidget);

      // Empty-state copy renders once the fake repository resolves with no
      // documents — proves the screen pumps end-to-end without throwing.
      await tester.pump();
      expect(find.text('No documents uploaded yet'), findsOneWidget);
    },
  );
}

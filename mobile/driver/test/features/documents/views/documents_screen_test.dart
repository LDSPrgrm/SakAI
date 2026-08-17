library;

/// Task 15 — structural smoke coverage for the driver "My Documents" screen.
///
/// The driver app's theme mode is user-selectable and provider-driven
/// (defaults to `ThemeMode.system`), so this suite pumps the screen under
/// both `SakaiTheme.dark` and `SakaiTheme.light` rather than assuming a
/// single forced brightness. Each test supplies `MaterialApp.theme`
/// explicitly, so neither depends on the app-level theme-mode provider.
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
  // `theme` is a factory, not a value: SakaiTheme.* reaches through
  // google_fonts into the asset bundle, so it must be built inside the test
  // body (after the binding is initialized), never eagerly in `main()`.
  for (final variant in <({String label, ThemeData Function() theme})>[
    (label: 'dark', theme: () => SakaiTheme.dark(_themeConfig)),
    (label: 'light', theme: () => SakaiTheme.light(_themeConfig)),
  ]) {
    testWidgets(
      'DocumentsScreen pumps under ${variant.label} theme with the themed '
      'SakaiAppBar, not a bare AppBar',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              driverDocumentRepositoryProvider.overrideWithValue(
                _FakeDriverDocumentRepository(),
              ),
            ],
            child: MaterialApp(
              theme: variant.theme(),
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
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../support/test_harness.dart';

Widget _withOpener({required void Function(BuildContext) onTap}) {
  return sakaiHarness(
    Builder(
      builder: (ctx) => Center(
        child: ElevatedButton(
          onPressed: () => onTap(ctx),
          child: const Text('open'),
        ),
      ),
    ),
    wrapInScaffold: true,
  );
}

void main() {
  tearDown(() {
    // Ensure no overlay leaks between tests.
    SakaiLoadingOverlay.hide();
  });

  group('SakaiLoadingOverlay', () {
    testWidgets('show inserts a CircularProgressIndicator', (tester) async {
      await tester.pumpWidget(_withOpener(
        onTap: (ctx) => SakaiLoadingOverlay.show(ctx, message: 'Loading...'),
      ));

      expect(SakaiLoadingOverlay.isVisible, isFalse);
      await tester.tap(find.text('open'));
      await tester.pump();

      expect(SakaiLoadingOverlay.isVisible, isTrue);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('hide removes the overlay', (tester) async {
      await tester.pumpWidget(_withOpener(
        onTap: (ctx) => SakaiLoadingOverlay.show(ctx),
      ));

      await tester.tap(find.text('open'));
      await tester.pump();
      expect(SakaiLoadingOverlay.isVisible, isTrue);

      SakaiLoadingOverlay.hide();
      await tester.pump();

      expect(SakaiLoadingOverlay.isVisible, isFalse);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}

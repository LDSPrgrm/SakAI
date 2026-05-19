import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../support/test_harness.dart';

void main() {
  group('SakaiErrorAlert', () {
    testWidgets('renders message + error icon for default severity',
        (tester) async {
      await pumpSakai(
        tester,
        const SakaiErrorAlert(message: 'Network failed'),
        wrapInScaffold: true,
      );

      expect(find.text('Network failed'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsNothing);
    });

    testWidgets('warning severity uses warning_amber_rounded icon',
        (tester) async {
      await pumpSakai(
        tester,
        const SakaiErrorAlert(
          message: 'Heads up',
          severity: SakaiAlertSeverity.warning,
        ),
        wrapInScaffold: true,
      );

      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsNothing);
    });

    testWidgets('retry button only shown when onRetry provided + invokes it',
        (tester) async {
      // Without onRetry: no retry button.
      await pumpSakai(
        tester,
        const SakaiErrorAlert(message: 'Nope'),
        wrapInScaffold: true,
      );
      expect(find.text('Retry'), findsNothing);

      // With onRetry: tappable button that fires the callback.
      var tapped = false;
      await pumpSakai(
        tester,
        SakaiErrorAlert(
          message: 'Nope',
          onRetry: () => tapped = true,
        ),
        wrapInScaffold: true,
      );
      expect(find.text('Retry'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      expect(tapped, isTrue);
    });
  });
}

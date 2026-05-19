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
  group('SakaiDialog.confirm', () {
    testWidgets('renders title, message, and both action buttons',
        (tester) async {
      await tester.pumpWidget(_withOpener(
        onTap: (ctx) => SakaiDialog.confirm(
          ctx,
          title: 'Cancel ride?',
          message: 'This action cannot be undone.',
        ),
      ));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('Cancel ride?'), findsOneWidget);
      expect(find.text('This action cannot be undone.'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Confirm'), findsOneWidget);
    });

    testWidgets('returns false on cancel and true on confirm', (tester) async {
      late Future<bool> cancelResult;
      await tester.pumpWidget(_withOpener(
        onTap: (ctx) {
          cancelResult = SakaiDialog.confirm(
            ctx,
            title: 'T',
            message: 'M',
          );
        },
      ));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(await cancelResult, isFalse);

      late Future<bool> confirmResult;
      await tester.pumpWidget(_withOpener(
        onTap: (ctx) {
          confirmResult = SakaiDialog.confirm(
            ctx,
            title: 'T',
            message: 'M',
          );
        },
      ));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
      expect(await confirmResult, isTrue);
    });

    testWidgets('destructive: true tints confirm button with semantic.danger',
        (tester) async {
      await tester.pumpWidget(_withOpener(
        onTap: (ctx) => SakaiDialog.confirm(
          ctx,
          title: 'Logout?',
          message: 'You will be signed out.',
          confirmLabel: 'Logout',
          destructive: true,
        ),
      ));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      final BuildContext dialogContext = tester.element(find.text('Logout?'));
      final expectedDanger = SakaiSemanticColors.of(dialogContext).danger;

      final FilledButton confirmButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Logout'),
      );
      final style = confirmButton.style;
      expect(style, isNotNull);
      final bg = style!.backgroundColor?.resolve(<WidgetState>{});
      expect(bg, equals(expectedDanger));
    });
  });
}

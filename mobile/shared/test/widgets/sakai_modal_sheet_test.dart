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
  group('SakaiModalSheet', () {
    testWidgets('renders builder content when shown', (tester) async {
      await tester.pumpWidget(_withOpener(
        onTap: (ctx) => SakaiModalSheet.show<void>(
          ctx,
          builder: (_) => const Padding(
            padding: EdgeInsets.all(16),
            child: Text('sheet body'),
          ),
        ),
      ));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('sheet body'), findsOneWidget);
    });

    testWidgets('omits drag handle when dragHandle is false', (tester) async {
      await tester.pumpWidget(_withOpener(
        onTap: (ctx) => SakaiModalSheet.show<void>(
          ctx,
          dragHandle: false,
          builder: (_) => const SizedBox(
            height: 120,
            child: Center(child: Text('no handle')),
          ),
        ),
      ));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('no handle'), findsOneWidget);

      // The handle is a 36x4 Container with a BoxDecoration. When dragHandle
      // is false, no such Container should be present inside the sheet.
      final handleFinder = find.byWidgetPredicate((widget) {
        if (widget is! Container) return false;
        final c = widget.constraints;
        return c != null && c.maxWidth == 36 && c.maxHeight == 4;
      });
      expect(handleFinder, findsNothing);
    });

    testWidgets('tapping outside dismisses with null', (tester) async {
      late Future<String?> result;

      await tester.pumpWidget(_withOpener(
        onTap: (ctx) {
          result = SakaiModalSheet.show<String>(
            ctx,
            builder: (_) => const SizedBox(
              height: 120,
              child: Center(child: Text('dismiss me')),
            ),
          );
        },
      ));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('dismiss me'), findsOneWidget);

      // Tap the barrier in the top-left corner outside the sheet.
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(find.text('dismiss me'), findsNothing);
      expect(await result, isNull);
    });
  });
}

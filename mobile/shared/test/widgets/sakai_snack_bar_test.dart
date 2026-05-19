import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../support/test_harness.dart';

typedef _SnackInvoker = void Function(BuildContext context);

Future<(SnackBar, SakaiSemanticColors)> _triggerSnack(
  WidgetTester tester,
  _SnackInvoker invoke,
) async {
  late SakaiSemanticColors capturedSemantic;

  await tester.pumpWidget(sakaiHarness(
    Builder(builder: (ctx) {
      capturedSemantic = SakaiSemanticColors.of(ctx);
      return Center(
        child: ElevatedButton(
          onPressed: () => invoke(ctx),
          child: const Text('show'),
        ),
      );
    }),
    wrapInScaffold: true,
  ));

  await tester.tap(find.text('show'));
  // Let the snack bar enqueue + slide in.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 750));

  final snack = tester.widget<SnackBar>(find.byType(SnackBar));
  return (snack, capturedSemantic);
}

void main() {
  group('SakaiSnackBar', () {
    testWidgets('success uses semantic.success background', (tester) async {
      final (snack, semantic) =
          await _triggerSnack(tester, (ctx) => SakaiSnackBar.success(ctx, 'ok'));

      expect(find.text('ok'), findsOneWidget);
      expect(snack.backgroundColor, semantic.success);
    });

    testWidgets('error uses semantic.danger background', (tester) async {
      final (snack, semantic) =
          await _triggerSnack(tester, (ctx) => SakaiSnackBar.error(ctx, 'oops'));

      expect(find.text('oops'), findsOneWidget);
      expect(snack.backgroundColor, semantic.danger);
    });

    testWidgets('info uses semantic.accentBlue background', (tester) async {
      final (snack, semantic) =
          await _triggerSnack(tester, (ctx) => SakaiSnackBar.info(ctx, 'fyi'));

      expect(find.text('fyi'), findsOneWidget);
      expect(snack.backgroundColor, semantic.accentBlue);
    });
  });
}

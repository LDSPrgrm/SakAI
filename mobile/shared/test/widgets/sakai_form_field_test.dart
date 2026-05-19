import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../support/test_harness.dart';

void main() {
  group('SakaiFormField', () {
    testWidgets('renders label text', (tester) async {
      await pumpSakai(
        tester,
        const SakaiFormField(label: 'Full name'),
        wrapInScaffold: true,
      );
      expect(find.text('Full name'), findsOneWidget);
    });

    testWidgets('renders `*` suffix in error color when required', (tester) async {
      await pumpSakai(
        tester,
        const SakaiFormField(label: 'Email', required: true),
        wrapInScaffold: true,
      );

      // Locate the Text widget (built by Text.rich) whose textSpan contains
      // a ` *` child span.
      final labelText = tester.widget<Text>(
        find.byWidgetPredicate((widget) {
          if (widget is! Text) return false;
          final span = widget.textSpan;
          if (span is! TextSpan) return false;
          final children = span.children;
          if (children == null) return false;
          return children.any((c) => c is TextSpan && c.text == ' *');
        }),
      );

      final root = labelText.textSpan as TextSpan;
      final starSpan = root.children!.firstWhere(
        (c) => c is TextSpan && c.text == ' *',
      ) as TextSpan;

      // Resolve scheme.error from a context inside the harness.
      final ctx = tester.element(find.byType(SakaiFormField));
      final errorColor = Theme.of(ctx).colorScheme.error;
      expect(starSpan.style?.color, errorColor);
    });

    testWidgets('shows errorText and hides helperText when both set',
        (tester) async {
      await pumpSakai(
        tester,
        const SakaiFormField(
          label: 'Email',
          helperText: 'We never share this.',
          errorText: 'Invalid email',
        ),
        wrapInScaffold: true,
      );

      expect(find.text('Invalid email'), findsOneWidget);
      expect(find.text('We never share this.'), findsNothing);
    });
  });
}

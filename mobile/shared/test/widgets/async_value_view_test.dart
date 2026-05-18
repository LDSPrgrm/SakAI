import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakai_shared/sakai_shared.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: SakaiTheme.light(SakaiThemeConfig.passenger()),
        home: Scaffold(body: child),
      );

  group('AsyncValueView', () {
    testWidgets('renders skeleton on loading', (tester) async {
      await tester.pumpWidget(wrap(
        AsyncValueView<List<String>>(
          value: const AsyncValue.loading(),
          dataBuilder: (_) => const Text('DATA'),
        ),
      ));
      expect(find.byType(SakaiSkeleton), findsWidgets);
      expect(find.text('DATA'), findsNothing);
    });

    testWidgets('renders SakaiErrorState on error with retry', (tester) async {
      var retries = 0;
      await tester.pumpWidget(wrap(
        AsyncValueView<List<String>>(
          value: AsyncValue.error(Exception('boom'), StackTrace.empty),
          dataBuilder: (_) => const Text('DATA'),
          onRetry: () => retries++,
        ),
      ));
      expect(find.byType(SakaiErrorState), findsOneWidget);
      expect(find.textContaining('boom'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      await tester.pump();
      expect(retries, 1);
    });

    testWidgets('renders SakaiEmptyState when isEmpty returns true',
        (tester) async {
      await tester.pumpWidget(wrap(
        AsyncValueView<List<String>>(
          value: const AsyncValue.data(<String>[]),
          dataBuilder: (_) => const Text('DATA'),
          isEmpty: (list) => list.isEmpty,
          emptyTitle: 'No items',
        ),
      ));
      expect(find.byType(SakaiEmptyState), findsOneWidget);
      expect(find.text('No items'), findsOneWidget);
      expect(find.text('DATA'), findsNothing);
    });

    testWidgets('renders data builder when populated', (tester) async {
      await tester.pumpWidget(wrap(
        AsyncValueView<List<String>>(
          value: const AsyncValue.data(['a', 'b']),
          dataBuilder: (list) => Text('items: ${list.length}'),
          isEmpty: (list) => list.isEmpty,
        ),
      ));
      expect(find.text('items: 2'), findsOneWidget);
      expect(find.byType(SakaiEmptyState), findsNothing);
    });

    testWidgets('skips empty path when isEmpty is null', (tester) async {
      await tester.pumpWidget(wrap(
        AsyncValueView<int>(
          value: const AsyncValue.data(0),
          dataBuilder: (n) => Text('n=$n'),
        ),
      ));
      expect(find.text('n=0'), findsOneWidget);
    });
  });
}

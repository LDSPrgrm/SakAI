import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passenger/features/home/views/widgets/home_search_hero.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '_test_helpers.dart';

void main() {
  setUp(() {
    SakaiAnimatedBackdrop.debugDisableAnimations = true;
  });
  tearDown(() {
    SakaiAnimatedBackdrop.debugDisableAnimations = false;
  });

  testWidgets('renders Where to? label and fires onTap when tapped', (
    tester,
  ) async {
    var tapCount = 0;
    await tester.pumpWidget(
      ProviderScope(
        child: themedScaffold(child: HomeSearchHero(onTap: () => tapCount++)),
      ),
    );

    expect(find.text('Where to?'), findsOneWidget);

    await tester.tap(find.text('Where to?'));
    await tester.pumpAndSettle();

    expect(tapCount, 1);
  });
}

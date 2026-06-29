import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passenger/features/home/views/widgets/home_promo_carousel.dart';
import 'package:passenger/features/promotions/view_models/promotions_view_model.dart';
import 'package:sakai_api_client/sakai_api_client.dart' as api;
import 'package:sakai_shared/sakai_shared.dart';

import '_test_helpers.dart';

class _FakePromotionsNotifier extends PromotionsNotifier {
  _FakePromotionsNotifier(this._state);
  final PromotionsState _state;
  @override
  PromotionsState build() => _state;
}

api.Promotion _promo(String id) => api.Promotion(
  (b) => b
    ..id = id
    ..code = 'CODE$id'
    ..title = 'Promo $id'
    ..description = 'Save big on your next ride'
    ..discountValue = 50
    ..discountType = api.PromotionDiscountTypeEnum.percentage
    ..expiresAt = DateTime.now().add(const Duration(days: 7)),
);

void main() {
  setUp(() {
    SakaiAnimatedBackdrop.debugDisableAnimations = true;
  });
  tearDown(() {
    SakaiAnimatedBackdrop.debugDisableAnimations = false;
  });

  testWidgets('shows skeletons while loading', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          promotionsNotifierProvider.overrideWith(
            () => _FakePromotionsNotifier(
              const PromotionsState(status: PromotionsStatus.loading),
            ),
          ),
        ],
        child: routedScaffold(child: const HomePromoCarousel()),
      ),
    );
    await tester.pump();

    expect(find.byType(SakaiSkeleton), findsNWidgets(2));
  });

  testWidgets('renders one PageView page per promotion', (tester) async {
    final promos = [_promo('1'), _promo('2'), _promo('3')];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          promotionsNotifierProvider.overrideWith(
            () => _FakePromotionsNotifier(
              PromotionsState(
                status: PromotionsStatus.loaded,
                promotions: promos,
              ),
            ),
          ),
        ],
        child: routedScaffold(child: const HomePromoCarousel()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Promo 1'), findsOneWidget);
    expect(find.text('CODE1'), findsOneWidget);
  });
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passenger/features/home/views/widgets/home_recent_trips.dart';
import 'package:passenger/features/ride_history/models/ride_history_item.dart';
import 'package:passenger/features/ride_history/view_models/ride_history_list_view_model.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '_test_helpers.dart';

class _FakeRideHistoryNotifier extends RideHistoryListNotifier {
  _FakeRideHistoryNotifier(this._state);
  final RideHistoryListState _state;
  @override
  RideHistoryListState build() => _state;
}

RideHistoryItem _item(int i) => RideHistoryItem(
  id: 'r$i',
  status: RideStatus.completed,
  originAddress: 'Origin $i',
  destinationAddress: 'Destination $i',
  fare: 150 + i.toDouble(),
  estimatedFare: 150 + i.toDouble(),
  paymentMethod: 'cash',
  createdAt: DateTime.now().subtract(Duration(days: i)),
  updatedAt: DateTime.now().subtract(Duration(days: i)),
);

void main() {
  setUp(() {
    SakaiAnimatedBackdrop.debugDisableAnimations = true;
  });
  tearDown(() {
    SakaiAnimatedBackdrop.debugDisableAnimations = false;
  });

  testWidgets('caps recent trips at 3 even when 5 are available', (
    tester,
  ) async {
    final items = List.generate(5, _item);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          rideHistoryListNotifierProvider.overrideWith(
            () => _FakeRideHistoryNotifier(
              RideHistoryListState(
                status: RideHistoryStatus.success,
                items: items,
              ),
            ),
          ),
        ],
        child: routedScaffold(child: const HomeRecentTrips()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Destination 0'), findsOneWidget);
    expect(find.text('Destination 1'), findsOneWidget);
    expect(find.text('Destination 2'), findsOneWidget);
    expect(find.text('Destination 3'), findsNothing);
    expect(find.text('Destination 4'), findsNothing);
  });
}

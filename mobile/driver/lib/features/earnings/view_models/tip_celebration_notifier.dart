import 'package:built_collection/built_collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../../../app/providers.dart';

/// State surfaced by [TipCelebrationNotifier].
///
/// `pendingAmount` is non-null exactly once per WS `ride.completed` event
/// that carries a non-zero tip. The driver UI watches for this field
/// and pops [SakaiTipCelebration] when it changes; the UI is expected to
/// call [TipCelebrationNotifier.acknowledge] once the celebration has
/// been shown so the same tip isn't re-celebrated on rebuild.
class TipCelebrationState {
  final double? pendingAmount;
  final String? rideId;
  const TipCelebrationState({this.pendingAmount, this.rideId});

  static const idle = TipCelebrationState();
}

/// Listens for `ride.completed` on the shared WS dispatcher and surfaces
/// a one-shot celebration intent when the payload carries a non-zero tip.
///
/// Lives separately from [SosNotifier] because the two lifecycles are
/// independent and the tip flow is expected to gain more shape (rating
/// linkage, multi-currency, etc.) before we'd want to consolidate.
class TipCelebrationNotifier extends Notifier<TipCelebrationState> {
  WsDispatcher? _dispatcher;
  final List<void Function()> _disposers = [];

  @override
  TipCelebrationState build() {
    final dispatcher = WsDispatcher(ref.read(wsClientProvider));
    _dispatcher = dispatcher;
    _disposers.add(dispatcher.on<BuiltMap<String, Object?>>(
      WsEventType.rideCompleted,
      _onRideCompleted,
    ));
    ref.onDispose(() {
      for (final d in _disposers) {
        d();
      }
      _disposers.clear();
      _dispatcher?.dispose();
      _dispatcher = null;
    });
    return TipCelebrationState.idle;
  }

  void _onRideCompleted(BuiltMap<String, Object?> payload) {
    final tipRaw = payload['tip_amount'];
    if (tipRaw is! num) return;
    final tip = tipRaw.toDouble();
    if (tip <= 0) return;
    final rideId = payload['ride_id'] as String?;
    state = TipCelebrationState(pendingAmount: tip, rideId: rideId);
  }

  /// Mark the pending tip as acknowledged so the UI doesn't replay it on
  /// the next rebuild. Idempotent.
  void acknowledge() {
    if (state.pendingAmount == null) return;
    state = TipCelebrationState.idle;
  }
}

final tipCelebrationProvider =
    NotifierProvider<TipCelebrationNotifier, TipCelebrationState>(
  TipCelebrationNotifier.new,
);

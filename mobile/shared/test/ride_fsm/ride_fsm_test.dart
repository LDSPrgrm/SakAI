import 'package:flutter_test/flutter_test.dart';
import 'package:sakai_shared/ride_fsm/ride_fsm.dart';

void main() {
  group('RideFsm — transition table mirrors Go validTransitions', () {
    test('happy path: created → requested → accepted → arrived → inProgress → completed', () {
      final fsm = RideFsm(RideStatus.created);
      expect(fsm.apply(RideStatus.requested), isA<FsmApplied>());
      expect(fsm.current, RideStatus.requested);
      expect(fsm.apply(RideStatus.accepted), isA<FsmApplied>());
      expect(fsm.apply(RideStatus.arrived), isA<FsmApplied>());
      expect(fsm.apply(RideStatus.inProgress), isA<FsmApplied>());
      expect(fsm.apply(RideStatus.completed), isA<FsmApplied>());
      expect(fsm.current, RideStatus.completed);
    });

    test('payment_pending path: inProgress → paymentPending → completed', () {
      final fsm = RideFsm(RideStatus.inProgress);
      expect(fsm.apply(RideStatus.paymentPending), isA<FsmApplied>());
      expect(fsm.apply(RideStatus.completed), isA<FsmApplied>());
    });

    test('cancellation at every non-terminal stage', () {
      for (final from in [
        RideStatus.created,
        RideStatus.requested,
        RideStatus.accepted,
        RideStatus.arrived,
        RideStatus.paymentPending,
      ]) {
        final fsm = RideFsm(from);
        expect(fsm.apply(RideStatus.cancelled), isA<FsmApplied>(),
            reason: 'cancellation must be allowed from $from');
      }
    });

    test('inProgress cancels ONLY via paymentPending bridge', () {
      final fsm = RideFsm(RideStatus.inProgress);
      expect(fsm.apply(RideStatus.cancelled), isA<FsmImplausible>(),
          reason: 'in_progress → cancelled must be implausible (cancel only via payment_pending or finish)');
    });

    test('terminal states never advance', () {
      final completed = RideFsm(RideStatus.completed);
      expect(completed.apply(RideStatus.cancelled), isA<FsmImplausible>());
      expect(completed.apply(RideStatus.inProgress), isA<FsmImplausible>());

      final cancelled = RideFsm(RideStatus.cancelled);
      expect(cancelled.apply(RideStatus.requested), isA<FsmImplausible>());
      expect(cancelled.apply(RideStatus.completed), isA<FsmImplausible>());
    });

    test('FsmImplausible leaves current state untouched', () {
      final fsm = RideFsm(RideStatus.created);
      fsm.apply(RideStatus.completed); // illegal jump
      expect(fsm.current, RideStatus.created);
    });

    test('forbidden skips', () {
      final cases = <List<RideStatus>>[
        [RideStatus.created, RideStatus.accepted],
        [RideStatus.created, RideStatus.arrived],
        [RideStatus.created, RideStatus.completed],
        [RideStatus.requested, RideStatus.arrived],
        [RideStatus.requested, RideStatus.inProgress],
        [RideStatus.accepted, RideStatus.inProgress],
        [RideStatus.accepted, RideStatus.completed],
        [RideStatus.arrived, RideStatus.completed],
        [RideStatus.paymentPending, RideStatus.arrived],
        [RideStatus.paymentPending, RideStatus.inProgress],
      ];
      for (final pair in cases) {
        final fsm = RideFsm(pair[0]);
        expect(fsm.apply(pair[1]), isA<FsmImplausible>(),
            reason: '${pair[0]} → ${pair[1]} should be implausible');
      }
    });
  });

  group('RideFsm — utility helpers', () {
    test('isTerminal is true only for completed + cancelled', () {
      expect(RideStatus.completed.isTerminal, isTrue);
      expect(RideStatus.cancelled.isTerminal, isTrue);
      for (final s in [
        RideStatus.created,
        RideStatus.requested,
        RideStatus.accepted,
        RideStatus.arrived,
        RideStatus.inProgress,
        RideStatus.paymentPending,
      ]) {
        expect(s.isTerminal, isFalse, reason: '$s should be non-terminal');
      }
    });

    test('reset() bypasses transition check (used after state_sync)', () {
      final fsm = RideFsm(RideStatus.created);
      fsm.reset(RideStatus.completed);
      expect(fsm.current, RideStatus.completed);
    });

    test('fromWire round-trips known values; unknown for novel strings', () {
      expect(RideStatus.fromWire('payment_pending'), RideStatus.paymentPending);
      expect(RideStatus.fromWire('not-a-status'), RideStatus.unknown);
    });

    test('FsmApplied carries from + to', () {
      final fsm = RideFsm(RideStatus.requested);
      final r = fsm.apply(RideStatus.accepted);
      expect(r, isA<FsmApplied>());
      final ok = r as FsmApplied;
      expect(ok.from, RideStatus.requested);
      expect(ok.to, RideStatus.accepted);
    });
  });
}

/// Client-side mirror of the backend ride FSM.
///
/// Backend is the source of truth (see `internal/domain/ride.go`); this
/// module exists so notifiers can reject implausible inbound transitions
/// — typically a sign of missed events — and request `ride.state_sync` to
/// reconcile before driving UI into an invalid state.
///
/// The transition table MUST match the Go side exactly. RFC v2 §7.
library;

/// RideStatus mirrors backend `domain.RideStatus` wire values.
enum RideStatus {
  created('created'),
  requested('requested'),
  accepted('accepted'),
  arrived('arrived'),
  inProgress('in_progress'),
  paymentPending('payment_pending'),
  completed('completed'),
  cancelled('cancelled'),
  unknown('');

  final String wire;
  const RideStatus(this.wire);

  /// Returns the matching status or [RideStatus.unknown] for unrecognized
  /// values — keeps the FSM forward-compatible if the backend adds a state
  /// before the client is rebuilt.
  static RideStatus fromWire(String s) {
    for (final v in values) {
      if (v.wire == s) return v;
    }
    return RideStatus.unknown;
  }
}

const _transitions = <RideStatus, Set<RideStatus>>{
  RideStatus.created: {RideStatus.requested, RideStatus.cancelled},
  RideStatus.requested: {RideStatus.accepted, RideStatus.cancelled},
  RideStatus.accepted: {RideStatus.arrived, RideStatus.cancelled},
  RideStatus.arrived: {RideStatus.inProgress, RideStatus.cancelled},
  RideStatus.inProgress: {
    RideStatus.completed,
    RideStatus.paymentPending,
  },
  RideStatus.paymentPending: {
    RideStatus.completed,
    RideStatus.cancelled,
  },
  RideStatus.completed: <RideStatus>{},
  RideStatus.cancelled: <RideStatus>{},
};

extension RideStatusFsm on RideStatus {
  bool canTransitionTo(RideStatus next) =>
      (_transitions[this] ?? const <RideStatus>{}).contains(next);

  bool get isTerminal =>
      this == RideStatus.completed || this == RideStatus.cancelled;
}

/// FsmResult is the outcome of [RideFsm.apply].
sealed class FsmResult {
  const FsmResult();
}

class FsmApplied extends FsmResult {
  final RideStatus from;
  final RideStatus to;
  const FsmApplied(this.from, this.to);
}

/// FsmImplausible indicates the transition is not allowed from the current
/// state. The notifier should treat this as a signal that events were
/// missed and request `ride.state_sync` to reconcile. Per RFC v2 §7,
/// implausible ≠ wrong: it means "I lost context; resync."
class FsmImplausible extends FsmResult {
  final RideStatus from;
  final RideStatus to;
  const FsmImplausible(this.from, this.to);

  @override
  String toString() => 'FsmImplausible($from → $to)';
}

/// RideFsm is a tiny state holder around a single ride's status. The
/// constructor takes the initial state observed from the server (typically
/// `ride.state_sync` or `ride.accepted`); subsequent transitions must
/// arrive via [apply].
class RideFsm {
  RideStatus _current;
  RideFsm(this._current);

  RideStatus get current => _current;

  /// Apply a server-observed status transition. Returns [FsmApplied] when
  /// the transition is allowed, [FsmImplausible] otherwise. On implausible
  /// the internal state is NOT advanced.
  FsmResult apply(RideStatus next) {
    if (_current.canTransitionTo(next)) {
      final from = _current;
      _current = next;
      return FsmApplied(from, next);
    }
    return FsmImplausible(_current, next);
  }

  /// Forces the state to [next] without checking transition legality.
  /// Used after a successful `ride.state_sync` payload, where the server
  /// is restating ground truth and the client must adopt it verbatim.
  void reset(RideStatus next) {
    _current = next;
  }
}

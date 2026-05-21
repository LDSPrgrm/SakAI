/// Shared SOS lifecycle UI state.
///
/// Both passenger and driver active-ride flows render the same emergency
/// banner once an SOS has been triggered for the current ride, so the
/// state shape lives in shared/ to keep them in sync.
///
/// Privacy decisions baked in here (rather than at each call site so they
/// can't diverge):
///
/// * `assigneeDisplay` strips assignee_name to first token only — the
///   operator's surname / employee ID never reaches the rider/driver UI.
/// * `resolutionNotes` is intentionally **not** stored on the state. The
///   incident.resolved event may include redacted operator notes; we treat
///   them as informational-only and let the screen surface them as a
///   one-shot toast if it chooses, never as durable banner text.
/// * `reason` mirrors what the triggering party typed at trigger time.
///   It is already visible to that party (they typed it) and to the
///   counterpart (server-side audit decided to broadcast it on the
///   ride.sos_triggered event), so it is safe to retain in memory until
///   resolved.
library;

import 'package:meta/meta.dart';

@immutable
class SosUiState {
  /// True when an SOS is in flight for the current ride (either pending
  /// operator assignment or already assigned, but NOT yet resolved).
  final bool active;

  /// Server-side incident UUID. Carried from `ride.sos_triggered` so
  /// downstream consumers (e.g. the passenger location pusher) can target
  /// POST /incidents/:id/location without re-fetching via REST.
  final String? incidentId;

  /// Who pulled the SOS — "rider" or "driver" verbatim from the wire.
  /// Null until the trigger event arrives.
  final String? triggeredBy;

  /// Free-text reason supplied at trigger time. May be null.
  final String? reason;

  /// First-name-only display string of the operator that picked up the
  /// incident, or null if unassigned or unresolved. Surnames are stripped
  /// on the way in (see [SosUiState.withAssignee]) so this getter is safe
  /// to render directly to the screen.
  final String? assigneeDisplay;

  const SosUiState({
    this.active = false,
    this.incidentId,
    this.triggeredBy,
    this.reason,
    this.assigneeDisplay,
  });

  static const idle = SosUiState();

  /// Apply `ride.sos_triggered` to the state. Idempotent — re-applying the
  /// same trigger does not overwrite the assignee.
  SosUiState withTrigger({String? incidentId, String? triggeredBy, String? reason}) {
    return SosUiState(
      active: true,
      incidentId: incidentId ?? this.incidentId,
      triggeredBy: triggeredBy ?? this.triggeredBy,
      reason: reason ?? this.reason,
      assigneeDisplay: assigneeDisplay,
    );
  }

  /// Apply `incident.assigned`. Honours privacy: only the first whitespace
  /// token of [fullAssigneeName] is retained.
  SosUiState withAssignee(String? fullAssigneeName) {
    final firstName = _firstNameOnly(fullAssigneeName);
    return SosUiState(
      active: true,
      incidentId: incidentId,
      triggeredBy: triggeredBy,
      reason: reason,
      assigneeDisplay: firstName,
    );
  }

  /// Apply `incident.resolved`. Clears the active flag and the assignee —
  /// the screen reverts to its non-SOS layout.
  SosUiState withResolved() => SosUiState.idle;

  static String? _firstNameOnly(String? full) {
    if (full == null) return null;
    final trimmed = full.trim();
    if (trimmed.isEmpty) return null;
    final space = trimmed.indexOf(RegExp(r'\s'));
    if (space < 0) return trimmed;
    return trimmed.substring(0, space);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SosUiState &&
          other.active == active &&
          other.incidentId == incidentId &&
          other.triggeredBy == triggeredBy &&
          other.reason == reason &&
          other.assigneeDisplay == assigneeDisplay);

  @override
  int get hashCode => Object.hash(active, incidentId, triggeredBy, reason, assigneeDisplay);

  @override
  String toString() =>
      'SosUiState(active: $active, incidentId: $incidentId, '
      'triggeredBy: $triggeredBy, reason: $reason, '
      'assigneeDisplay: $assigneeDisplay)';
}

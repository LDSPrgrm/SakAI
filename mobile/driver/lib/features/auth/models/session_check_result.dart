/// Result of checking whether a persisted session is still usable.
class SessionCheckResult {
  const SessionCheckResult._({required this.status, this.reason});

  const SessionCheckResult.authenticated()
      : this._(status: SessionCheckStatus.authenticated);

  const SessionCheckResult.unauthenticated()
      : this._(status: SessionCheckStatus.unauthenticated);

  const SessionCheckResult.transientError({
    SessionCheckFailureReason reason = SessionCheckFailureReason.unknown,
  }) : this._(status: SessionCheckStatus.transientError, reason: reason);

  final SessionCheckStatus status;
  final SessionCheckFailureReason? reason;
}

enum SessionCheckStatus { authenticated, unauthenticated, transientError }

enum SessionCheckFailureReason { network, server, unknown }

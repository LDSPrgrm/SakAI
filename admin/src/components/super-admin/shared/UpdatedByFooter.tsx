import React from 'react';

interface UpdatedByFooterProps {
  name?: string | null;
  actions?: React.ReactNode;
}

// A bare UUID-like updated_by value isn't user-facing — render "Never updated"
// instead of leaking the identifier.
const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

export function UpdatedByFooter({ name, actions }: UpdatedByFooterProps) {
  const trimmed = name?.trim();
  const hasName = !!trimmed && !UUID_RE.test(trimmed);
  return (
    <div className="flex items-center justify-between gap-3 pt-3 border-t border-border">
      <p className="text-xs text-text-muted">
        {hasName ? (
          <>Last updated by <span className="text-text-main">{trimmed}</span></>
        ) : (
          <span>Never updated</span>
        )}
      </p>
      {actions}
    </div>
  );
}

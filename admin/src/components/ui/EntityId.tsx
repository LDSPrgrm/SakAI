import { useState, useCallback, type MouseEvent } from 'react';
import { cn } from '@/lib/utils';

interface EntityIdProps {
  /** Pre-formatted reference like "INC-0042". Backend supplies this when available. */
  displayId?: string;
  /** Full UUID. Required for tooltip + clipboard payload. */
  uuid?: string | null;
  /** Used to compose a fallback ref ("INC-A4F2") when displayId is absent. */
  fallbackPrefix?: string;
  size?: 'sm' | 'md';
  className?: string;
}

const sizes = {
  sm: 'px-2 py-0.5 text-xs',
  md: 'px-2.5 py-1 text-sm',
};

function fallbackRef(prefix: string | undefined, uuid: string | null | undefined): string {
  if (!uuid) return prefix ? `${prefix}-?` : '—';
  return `${prefix ?? 'REF'}-${uuid.replace(/-/g, '').slice(0, 4).toUpperCase()}`;
}

export function EntityId({
  displayId,
  uuid,
  fallbackPrefix,
  size = 'sm',
  className,
}: EntityIdProps) {
  const [copied, setCopied] = useState(false);
  const label = displayId && displayId.length > 0 ? displayId : fallbackRef(fallbackPrefix, uuid);

  const onClick = useCallback(
    (e: MouseEvent<HTMLButtonElement>) => {
      e.stopPropagation();
      const payload = uuid ?? displayId ?? '';
      if (!payload || typeof navigator === 'undefined' || !navigator.clipboard) return;
      void navigator.clipboard.writeText(payload).then(() => {
        setCopied(true);
        window.setTimeout(() => setCopied(false), 1200);
      });
    },
    [uuid, displayId]
  );

  const tooltip = uuid ?? label;

  return (
    <button
      type="button"
      onClick={onClick}
      title={tooltip}
      aria-label={`${label} (click to copy ${tooltip})`}
      data-testid="entity-id"
      className={cn(
        'inline-flex items-center rounded-md border font-mono leading-none',
        'border-border bg-surface-hover text-text-muted',
        'transition-colors hover:border-primary/40 hover:text-text',
        'focus:outline-none focus-visible:ring-2 focus-visible:ring-primary/40',
        'cursor-pointer select-none whitespace-nowrap',
        sizes[size],
        className
      )}
    >
      {copied ? 'Copied!' : label}
    </button>
  );
}

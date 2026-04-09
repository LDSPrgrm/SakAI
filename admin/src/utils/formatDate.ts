// Format dates/times in Philippine Time (Asia/Manila, UTC+8).
// Spec: superadmin.md — all datetimes displayed in PHT

const PHT_LOCALE = 'en-PH';
const PHT_TZ     = 'Asia/Manila';

/** Full date: "Apr 9, 2026" */
export function formatDate(iso: string): string {
  return new Date(iso).toLocaleDateString(PHT_LOCALE, {
    timeZone: PHT_TZ,
    year: 'numeric',
    month: 'short',
    day: 'numeric',
  });
}

/** Full datetime: "Apr 9, 2026, 2:30 PM" */
export function formatDateTime(iso: string): string {
  return new Date(iso).toLocaleString(PHT_LOCALE, {
    timeZone: PHT_TZ,
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  });
}

/** Time only: "2:30 PM" */
export function formatTime(iso: string): string {
  return new Date(iso).toLocaleTimeString(PHT_LOCALE, {
    timeZone: PHT_TZ,
    hour: '2-digit',
    minute: '2-digit',
  });
}

/** Relative time, capped at absolute date after 7 days */
export function formatRelativeTime(iso: string): string {
  const diffMs = Date.now() - new Date(iso).getTime();
  const mins = Math.floor(diffMs / 60_000);
  if (mins < 1)  return 'just now';
  if (mins < 60) return `${mins}m ago`;
  const hrs = Math.floor(mins / 60);
  if (hrs < 24)  return `${hrs}h ago`;
  const days = Math.floor(hrs / 24);
  if (days < 7)  return `${days}d ago`;
  return formatDate(iso);
}

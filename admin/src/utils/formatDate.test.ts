import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { formatDate, formatDateTime, formatTime, formatRelativeTime } from './formatDate';

// 2026-04-18 08:00:00 UTC = 2026-04-18 16:00:00 PHT (UTC+8)
const ISO_AFTERNOON = '2026-04-18T08:00:00.000Z';

describe('formatDate', () => {
  it('formats an ISO string to a short PHT date', () => {
    expect(formatDate(ISO_AFTERNOON)).toBe('Apr 18, 2026');
  });

  it('uses Philippine Time — UTC midnight becomes the same day in PHT', () => {
    // 2026-01-01T00:00:00Z = 2026-01-01 08:00 PHT, still Jan 1
    expect(formatDate('2026-01-01T00:00:00.000Z')).toBe('Jan 1, 2026');
  });
});

describe('formatDateTime', () => {
  it('includes time in 12-hour format', () => {
    // 08:00 UTC = 16:00 PHT = 4:00 PM
    expect(formatDateTime(ISO_AFTERNOON)).toBe('Apr 18, 2026, 4:00 PM');
  });
});

describe('formatTime', () => {
  it('returns time only in PHT', () => {
    expect(formatTime(ISO_AFTERNOON)).toBe('4:00 PM');
  });
});

describe('formatRelativeTime', () => {
  const NOW = new Date('2026-04-18T12:00:00.000Z').getTime();

  beforeEach(() => {
    vi.useFakeTimers();
    vi.setSystemTime(NOW);
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  it('returns "just now" for less than a minute ago', () => {
    const iso = new Date(NOW - 30_000).toISOString();
    expect(formatRelativeTime(iso)).toBe('just now');
  });

  it('returns minutes ago', () => {
    const iso = new Date(NOW - 5 * 60_000).toISOString();
    expect(formatRelativeTime(iso)).toBe('5m ago');
  });

  it('returns hours ago', () => {
    const iso = new Date(NOW - 3 * 60 * 60_000).toISOString();
    expect(formatRelativeTime(iso)).toBe('3h ago');
  });

  it('returns days ago', () => {
    const iso = new Date(NOW - 2 * 24 * 60 * 60_000).toISOString();
    expect(formatRelativeTime(iso)).toBe('2d ago');
  });

  it('returns formatted date when older than 7 days', () => {
    const iso = new Date(NOW - 10 * 24 * 60 * 60_000).toISOString();
    // Falls back to formatDate output
    expect(formatRelativeTime(iso)).toBe(formatDate(iso));
  });
});

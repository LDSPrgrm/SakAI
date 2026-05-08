import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { secondsAgo } from './timeAgo';

describe('secondsAgo', () => {
  const NOW = new Date('2026-05-08T12:00:00Z').getTime();

  beforeEach(() => {
    vi.useFakeTimers();
    vi.setSystemTime(NOW);
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  it('returns "never" for undefined / null / invalid inputs', () => {
    expect(secondsAgo(undefined)).toBe('never');
    expect(secondsAgo(null)).toBe('never');
    expect(secondsAgo(0)).toBe('never');
    expect(secondsAgo(NaN)).toBe('never');
  });

  it('returns "just now" within the first 5 seconds', () => {
    expect(secondsAgo(NOW)).toBe('just now');
    expect(secondsAgo(NOW - 1_000)).toBe('just now');
    expect(secondsAgo(NOW - 4_000)).toBe('just now');
  });

  it('returns seconds when between 5s and 60s', () => {
    expect(secondsAgo(NOW - 5_000)).toBe('5s ago');
    expect(secondsAgo(NOW - 30_000)).toBe('30s ago');
    expect(secondsAgo(NOW - 59_000)).toBe('59s ago');
  });

  it('returns minutes when between 1m and 60m', () => {
    expect(secondsAgo(NOW - 60_000)).toBe('1m ago');
    expect(secondsAgo(NOW - 5 * 60_000)).toBe('5m ago');
    expect(secondsAgo(NOW - 59 * 60_000)).toBe('59m ago');
  });

  it('returns hours past 60 minutes', () => {
    expect(secondsAgo(NOW - 60 * 60_000)).toBe('1h ago');
    expect(secondsAgo(NOW - 3 * 60 * 60_000)).toBe('3h ago');
  });

  it('accepts Date instances', () => {
    expect(secondsAgo(new Date(NOW - 10_000))).toBe('10s ago');
  });

  it('treats future timestamps as just now (clock-skew safe)', () => {
    expect(secondsAgo(NOW + 5_000)).toBe('just now');
  });
});

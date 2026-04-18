import { describe, it, expect } from 'vitest';
import { maskApiKey } from './maskApiKey';

describe('maskApiKey', () => {
  it('shows only the last 4 characters by default', () => {
    // 'sk-1234567890abcdef' = 19 chars → 15 bullets + last 4 'cdef'
    expect(maskApiKey('sk-1234567890abcdef')).toBe('•••••••••••••••cdef');
  });

  it('masks with bullet characters', () => {
    const result = maskApiKey('ABCDEFGHIJ');
    expect(result.endsWith('GHIJ')).toBe(true);
    expect(result.startsWith('••')).toBe(true);
  });

  it('returns empty string for empty input', () => {
    expect(maskApiKey('')).toBe('');
  });

  it('returns key as-is when shorter than or equal to visibleChars', () => {
    expect(maskApiKey('1234')).toBe('1234');
    expect(maskApiKey('123')).toBe('123');
  });

  it('respects custom visibleChars', () => {
    // 'ABCDEFGH' = 8 chars, visibleChars=6 → 2 bullets + last 6 'CDEFGH'
    expect(maskApiKey('ABCDEFGH', 6)).toBe('••CDEFGH');
  });

  it('caps bullet count at 20 for very long keys', () => {
    const longKey = 'A'.repeat(50) + 'BCDE';
    const result = maskApiKey(longKey);
    const bullets = result.replace(/[^•]/g, '');
    expect(bullets.length).toBe(20);
    expect(result.endsWith('BCDE')).toBe(true);
  });
});

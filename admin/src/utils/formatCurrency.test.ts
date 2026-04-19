import { describe, it, expect } from 'vitest';
import { formatPHP, formatPHPNumber } from './formatCurrency';

describe('formatPHP', () => {
  it('formats a standard amount with peso sign and 2 decimal places', () => {
    expect(formatPHP(12345.67)).toBe('₱12,345.67');
  });

  it('formats zero', () => {
    expect(formatPHP(0)).toBe('₱0.00');
  });

  it('adds thousands separator', () => {
    expect(formatPHP(1000000)).toBe('₱1,000,000.00');
  });

  it('rounds to 2 decimal places', () => {
    expect(formatPHP(9.999)).toBe('₱10.00');
  });

  it('formats small amounts', () => {
    expect(formatPHP(5)).toBe('₱5.00');
  });

  it('formats negative amounts', () => {
    expect(formatPHP(-250)).toBe('-₱250.00');
  });
});

describe('formatPHPNumber', () => {
  it('formats without currency symbol', () => {
    expect(formatPHPNumber(12345.67)).toBe('12,345.67');
  });

  it('formats zero without symbol', () => {
    expect(formatPHPNumber(0)).toBe('0.00');
  });

  it('adds thousands separator without symbol', () => {
    expect(formatPHPNumber(1000)).toBe('1,000.00');
  });
});

import { describe, expect, it } from 'vitest';
import { computeChangedKeys } from './objectDiff';

describe('computeChangedKeys', () => {
  it('returns empty set for identical objects', () => {
    expect(computeChangedKeys({ a: 1, b: 'x' }, { a: 1, b: 'x' }).size).toBe(0);
  });

  it('returns empty set for both null/undefined', () => {
    expect(computeChangedKeys(null, null).size).toBe(0);
    expect(computeChangedKeys(undefined, undefined).size).toBe(0);
  });

  it('flags scalar value change', () => {
    const out = computeChangedKeys({ a: 1, b: 2 }, { a: 1, b: 3 });
    expect(out.has('b')).toBe(true);
    expect(out.has('a')).toBe(false);
  });

  it('flags top-level key when nested value changes', () => {
    const out = computeChangedKeys(
      { meta: { count: 1 }, name: 'x' },
      { meta: { count: 2 }, name: 'x' },
    );
    expect(out.has('meta')).toBe(true);
    expect(out.has('name')).toBe(false);
  });

  it('flags added keys', () => {
    const out = computeChangedKeys({ a: 1 }, { a: 1, b: 2 });
    expect(out.has('b')).toBe(true);
    expect(out.size).toBe(1);
  });

  it('flags removed keys', () => {
    const out = computeChangedKeys({ a: 1, b: 2 }, { a: 1 });
    expect(out.has('b')).toBe(true);
    expect(out.size).toBe(1);
  });

  it('flags array length change', () => {
    const out = computeChangedKeys({ items: [1, 2] }, { items: [1, 2, 3] });
    expect(out.has('items')).toBe(true);
  });

  it('flags array element change', () => {
    const out = computeChangedKeys({ items: [1, 2] }, { items: [1, 9] });
    expect(out.has('items')).toBe(true);
  });

  it('flags null vs object as changed', () => {
    const out = computeChangedKeys({ profile: null }, { profile: { id: 1 } });
    expect(out.has('profile')).toBe(true);
  });

  it('treats null and undefined values as different', () => {
    const out = computeChangedKeys({ x: null }, { x: undefined });
    expect(out.has('x')).toBe(true);
  });

  it('handles one side null gracefully', () => {
    const out = computeChangedKeys(null, { a: 1, b: 2 });
    expect(out.has('a')).toBe(true);
    expect(out.has('b')).toBe(true);
    expect(out.size).toBe(2);
  });
});

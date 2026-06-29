import { describe, it, expect } from 'vitest';
import { prefixFor, RESOURCE_TYPE_PREFIX } from './resourceTypeToPrefix';

describe('prefixFor', () => {
  it('maps known resource types', () => {
    expect(prefixFor('incident')).toBe('INC');
    expect(prefixFor('ride')).toBe('RIDE');
    expect(prefixFor('user')).toBe('USR');
    expect(prefixFor('admin_user')).toBe('USR');
    expect(prefixFor('fare_config')).toBe('FARE');
  });

  it('returns REF for unknown types', () => {
    expect(prefixFor('something_new')).toBe('REF');
  });

  it('returns REF for null/undefined', () => {
    expect(prefixFor(null)).toBe('REF');
    expect(prefixFor(undefined)).toBe('REF');
    expect(prefixFor('')).toBe('REF');
  });

  it('table covers all backend ResourceType strings used in usecase', () => {
    for (const t of ['admin_user', 'incident', 'fare_config', 'surge_config', 'alert_rule']) {
      expect(RESOURCE_TYPE_PREFIX[t]).toBeDefined();
    }
  });
});

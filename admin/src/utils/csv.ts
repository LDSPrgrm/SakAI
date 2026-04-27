// RFC 4180 CSV field escaping. Wraps the value in double quotes and doubles
// any embedded quote when the field contains a comma, double quote, CR, or LF.
// Null / undefined collapse to an empty field rather than the literal strings
// "null" / "undefined" that String() would otherwise produce.

export function csvEscape(value: unknown): string {
  if (value == null) return '';
  const s = String(value);
  return /[",\r\n]/.test(s) ? `"${s.replace(/"/g, '""')}"` : s;
}

export function csvRow(values: readonly unknown[]): string {
  return values.map(csvEscape).join(',');
}

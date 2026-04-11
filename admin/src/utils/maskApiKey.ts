// Mask API keys — show only the last 4 characters.
// Spec: superadmin.md §4.5 — "API keys masked in UI (show last 4 characters only)"

export function maskApiKey(key: string, visibleChars = 4): string {
  if (!key) return '';
  if (key.length <= visibleChars) return key;
  return `${'•'.repeat(Math.min(key.length - visibleChars, 20))}${key.slice(-visibleChars)}`;
}

// Format a number as Philippine Peso.
// Spec: superadmin.md — PHP (₱) with 2 decimal places and thousands separator
// e.g. 12345.67 → "₱12,345.67"

export function formatPHP(amount: number): string {
  return new Intl.NumberFormat('en-PH', {
    style: 'currency',
    currency: 'PHP',
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  }).format(amount);
}

/** Returns just the formatted number without the symbol (for layout where ₱ is shown separately) */
export function formatPHPNumber(amount: number): string {
  return new Intl.NumberFormat('en-PH', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  }).format(amount);
}

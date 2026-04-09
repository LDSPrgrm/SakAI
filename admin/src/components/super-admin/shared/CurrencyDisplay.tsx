// Displays a PHP monetary value — spec requires ₱ with 2 decimal places and thousands separator.
import { cn } from '@/lib/utils';
import { formatPHP } from '@/utils/formatCurrency';

interface CurrencyDisplayProps {
  amount: number;
  /** Show sign for deltas (+/−) */
  showSign?: boolean;
  className?: string;
}

export function CurrencyDisplay({ amount, showSign, className }: CurrencyDisplayProps) {
  const sign = showSign && amount >= 0 ? '+' : '';
  const formatted = formatPHP(Math.abs(amount));
  const isNegative = amount < 0;

  return (
    <span
      className={cn(
        'tabular-nums',
        showSign && isNegative ? 'text-danger' : undefined,
        showSign && !isNegative ? 'text-success' : undefined,
        className,
      )}
    >
      {isNegative ? '-' : sign}{formatted}
    </span>
  );
}

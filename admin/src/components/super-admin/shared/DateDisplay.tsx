// Displays a datetime in Philippine Time (Asia/Manila, UTC+8).
import { cn } from '@/lib/utils';
import { formatDateTime, formatDate, formatRelativeTime } from '@/utils/formatDate';

interface DateDisplayProps {
  iso: string | null | undefined;
  format?: 'datetime' | 'date' | 'relative';
  className?: string;
}

export function DateDisplay({ iso, format = 'datetime', className }: DateDisplayProps) {
  if (!iso) return <span className={cn('text-text-muted', className)}>—</span>;

  const text =
    format === 'date'     ? formatDate(iso) :
    format === 'relative' ? formatRelativeTime(iso) :
    formatDateTime(iso);

  return (
    <span className={cn('tabular-nums', className)} title={formatDateTime(iso)}>
      {text}
    </span>
  );
}

import { cn } from '@/lib/utils';
import { ROLE_LABELS } from '@/constants/roles';

type AdminRole = 'admin' | 'superadmin' | 'operations' | 'finance' | 'support' | string;

const ROLE_COLORS: Record<string, string> = {
  admin:       'bg-primary/10 text-primary border-primary/20',
  superadmin:  'bg-warning/10 text-warning border-warning/20',
  operations:  'bg-primary/10 text-primary border-primary/20',
  finance:     'bg-success/10 text-success border-success/20',
  support:     'bg-surface text-text-muted border-border',
};

interface RoleBadgeProps {
  role: AdminRole;
  /** Show "System" indicator for immutable built-in roles */
  showSystemTag?: boolean;
  className?: string;
}

function titleCase(s: string): string {
  return s.replace(/_/g, ' ').replace(/\b\w/g, (c) => c.toUpperCase());
}

export function RoleBadge({ role, showSystemTag, className }: RoleBadgeProps) {
  const color  = ROLE_COLORS[role] ?? 'bg-surface text-text-muted border-border';
  const label  = ROLE_LABELS[role as keyof typeof ROLE_LABELS] ?? titleCase(role);
  const isSystem = role === 'superadmin';

  return (
    <span className="inline-flex items-center gap-1">
      <span className={cn('inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium border capitalize', color, className)}>
        {label}
      </span>
      {showSystemTag && isSystem && (
        <span className="text-[10px] text-text-muted border border-border rounded px-1">System</span>
      )}
    </span>
  );
}

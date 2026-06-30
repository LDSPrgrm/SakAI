import React from 'react';
import { Wallet, CreditCard, Banknote, type LucideIcon } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { Badge } from '@/components/ui/Badge';
import { cn } from '@/lib/utils';
import type { PaymentGatewayConfig } from '@/api/super-admin/payments';

type Provider = 'gcash' | 'paymaya' | 'card' | 'cash';

const PROVIDER_ORDER: Provider[] = ['gcash', 'paymaya', 'card', 'cash'];

const PROVIDER_META: Record<Provider, { label: string; Icon: LucideIcon; tileCls: string }> = {
  gcash:   { label: 'GCash',   Icon: Wallet,     tileCls: 'bg-primary/10 text-primary ring-primary/20' },
  paymaya: { label: 'PayMaya', Icon: Wallet,     tileCls: 'bg-primary/10 text-primary ring-primary/20' },
  card:    { label: 'Card',    Icon: CreditCard, tileCls: 'bg-primary/10 text-primary ring-primary/20' },
  cash:    { label: 'Cash',    Icon: Banknote,   tileCls: 'bg-success/10 text-success ring-success/20' },
};

function relativeFromNow(iso?: string): string {
  if (!iso) return 'never';
  const then = new Date(iso).getTime();
  if (Number.isNaN(then)) return 'never';
  const diffMs = Date.now() - then;
  const mins = Math.round(diffMs / 60_000);
  if (mins < 1) return 'just now';
  if (mins < 60) return `${mins}m ago`;
  const hrs = Math.round(mins / 60);
  if (hrs < 24) return `${hrs}h ago`;
  const days = Math.round(hrs / 24);
  return `${days}d ago`;
}

export interface GatewayStatusBoardProps {
  configs: PaymentGatewayConfig[];
  isLoading?: boolean;
  className?: string;
}

export function GatewayStatusBoard({ configs, isLoading, className }: GatewayStatusBoardProps) {
  const byProvider = new Map<Provider, PaymentGatewayConfig>();
  for (const c of configs) {
    if (c.provider && PROVIDER_ORDER.includes(c.provider as Provider)) {
      byProvider.set(c.provider as Provider, c);
    }
  }

  return (
    <Card className={cn('flex flex-col', className)}>
      <CardHeader className="flex flex-row items-center justify-between">
        <div className="flex items-center gap-2">
          <span
            className="w-1.5 h-1.5 rounded-full bg-[var(--color-sa-accent)]"
            aria-hidden
          />
          <CardTitle className="text-sm font-semibold uppercase tracking-wider">
            Gateways
          </CardTitle>
        </div>
        <span className="text-[10px] uppercase tracking-widest text-text-muted/80">
          {configs.length} configured
        </span>
      </CardHeader>
      <CardContent className="p-0 flex-1 min-h-0">
        {isLoading ? (
          <ul className="flex flex-col">
            {Array.from({ length: 4 }).map((_, i) => (
              <li
                key={i}
                data-testid="gateway-skeleton"
                className="flex items-center gap-3 px-4 py-2.5 border-b border-border/60 last:border-0 animate-pulse"
              >
                <div className="w-9 h-9 rounded-lg bg-surface-hover flex-shrink-0" />
                <div className="flex-1 flex flex-col gap-1">
                  <div className="h-3 w-16 rounded bg-surface-hover" />
                  <div className="h-2 w-24 rounded bg-surface-hover" />
                </div>
                <div className="h-5 w-16 rounded bg-surface-hover" />
              </li>
            ))}
          </ul>
        ) : (
          <ul className="flex flex-col">
            {PROVIDER_ORDER.map((p) => {
              const cfg = byProvider.get(p);
              const meta = PROVIDER_META[p];
              const Icon = meta.Icon;

              let statusLabel: string;
              let statusVariant: 'success' | 'default' | 'warning';
              if (!cfg) {
                statusLabel = 'Not configured';
                statusVariant = 'warning';
              } else if (cfg.is_active) {
                statusLabel = 'Connected';
                statusVariant = 'success';
              } else {
                statusLabel = 'Disabled';
                statusVariant = 'default';
              }

              return (
                <li
                  key={p}
                  className="flex items-center gap-3 px-4 py-2.5 border-b border-border/60 last:border-0"
                >
                  <div
                    className={cn(
                      'w-9 h-9 rounded-lg flex items-center justify-center ring-1 flex-shrink-0',
                      meta.tileCls,
                    )}
                  >
                    <Icon className="w-4 h-4" />
                  </div>
                  <div className="min-w-0 flex-1 flex flex-col gap-0.5">
                    <span className="text-sm font-semibold text-text-main">{meta.label}</span>
                    <span className="text-[11px] text-text-muted tabular-nums">
                      {cfg ? `updated ${relativeFromNow(cfg.updated_at)}` : 'no record'}
                    </span>
                  </div>
                  <Badge variant={statusVariant}>{statusLabel}</Badge>
                </li>
              );
            })}
          </ul>
        )}
      </CardContent>
    </Card>
  );
}

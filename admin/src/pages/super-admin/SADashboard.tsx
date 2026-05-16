import React, { useEffect, useMemo, useState } from 'react';
import {
  RefreshCw, Activity, Clock, Server, PhilippinePeso,
  ShieldAlert, ShieldCheck, Wallet, Users, Gauge, Car,
} from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { KPICard } from '@/components/super-admin/dashboard/KPICard';
import { ServiceStatusBanner } from '@/components/super-admin/dashboard/ServiceStatusBanner';
import { ActionQueueCard } from '@/components/super-admin/dashboard/ActionQueueCard';
import { ServiceHealthGrid } from '@/components/super-admin/dashboard/ServiceHealthGrid';
import { PaymentSplitCard } from '@/components/super-admin/dashboard/PaymentSplitCard';
import { GatewayStatusBoard } from '@/components/super-admin/dashboard/GatewayStatusBoard';
import { ActivityFeed } from '@/components/super-admin/dashboard/ActivityFeed';
import type { FeedEvent } from '@/components/super-admin/shared/activityMeta';
import { useDashboardMetrics, useDriverHeatmap } from '@/hooks/useMetrics';
import { useInfraMetrics, useSystemServices } from '@/hooks/useSystem';
import { useKycQueue, useIncidents } from '@/hooks/useSafety';
import { usePayouts, useGatewayConfigs } from '@/hooks/usePayments';
import { useAuditLog } from '@/hooks/useAuditLog';
import { useReportChart } from '@/hooks/useReports';
import type { AuditLog } from '@/types/super-admin/audit';
import { useRoleAccent } from '@/hooks/useRoleAccent';
import { formatPHP, cn } from '@/lib/utils';
import { UpdatedAgo } from '@/utils/timeAgo';

const ACTION_QUEUE_REFRESH_MS = 30_000;
const PAYMENTS_REFRESH_MS = 60_000;

const LATENCY_GREEN = 250;
const LATENCY_YELLOW = 500;

function latencyTone(ms: number | undefined): 'success' | 'warning' | 'danger' | 'muted' {
  if (ms == null) return 'muted';
  if (ms < LATENCY_GREEN) return 'success';
  if (ms < LATENCY_YELLOW) return 'warning';
  return 'danger';
}

const TONE_TEXT: Record<string, string> = {
  success: 'text-success',
  warning: 'text-warning',
  danger: 'text-danger',
  muted: 'text-text-muted',
};

function useNow(intervalMs = 30_000) {
  const [now, setNow] = useState(() => new Date());
  useEffect(() => {
    const id = window.setInterval(() => setNow(new Date()), intervalMs);
    return () => window.clearInterval(id);
  }, [intervalMs]);
  return now;
}

const ALERT_ACTIONS = new Set(['delete', 'reject', 'suspend', 'revoke']);

function relativeTime(iso?: string): string {
  if (!iso) return '';
  const then = new Date(iso).getTime();
  if (Number.isNaN(then)) return '';
  const diffMs = Date.now() - then;
  const mins = Math.round(diffMs / 60_000);
  if (mins < 1) return 'just now';
  if (mins < 60) return `${mins}m`;
  const hrs = Math.round(mins / 60);
  if (hrs < 24) return `${hrs}h`;
  const days = Math.round(hrs / 24);
  return `${days}d`;
}

function auditLogToFeedEvent(entry: AuditLog, index: number): FeedEvent {
  const actor = entry.actor_name ?? 'Admin';
  const action = entry.action ?? 'event';
  const resource = [entry.resource_type, entry.resource_id].filter(Boolean).join(' ');
  return {
    id: entry.id ?? `audit-${index}`,
    type: action,
    message: `${actor} ${action.replace(/_/g, ' ')}${resource ? ` · ${resource}` : ''}`,
    time: relativeTime(entry.timestamp),
    isAlert: ALERT_ACTIONS.has(action.toLowerCase()),
  };
}

export function SADashboard() {
  const accent = useRoleAccent();
  const metricsQuery = useDashboardMetrics();
  const heatmapQuery = useDriverHeatmap();
  const infraQuery = useInfraMetrics({ refetchInterval: 30_000 });
  const kycQuery = useKycQueue({ refetchInterval: ACTION_QUEUE_REFRESH_MS });
  const incidentsQuery = useIncidents({ refetchInterval: ACTION_QUEUE_REFRESH_MS });
  const payoutsQuery = usePayouts({ refetchInterval: ACTION_QUEUE_REFRESH_MS });
  const servicesQuery = useSystemServices({ refetchInterval: 30_000 });
  const gatewaysQuery = useGatewayConfigs({ refetchInterval: PAYMENTS_REFRESH_MS });
  const auditQuery = useAuditLog();
  const paymentSplitQuery = useReportChart('payment-methods', undefined, { refetchInterval: PAYMENTS_REFRESH_MS });
  const now = useNow();

  const lastUpdated = Math.max(
    metricsQuery.dataUpdatedAt ?? 0,
    heatmapQuery.dataUpdatedAt ?? 0,
    infraQuery.dataUpdatedAt ?? 0,
    kycQuery.dataUpdatedAt ?? 0,
    incidentsQuery.dataUpdatedAt ?? 0,
    payoutsQuery.dataUpdatedAt ?? 0,
    servicesQuery.dataUpdatedAt ?? 0,
    gatewaysQuery.dataUpdatedAt ?? 0,
    auditQuery.dataUpdatedAt ?? 0,
    paymentSplitQuery.dataUpdatedAt ?? 0,
  );

  const metrics = metricsQuery.data;
  const isLoading = !metrics;
  const isFetching = metricsQuery.isFetching;

  const refetchAll = () => {
    void metricsQuery.refetch();
    void heatmapQuery.refetch();
    void infraQuery.refetch();
    void kycQuery.refetch();
    void incidentsQuery.refetch();
    void payoutsQuery.refetch();
    void servicesQuery.refetch();
    void gatewaysQuery.refetch();
    void auditQuery.refetch();
    void paymentSplitQuery.refetch();
  };

  const onlineDrivers = heatmapQuery.data?.positions.length ?? 0;
  const apiP95 = infraQuery.data?.api_p95_ms;
  const p95Tone = latencyTone(apiP95);

  const pendingKyc = useMemo(
    () => (kycQuery.data ?? []).filter((k) => k.status === 'pending').length,
    [kycQuery.data],
  );
  const openIncidents = useMemo(
    () => (incidentsQuery.data ?? []).filter((i) => i.status === 'open' || i.status === 'investigating' || i.status === 'escalated').length,
    [incidentsQuery.data],
  );
  const pendingPayouts = useMemo(
    () => (payoutsQuery.data ?? []).filter((p) => p.status === 'pending').length,
    [payoutsQuery.data],
  );

  const activityEvents = useMemo<FeedEvent[]>(
    () => (auditQuery.data ?? []).slice(0, 30).map(auditLogToFeedEvent),
    [auditQuery.data],
  );

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64 text-text-muted text-sm">
        Loading superadmin dashboard…
      </div>
    );
  }

  const timestamp = new Intl.DateTimeFormat('en-PH', {
    timeZone: 'Asia/Manila',
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit',
    hour12: false,
  }).format(now);

  const dateLabel = new Intl.DateTimeFormat('en-PH', {
    timeZone: 'Asia/Manila',
    weekday: 'long',
    month: 'short',
    day: 'numeric',
    year: 'numeric',
  }).format(now);

  const kpis = [
    {
      title: 'Revenue Today',
      value: formatPHP(metrics.revenue_today ?? 0),
      icon: PhilippinePeso,
      tone: accent.kpiTone,
      trend: metrics.revenue_trend,
    },
    {
      title: 'Rides Today',
      value: (metrics.rides_today ?? 0).toLocaleString(),
      icon: Activity,
      tone: accent.kpiTone,
      trend: metrics.rides_trend,
    },
    {
      title: 'Avg Wait',
      value: `${metrics.avg_wait_minutes ?? 0}m`,
      icon: Clock,
      tone: 'warning' as const,
      trend: metrics.wait_trend,
      trendDownIsGood: true,
    },
    {
      title: 'Uptime',
      value: `${metrics.platform_uptime ?? 0}%`,
      icon: Server,
      tone: 'success' as const,
    },
  ];

  return (
    <div className="flex flex-col gap-5">
      <header className="flex flex-col gap-3 pb-2 border-b border-border/60">
        <div className="flex flex-wrap items-center justify-between gap-2">
          <div className="flex items-center gap-2 text-xs text-text-muted tabular-nums">
            <span className="relative flex w-2 h-2">
              <span className="absolute inset-0 rounded-full bg-success animate-ping opacity-60" />
              <span className="relative rounded-full bg-success w-2 h-2" />
            </span>
            <span className="hidden sm:inline">{dateLabel} · Manila</span>
            <span className="font-mono text-text-main">{timestamp}</span>
          </div>
          <div className="flex items-center gap-3">
            <UpdatedAgo timestamp={lastUpdated || undefined} />
            <Button
              variant="outline"
              size="sm"
              onClick={refetchAll}
              disabled={isFetching}
              title="Refresh"
              className="flex items-center gap-2"
            >
              <RefreshCw className={cn('w-4 h-4', isFetching && 'animate-spin')} />
              Refresh
            </Button>
          </div>
        </div>

        <div className="flex flex-col gap-1 min-w-0">
          <h1 className="text-2xl md:text-3xl font-bold text-text-main tracking-tight leading-none">
            Superadmin Dashboard
          </h1>
          <p className="text-sm text-text-muted">
            Real-time pulse of SakAI rides, revenue, and platform health.
          </p>
        </div>
      </header>

      <ServiceStatusBanner />

      <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
        {kpis.map((k, i) => (
          <div key={k.title} className="kpi-rise" style={{ animationDelay: `${i * 55}ms` }}>
            <KPICard
              title={k.title}
              value={k.value}
              icon={k.icon}
              iconTone={k.tone}
              trend={k.trend}
              trendDownIsGood={k.trendDownIsGood}
            />
          </div>
        ))}
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
        <Card className="p-4 flex items-center gap-4">
          <div className="w-11 h-11 rounded-lg flex items-center justify-center bg-primary/10 text-primary ring-1 ring-primary/20 flex-shrink-0">
            <Users className="w-5 h-5" />
          </div>
          <div className="min-w-0 flex-1 flex flex-col gap-0.5">
            <span className="text-[10px] uppercase tracking-widest text-text-muted font-semibold">
              Total Riders
            </span>
            <div className="flex items-baseline gap-2 flex-wrap">
              <span className="text-2xl font-bold tabular-nums leading-none text-text-main">
                {(metrics.total_riders ?? 0).toLocaleString()}
              </span>
              {metrics.riders_trend && (
                <span className="text-xs text-success tabular-nums">
                  {metrics.riders_trend}
                </span>
              )}
            </div>
          </div>
        </Card>

        <Card className="p-4 flex items-center gap-4">
          <div className="w-11 h-11 rounded-lg flex items-center justify-center bg-[var(--color-sa-accent-soft)] text-[var(--color-sa-accent)] ring-1 ring-[var(--color-sa-accent)]/20 flex-shrink-0">
            <Car className="w-5 h-5" />
          </div>
          <div className="min-w-0 flex-1 flex flex-col gap-0.5">
            <span className="text-[10px] uppercase tracking-widest text-text-muted font-semibold">
              Total Drivers
            </span>
            <div className="flex items-baseline gap-2 flex-wrap">
              <span className="text-2xl font-bold tabular-nums leading-none text-text-main">
                {(metrics.total_drivers ?? 0).toLocaleString()}
              </span>
              {metrics.drivers_trend && (
                <span className="text-xs text-success tabular-nums">
                  {metrics.drivers_trend}
                </span>
              )}
            </div>
          </div>
        </Card>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
        <Card className="p-4 flex items-center gap-4">
          <div className="w-11 h-11 rounded-lg flex items-center justify-center bg-primary/10 text-primary ring-1 ring-primary/20 flex-shrink-0">
            <Users className="w-5 h-5" />
          </div>
          <div className="min-w-0 flex-1 flex flex-col gap-0.5">
            <span className="text-[10px] uppercase tracking-widest text-text-muted font-semibold">
              Drivers Online
            </span>
            <div className="flex items-baseline gap-2">
              <span className="text-2xl font-bold tabular-nums leading-none text-text-main">
                {onlineDrivers.toLocaleString()}
              </span>
              <span className="text-xs text-text-muted">live supply</span>
            </div>
          </div>
        </Card>

        <Card className="p-4 flex items-center gap-4">
          <div className={cn('w-11 h-11 rounded-lg flex items-center justify-center ring-1 flex-shrink-0',
            p95Tone === 'success' && 'bg-success/10 text-success ring-success/20',
            p95Tone === 'warning' && 'bg-warning/10 text-warning ring-warning/20',
            p95Tone === 'danger'  && 'bg-danger/10 text-danger ring-danger/20',
            p95Tone === 'muted'   && 'bg-surface-hover text-text-muted ring-border',
          )}>
            <Gauge className="w-5 h-5" />
          </div>
          <div className="min-w-0 flex-1 flex flex-col gap-0.5">
            <span className="text-[10px] uppercase tracking-widest text-text-muted font-semibold">
              API P95 Latency
            </span>
            <div className="flex items-baseline gap-2">
              <span className={cn('text-2xl font-bold tabular-nums leading-none', TONE_TEXT[p95Tone])}>
                {apiP95 != null ? `${Math.round(apiP95)}ms` : '—'}
              </span>
              <span className="text-xs text-text-muted">
                {p95Tone === 'success' && 'healthy'}
                {p95Tone === 'warning' && 'elevated'}
                {p95Tone === 'danger'  && 'degraded'}
                {p95Tone === 'muted'   && 'no data'}
              </span>
            </div>
          </div>
        </Card>
      </div>

      <div className="flex flex-col gap-2">
        <span className="text-[10px] uppercase tracking-widest text-text-muted font-semibold">
          Action Queue
        </span>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
          <ActionQueueCard
            label="KYC Pending"
            count={pendingKyc}
            to="/super-admin/safety"
            icon={ShieldCheck}
            tone={accent.queueTone}
            isLoading={kycQuery.isLoading}
            emptyHint="Queue empty"
          />
          <ActionQueueCard
            label="Open Incidents"
            count={openIncidents}
            to="/super-admin/safety"
            icon={ShieldAlert}
            tone={openIncidents > 0 ? 'danger' : 'success'}
            isLoading={incidentsQuery.isLoading}
            emptyHint="None open"
          />
          <ActionQueueCard
            label="Payouts Pending"
            count={pendingPayouts}
            to="/super-admin/payments"
            icon={Wallet}
            tone={accent.queueTone}
            isLoading={payoutsQuery.isLoading}
            emptyHint="All paid out"
          />
        </div>
      </div>

      <div className="flex flex-col gap-2">
        <span className="text-[10px] uppercase tracking-widest text-text-muted font-semibold">
          Service Health
        </span>
        <ServiceHealthGrid
          services={servicesQuery.data ?? []}
          isLoading={servicesQuery.isLoading}
        />
      </div>

      <div className="flex flex-col gap-2">
        <span className="text-[10px] uppercase tracking-widest text-text-muted font-semibold">
          Payments
        </span>
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-3">
          <PaymentSplitCard
            className="lg:col-span-1"
            query={paymentSplitQuery}
          />
          <GatewayStatusBoard
            className="lg:col-span-2"
            configs={gatewaysQuery.data ?? []}
            isLoading={gatewaysQuery.isLoading}
          />
        </div>
      </div>

      <div className="flex flex-col gap-2">
        <span className="text-[10px] uppercase tracking-widest text-text-muted font-semibold">
          Recent Admin Activity
        </span>
        <ActivityFeed events={activityEvents} initialVisible={6} />
      </div>
    </div>
  );
}

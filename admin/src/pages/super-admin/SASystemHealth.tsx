import React, { useEffect, useState } from 'react';
import { RefreshCw } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { StatusBadge } from '@/components/shared/StatusBadge';
import { useInfraMetrics, useSystemServices } from '@/hooks/useSystem';
import type { SystemService } from '@/types/super-admin';
import { cn } from '@/lib/utils';

// ── Helpers ───────────────────────────────────────────────────────────────────

function secondsAgo(date: Date): string {
  const diff = Math.floor((Date.now() - date.getTime()) / 1000);
  if (diff < 60) return `${diff}s ago`;
  const mins = Math.floor(diff / 60);
  return `${mins}m ago`;
}

function latencyColor(ms: number): string {
  if (ms < 200) return 'text-success';
  if (ms < 500) return 'text-warning';
  return 'text-danger';
}

function uptimeColor(pct: number): string {
  if (pct >= 99.9) return 'text-success';
  if (pct >= 99) return 'text-warning';
  return 'text-danger';
}

function statusDotClass(status: SystemService['status']): string {
  if (status === 'ok') return 'bg-success';
  if (status === 'degraded') return 'bg-warning';
  return 'bg-danger';
}

// ── Sub-components ────────────────────────────────────────────────────────────

function ServiceCard({ service }: { service: SystemService }) {
  return (
    <div className="p-4 bg-surface border border-border rounded-xl space-y-3">
      {/* Header */}
      <div className="flex items-center justify-between gap-2">
        <span className="font-medium text-text-main truncate">{service.name}</span>
        <div className="flex items-center gap-2 flex-shrink-0">
          <span
            className={cn('w-3 h-3 rounded-full flex-shrink-0', statusDotClass(service.status))}
            aria-hidden="true"
          />
          <StatusBadge status={service.status} />
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-2 gap-2 text-sm">
        <div>
          <p className="text-xs text-text-muted">Latency</p>
          <p className={cn('font-semibold', latencyColor(service.latency_ms ?? 0))}>
            {service.latency_ms != null ? `${service.latency_ms}ms` : '—'}
          </p>
        </div>
        <div>
          <p className="text-xs text-text-muted">Uptime</p>
          <p className={cn('font-semibold', uptimeColor(service.uptime_pct ?? 0))}>
            {service.uptime_pct != null ? `${service.uptime_pct.toFixed(2)}%` : '—'}
          </p>
        </div>
      </div>

      {/* Last checked */}
      <p className="text-xs text-text-muted">
        {service.last_checked ? `Checked ${secondsAgo(new Date(service.last_checked))}` : 'Not checked'}
      </p>
    </div>
  );
}

// ── Main component ────────────────────────────────────────────────────────────

export function SASystemHealth() {
  const servicesQuery = useSystemServices({ refetchInterval: 30_000 });
  const metricsQuery = useInfraMetrics({ refetchInterval: 30_000 });
  const services = (servicesQuery.data ?? []) as unknown as SystemService[];
  const metrics = metricsQuery.data;
  const loading = servicesQuery.isFetching;
  const lastRefreshed = servicesQuery.dataUpdatedAt
    ? new Date(servicesQuery.dataUpdatedAt)
    : new Date();
  const [, tick] = useState(0); // force re-render every second for "X seconds ago"

  const fetchServices = () => { void servicesQuery.refetch(); };

  useEffect(() => {
    // Tick every second to keep "last updated" text fresh
    const tickInterval = setInterval(() => tick((n) => n + 1), 1000);
    return () => clearInterval(tickInterval);
  }, []);

  // Derived counts
  const downCount = services.filter((s) => s.status === 'down').length;
  const degradedCount = services.filter((s) => s.status === 'degraded').length;

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div>
          <h1 className="text-2xl font-bold text-text-main">System Health</h1>
          <p className="text-sm text-text-muted mt-0.5">
            Last updated: {secondsAgo(lastRefreshed)}
          </p>
        </div>
        <Button variant="outline" onClick={fetchServices} disabled={loading}>
          <RefreshCw className={cn('w-4 h-4 mr-2', loading && 'animate-spin')} />
          Refresh
        </Button>
      </div>

      {/* Overall status banner */}
      {downCount > 0 ? (
        <div className="flex items-center gap-2 px-4 py-3 bg-danger/10 border border-danger/20 rounded-lg text-danger text-sm font-medium">
          ⚠ Critical: {downCount} service{downCount !== 1 ? 's' : ''} down
        </div>
      ) : degradedCount > 0 ? (
        <div className="flex items-center gap-2 px-4 py-3 bg-warning/10 border border-warning/20 rounded-lg text-warning text-sm font-medium">
          ⚡ Warning: {degradedCount} service{degradedCount !== 1 ? 's' : ''} degraded
        </div>
      ) : (
        <div className="flex items-center gap-2 px-4 py-3 bg-success/10 border border-success/20 rounded-lg text-success text-sm font-medium">
          All systems operational
        </div>
      )}

      {/* Service status board */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
        {services.map((service) => (
          <ServiceCard key={service.name} service={service} />
        ))}
        {services.length === 0 && !loading && (
          <p className="col-span-full text-sm text-text-muted text-center py-8">
            No service data available.
          </p>
        )}
      </div>

      {/* Infrastructure summary */}
      <Card>
        <CardHeader>
          <CardTitle>Infrastructure Summary</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            {buildInfraTiles(metrics).map(({ label, value }) => (
              <div
                key={label}
                className="p-3 bg-surface-hover rounded-lg text-center"
              >
                <p className="text-2xl font-bold text-text-main">{value}</p>
                <p className="text-xs text-text-muted mt-1">{label}</p>
              </div>
            ))}
          </div>
          {!metrics && !metricsQuery.isFetching && (
            <p className="text-xs text-text-muted mt-3 text-center">
              No infra samples yet — probes start streaming after first request.
            </p>
          )}
        </CardContent>
      </Card>
    </div>
  );
}

function buildInfraTiles(m?: { api_p50_ms?: number; api_p95_ms?: number; ws_connections?: number; db_query_p99_ms?: number }) {
  const fmtMs = (n?: number) => (n == null ? '—' : `${Math.round(n)}ms`);
  const fmtInt = (n?: number) => (n == null ? '—' : n.toLocaleString());
  return [
    { label: 'API P50 Latency', value: fmtMs(m?.api_p50_ms) },
    { label: 'API P95 Latency', value: fmtMs(m?.api_p95_ms) },
    { label: 'Active WS Connections', value: fmtInt(m?.ws_connections) },
    { label: 'DB Query Time P99', value: fmtMs(m?.db_query_p99_ms) },
  ];
}

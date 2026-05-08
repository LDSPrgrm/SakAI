import React, { useMemo, useState } from 'react';
import { Download } from 'lucide-react';
import {
  PieChart,
  Pie,
  Cell,
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
  ReferenceLine,
  LabelList,
} from 'recharts';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { DateRangePicker, DateRange, getDefaultRange } from '@/components/shared/DateRangePicker';
import { PageHeader } from '@/components/shared/PageHeader';
import { useReportList, useReportChart, useExportReport } from '@/hooks/useReports';
import type { ReportRange } from '@/api/super-admin/reports';
import { CHART_COLORS, DARK_TOOLTIP_STYLE } from '@/utils/chartColors';
import { renderOutsidePieLabel } from '@/utils/pieLabels';
import { aggregateByWeekday } from '@/utils/chartAggregate';

function toIsoDate(d: Date): string {
  return d.toISOString().slice(0, 10);
}

// ── Constants ─────────────────────────────────────────────────────────────────

const COLORS = CHART_COLORS;
const DARK_TOOLTIP = DARK_TOOLTIP_STYLE;

const yAxisLabel = (value: string) => ({
  value,
  angle: -90 as const,
  position: 'insideLeft' as const,
  fill: '#9CA3AF',
  fontSize: 11,
  style: { textAnchor: 'middle' as const },
});

// ── Types ──────────────────────────────────────────────────────────────────────

interface ReportItem {
  id: string;
  title: string;
  description: string;
}

// ── Component ─────────────────────────────────────────────────────────────────

export function SAReports() {
  const [dateRange, setDateRange] = useState<DateRange>(getDefaultRange('30d'));
  const [selectedReport, setSelectedReport] = useState<string>('weekly-financial');

  const apiRange: ReportRange = useMemo(
    () => ({ from: toIsoDate(dateRange.from), to: toIsoDate(dateRange.to) }),
    [dateRange.from, dateRange.to],
  );

  const reportListQuery = useReportList();
  const vehicleQuery = useReportChart('vehicle-distribution', apiRange);
  const paymentQuery = useReportChart('payment-methods', apiRange);
  const waitTimeQuery = useReportChart('wait-time', apiRange);
  const ratingsQuery = useReportChart('average-ratings', apiRange);
  const exportReport = useExportReport();

  const reportList = (reportListQuery.data ?? []) as ReportItem[];

  // Backend returns { label, value } — normalise to { name, value } for recharts.
  const vehicleData = ((vehicleQuery.data ?? []) as { label?: string; name?: string; value: number }[])
    .map(d => ({ name: d.name ?? d.label ?? 'Unknown', value: d.value }));
  const paymentData = ((paymentQuery.data ?? []) as { label?: string; name?: string; value: number }[])
    .map(d => ({ name: d.name ?? d.label ?? 'Unknown', value: d.value }));
  const waitTimeRaw = ((waitTimeQuery.data ?? []) as { label?: string; name?: string; wait?: number; value?: number }[])
    .map(d => {
      const v = d.wait ?? d.value ?? 0;
      return { name: d.name ?? d.label ?? '', wait: v > 0 ? v : null };
    });
  const waitTimeData = aggregateByWeekday(waitTimeRaw, ['wait'] as const);
  const ratingsRaw = ((ratingsQuery.data ?? []) as {
    name: string; driver: number; rider: number;
  }[]).map(d => ({
    name: d.name,
    driver: d.driver > 0 ? d.driver : null,
    rider: d.rider > 0 ? d.rider : null,
  }));
  const ratingsData = aggregateByWeekday(ratingsRaw, ['driver', 'rider'] as const);
  const loading = reportListQuery.isPending;

  async function handleExport(type: string) {
    const res = await exportReport.mutateAsync({ type, range: apiRange }).catch(() => null);
    if (!res) return;
    const blob = new Blob([res.data], { type: 'text/csv' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `${type}-${Date.now()}.csv`;
    a.click();
    URL.revokeObjectURL(url);
  }

  async function handleExportAll() {
    await handleExport(selectedReport);
  }

  // ── Render ─────────────────────────────────────────────────────────────────

  return (
    <div className="space-y-6 p-6">

      <PageHeader
        title="Reports & Analytics"
        actions={
          <>
            <DateRangePicker value={dateRange} onChange={setDateRange} />
            <Button variant="outline" size="sm" onClick={handleExportAll}>
              <Download className="w-4 h-4 mr-1.5" />
              Export CSV
            </Button>
          </>
        }
      />

      {/* Section 1 — Charts */}
      {loading ? (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {Array.from({ length: 4 }).map((_, i) => (
            <Card key={i}>
              <CardContent className="h-64 flex items-center justify-center text-text-muted">
                Loading chart...
              </CardContent>
            </Card>
          ))}
        </div>
      ) : (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">

          {/* Chart 1 — Rides by Vehicle Type (Donut) */}
          <Card>
            <CardHeader>
              <CardTitle>Rides by Vehicle Type</CardTitle>
              <p className="text-xs text-text-muted mt-1">Share of total rides</p>
            </CardHeader>
            <CardContent>
              <ResponsiveContainer width="100%" height={260}>
                <PieChart>
                  <Pie
                    data={vehicleData}
                    dataKey="value"
                    nameKey="name"
                    cy="55%"
                    innerRadius={60}
                    outerRadius={90}
                    paddingAngle={3}
                    label={renderOutsidePieLabel}
                    labelLine={false}
                  >
                    {vehicleData.map((_, index) => (
                      <Cell
                        key={`vehicle-cell-${index}`}
                        fill={COLORS[index % COLORS.length]}
                      />
                    ))}
                  </Pie>
                  <Tooltip {...DARK_TOOLTIP} />
                  <Legend verticalAlign="bottom" height={36} />
                </PieChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>

          {/* Chart 2 — Payment Method Distribution (Donut) */}
          <Card>
            <CardHeader>
              <CardTitle>Payment Method Distribution</CardTitle>
              <p className="text-xs text-text-muted mt-1">Share of total transactions</p>
            </CardHeader>
            <CardContent>
              <ResponsiveContainer width="100%" height={260}>
                <PieChart>
                  <Pie
                    data={paymentData}
                    dataKey="value"
                    nameKey="name"
                    cy="55%"
                    innerRadius={60}
                    outerRadius={90}
                    paddingAngle={3}
                    label={renderOutsidePieLabel}
                    labelLine={false}
                  >
                    {paymentData.map((_, index) => (
                      <Cell
                        key={`payment-cell-${index}`}
                        fill={COLORS[index % COLORS.length]}
                      />
                    ))}
                  </Pie>
                  <Tooltip {...DARK_TOOLTIP} />
                  <Legend verticalAlign="bottom" height={36} />
                </PieChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>

          {/* Chart 3 — Wait Time Trends (Line + ReferenceLine) */}
          <Card>
            <CardHeader>
              <CardTitle>Wait Time Trends</CardTitle>
              <p className="text-xs text-text-muted mt-1">Daily average · target ≤ 5 min</p>
            </CardHeader>
            <CardContent>
              <ResponsiveContainer width="100%" height={260}>
                <LineChart
                  data={waitTimeData}
                  margin={{ top: 28, right: 16, left: 24, bottom: 24 }}
                >
                  <CartesianGrid strokeDasharray="3 3" stroke="#333" />
                  <XAxis
                    dataKey="name"
                    tick={{ fill: '#9CA3AF', fontSize: 12 }}
                    axisLine={false}
                    tickLine={false}
                    interval="preserveStartEnd"
                    minTickGap={32}
                  />
                  <YAxis
                    tick={{ fill: '#9CA3AF', fontSize: 12 }}
                    axisLine={false}
                    tickLine={false}
                    label={yAxisLabel('Wait time (min)')}
                  />
                  <Tooltip
                    {...DARK_TOOLTIP}
                    formatter={(value: number) => [`${value} min`, 'Wait Time']}
                  />
                  <ReferenceLine
                    y={5}
                    stroke="#FBBC05"
                    strokeDasharray="4 4"
                    label={{
                      value: 'Target 5min',
                      fill: '#FBBC05',
                      fontSize: 11,
                      position: 'insideTopRight',
                    }}
                  />
                  <Line
                    type="linear"
                    dataKey="wait"
                    stroke="#1A73E8"
                    strokeWidth={2}
                    connectNulls
                    dot={{ r: 3, fill: '#1A73E8' }}
                    activeDot={{ r: 5 }}
                  >
                    <LabelList
                      dataKey="wait"
                      position="top"
                      fill="#E5E7EB"
                      fontSize={11}
                      formatter={(v: number | null) => (v == null ? '' : `${v}m`)}
                    />
                  </Line>
                </LineChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>

          {/* Chart 4 — Average Ratings (Line, driver + rider) */}
          <Card>
            <CardHeader>
              <CardTitle>Average Ratings</CardTitle>
              <p className="text-xs text-text-muted mt-1">1–5 scale · driver vs rider</p>
            </CardHeader>
            <CardContent>
              <ResponsiveContainer width="100%" height={260}>
                <LineChart
                  data={ratingsData}
                  margin={{ top: 28, right: 16, left: 24, bottom: 24 }}
                >
                  <CartesianGrid strokeDasharray="3 3" stroke="#333" />
                  <XAxis
                    dataKey="name"
                    tick={{ fill: '#9CA3AF', fontSize: 12 }}
                    axisLine={false}
                    tickLine={false}
                    interval="preserveStartEnd"
                    minTickGap={32}
                  />
                  <YAxis
                    tick={{ fill: '#9CA3AF', fontSize: 12 }}
                    axisLine={false}
                    tickLine={false}
                    domain={[1, 5]}
                    label={yAxisLabel('Rating (1–5)')}
                  />
                  <Tooltip {...DARK_TOOLTIP} />
                  <Legend />
                  <Line
                    type="linear"
                    dataKey="driver"
                    name="Driver Rating"
                    stroke="#1A73E8"
                    strokeWidth={2}
                    connectNulls
                    dot={{ r: 3, fill: '#1A73E8' }}
                    activeDot={{ r: 5 }}
                  >
                    <LabelList
                      dataKey="driver"
                      position="top"
                      fill="#E5E7EB"
                      fontSize={11}
                      formatter={(v: number | null) => (v == null ? '' : v.toFixed(1))}
                    />
                  </Line>
                  <Line
                    type="linear"
                    dataKey="rider"
                    name="Rider Rating"
                    stroke="#34A853"
                    strokeWidth={2}
                    connectNulls
                    dot={{ r: 3, fill: '#34A853' }}
                    activeDot={{ r: 5 }}
                  >
                    <LabelList
                      dataKey="rider"
                      position="bottom"
                      fill="#E5E7EB"
                      fontSize={11}
                      formatter={(v: number | null) => (v == null ? '' : v.toFixed(1))}
                    />
                  </Line>
                </LineChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>
        </div>
      )}

      {/* Section 2 — Available Reports */}
      <div>
        <h2 className="text-lg font-semibold text-text-main mb-4">
          Available Reports
        </h2>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {reportList.map((report) => (
            <div
              key={report.id}
              className={`p-4 bg-surface-hover rounded-lg border flex flex-col gap-3 transition-colors cursor-pointer ${
                selectedReport === report.id
                  ? 'border-primary ring-1 ring-primary'
                  : 'border-border hover:border-border/80'
              }`}
              onClick={() => setSelectedReport(report.id)}
            >
              <div>
                <p className="font-medium text-text-main">{report.title}</p>
                <p className="text-sm text-text-muted mt-1">{report.description}</p>
              </div>
              <Button
                variant="outline"
                size="sm"
                className="self-start"
                onClick={(e) => {
                  e.stopPropagation();
                  void handleExport(report.id);
                }}
              >
                <Download className="w-4 h-4 mr-1.5" />
                Download CSV
              </Button>
            </div>
          ))}

          {/* Empty state */}
          {reportList.length === 0 && (
            <div className="col-span-full text-center text-text-muted py-10">
              No reports available.
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

import React, { useMemo, useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Download, Calendar } from 'lucide-react';
import { PieChart, Pie, Cell, ResponsiveContainer, Tooltip as RechartsTooltip, Legend } from 'recharts';
import { useVehicleDistribution } from '@/hooks/useMetrics';
import { useReportChart, useReportList, useExportReport } from '@/hooks/useReports';
import type { ReportRange } from '@/api/super-admin/reports';
import { CHART_COLORS } from '@/utils/chartColors';

const COLORS = CHART_COLORS;

interface ChartDataPoint {
  label?: string;
  name?: string;
  value: number;
}

interface ReportDef {
  id: string;
  title: string;
  description: string;
}

function isoDaysAgo(days: number): string {
  const d = new Date();
  d.setDate(d.getDate() - days);
  return d.toISOString().slice(0, 10);
}

function todayISO(): string {
  return new Date().toISOString().slice(0, 10);
}

export function Reports() {
  const [from, setFrom] = useState<string>(isoDaysAgo(29));
  const [to, setTo] = useState<string>(todayISO());
  const range: ReportRange = useMemo(() => ({ from, to }), [from, to]);

  const vehicleQuery = useVehicleDistribution();
  const paymentQuery = useReportChart('payment-methods', range);
  const reportsQuery = useReportList();
  const exportReport = useExportReport();

  const vehicleData = ((vehicleQuery.data ?? []) as ChartDataPoint[]).map(p => ({
    name: p.name ?? p.label ?? 'Unknown',
    value: p.value,
  }));
  const paymentData = ((paymentQuery.data ?? []) as ChartDataPoint[]).map(p => ({
    name: p.name ?? p.label ?? 'Unknown',
    value: p.value,
  }));
  const reportList = (reportsQuery.data ?? []) as ReportDef[];
  const loading = reportsQuery.isPending;

  const openExportedCsv = async (type: string) => {
    const res = await exportReport.mutateAsync({ type, range }).catch(() => null);
    if (res?.url) window.open(res.url, '_blank');
  };

  const handleExportAll = () => openExportedCsv('all');
  const handleDownload = (reportId: string) => openExportedCsv(reportId);

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h1 className="text-2xl font-bold text-text-main">Reports & Analytics</h1>
        <div className="flex gap-3">
          <div className="flex items-center gap-2 bg-surface border border-border rounded-lg px-3 py-2">
            <Calendar className="w-4 h-4 text-text-muted" />
            <input
              type="date"
              value={from}
              onChange={e => setFrom(e.target.value)}
              className="bg-transparent text-sm text-text-main outline-none"
              aria-label="From date"
            />
            <span className="text-sm text-text-muted">→</span>
            <input
              type="date"
              value={to}
              onChange={e => setTo(e.target.value)}
              className="bg-transparent text-sm text-text-main outline-none"
              aria-label="To date"
            />
          </div>
          <Button className="gap-2" onClick={handleExportAll}>
            <Download className="w-4 h-4" /> Export All
          </Button>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <Card>
          <CardHeader>
            <CardTitle>Rides by Vehicle Type</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="h-[300px]">
              {vehicleData.length === 0 ? (
                <EmptyChart loading={vehicleQuery.isPending} />
              ) : (
                <ResponsiveContainer width="100%" height="100%">
                  <PieChart>
                    <Pie
                      data={vehicleData}
                      cx="50%"
                      cy="50%"
                      innerRadius={50}
                      outerRadius={90}
                      paddingAngle={5}
                      dataKey="value"
                      label
                    >
                      {vehicleData.map((_entry, index) => (
                        <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                      ))}
                    </Pie>
                    <RechartsTooltip
                      contentStyle={{ backgroundColor: '#1E1E1E', borderColor: '#333', color: '#FFF' }}
                      itemStyle={{ color: '#FFF' }}
                    />
                    <Legend verticalAlign="bottom" height={36} />
                  </PieChart>
                </ResponsiveContainer>
              )}
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Payment Method Distribution</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="h-[300px]">
              {paymentData.length === 0 ? (
                <EmptyChart loading={paymentQuery.isPending} />
              ) : (
                <ResponsiveContainer width="100%" height="100%">
                  <PieChart>
                    <Pie
                      data={paymentData}
                      cx="50%"
                      cy="50%"
                      innerRadius={50}
                      outerRadius={90}
                      paddingAngle={5}
                      dataKey="value"
                      label
                    >
                      {paymentData.map((_entry, index) => (
                        <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                      ))}
                    </Pie>
                    <RechartsTooltip
                      contentStyle={{ backgroundColor: '#1E1E1E', borderColor: '#333', color: '#FFF' }}
                      itemStyle={{ color: '#FFF' }}
                    />
                    <Legend verticalAlign="bottom" height={36} />
                  </PieChart>
                </ResponsiveContainer>
              )}
            </div>
          </CardContent>
        </Card>

        <Card className="md:col-span-2">
          <CardHeader>
            <CardTitle>Available Reports</CardTitle>
          </CardHeader>
          <CardContent>
            {loading ? (
              <p className="text-sm text-text-muted py-4 text-center">Loading reports...</p>
            ) : reportList.length === 0 ? (
              <p className="text-sm text-text-muted py-4 text-center">No reports defined yet.</p>
            ) : (
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                {reportList.map(report => (
                  <ReportCard
                    key={report.id}
                    title={report.title}
                    description={report.description}
                    onDownload={() => handleDownload(report.id)}
                  />
                ))}
              </div>
            )}
          </CardContent>
        </Card>
      </div>
    </div>
  );
}

function EmptyChart({ loading }: { loading: boolean }) {
  return (
    <div className="h-full flex items-center justify-center text-sm text-text-muted">
      {loading ? 'Loading…' : 'No data for the selected range.'}
    </div>
  );
}

function ReportCard({ title, description, onDownload }: { title: string; description: string; onDownload: () => void }) {
  return (
    <div className="p-4 bg-surface-hover border border-border rounded-lg flex flex-col h-full">
      <h4 className="font-medium text-text-main mb-2">{title}</h4>
      <p className="text-sm text-text-muted flex-1">{description}</p>
      <Button variant="outline" size="sm" className="w-full mt-4 gap-2" onClick={onDownload}>
        <Download className="w-4 h-4" /> Download CSV
      </Button>
    </div>
  );
}

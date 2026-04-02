import React, { useEffect, useState, useCallback } from 'react';
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
} from 'recharts';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { DateRangePicker, DateRange, getDefaultRange } from '@/components/shared/DateRangePicker';
import { adminApi } from '@/lib/admin-api';

// ── Constants ─────────────────────────────────────────────────────────────────

const COLORS = ['#1A73E8', '#34A853', '#FBBC05', '#EA4335', '#9C27B0'];

const DARK_TOOLTIP = {
  contentStyle: {
    backgroundColor: '#1E1E1E',
    borderColor: '#333',
    color: '#FFF',
  },
};

// ── Types ──────────────────────────────────────────────────────────────────────

interface ReportItem {
  id: string;
  title: string;
  description: string;
}

// ── Export helper ─────────────────────────────────────────────────────────────

async function handleExport(type: string) {
  const csv = await adminApi.reports.exportCsv(type);
  const blob = new Blob([csv], { type: 'text/csv' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = `${type}-${Date.now()}.csv`;
  a.click();
  URL.revokeObjectURL(url);
}

// ── Component ─────────────────────────────────────────────────────────────────

export function SAReports() {
  const [dateRange, setDateRange] = useState<DateRange>(getDefaultRange('30d'));
  const [selectedReport, setSelectedReport] = useState<string>('weekly-financial');
  const [reportList, setReportList] = useState<ReportItem[]>([]);

  // Chart data states
  const [vehicleData, setVehicleData] = useState<{ name: string; value: number }[]>([]);
  const [paymentData, setPaymentData] = useState<{ name: string; value: number }[]>([]);
  const [waitTimeData, setWaitTimeData] = useState<{ name: string; wait: number }[]>([]);
  const [ratingsData, setRatingsData] = useState<
    { name: string; driver: number; rider: number }[]
  >([]);

  const [loading, setLoading] = useState(true);

  // ── Initial load ────────────────────────────────────────────────────────────

  useEffect(() => {
    async function initialLoad() {
      setLoading(true);
      const [list, vehicle, payment, waitTime, ratings] = await Promise.all([
        adminApi.reports.getReportList(),
        adminApi.reports.getChartData('rides-by-vehicle'),
        adminApi.reports.getChartData('payment-method'),
        adminApi.reports.getChartData('wait-time'),
        adminApi.reports.getChartData('average-ratings'),
      ]);
      setReportList(list as ReportItem[]);
      setVehicleData(vehicle as { name: string; value: number }[]);
      setPaymentData(payment as { name: string; value: number }[]);
      setWaitTimeData(waitTime as { name: string; wait: number }[]);
      setRatingsData(
        ratings as { name: string; driver: number; rider: number }[]
      );
      setLoading(false);
    }
    void initialLoad();
  }, []);

  // ── Reload chart data when selectedReport changes ───────────────────────────

  const reloadChartData = useCallback(async () => {
    await adminApi.reports.getChartData(selectedReport);
    // Additional chart-specific data can be wired here when backend ships
  }, [selectedReport]);

  useEffect(() => {
    void reloadChartData();
  }, [reloadChartData]);

  // ── Export all (header-level) ──────────────────────────────────────────────

  async function handleExportAll() {
    await handleExport(selectedReport);
  }

  // ── Render ─────────────────────────────────────────────────────────────────

  return (
    <div className="space-y-6 p-6">

      {/* Page header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <h1 className="text-2xl font-bold text-text-main">Reports & Analytics</h1>
        <div className="flex items-center gap-3 flex-wrap">
          <DateRangePicker value={dateRange} onChange={setDateRange} />
          <Button variant="outline" size="sm" onClick={handleExportAll}>
            <Download className="w-4 h-4 mr-1.5" />
            Export CSV
          </Button>
        </div>
      </div>

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
            </CardHeader>
            <CardContent>
              <ResponsiveContainer width="100%" height={260}>
                <PieChart>
                  <Pie
                    data={vehicleData}
                    dataKey="value"
                    nameKey="name"
                    innerRadius={60}
                    outerRadius={90}
                    paddingAngle={3}
                  >
                    {vehicleData.map((_, index) => (
                      <Cell
                        key={`vehicle-cell-${index}`}
                        fill={COLORS[index % COLORS.length]}
                      />
                    ))}
                  </Pie>
                  <Tooltip {...DARK_TOOLTIP} />
                  <Legend />
                </PieChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>

          {/* Chart 2 — Payment Method Distribution (Donut) */}
          <Card>
            <CardHeader>
              <CardTitle>Payment Method Distribution</CardTitle>
            </CardHeader>
            <CardContent>
              <ResponsiveContainer width="100%" height={260}>
                <PieChart>
                  <Pie
                    data={paymentData}
                    dataKey="value"
                    nameKey="name"
                    innerRadius={60}
                    outerRadius={90}
                    paddingAngle={3}
                  >
                    {paymentData.map((_, index) => (
                      <Cell
                        key={`payment-cell-${index}`}
                        fill={COLORS[index % COLORS.length]}
                      />
                    ))}
                  </Pie>
                  <Tooltip {...DARK_TOOLTIP} />
                  <Legend />
                </PieChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>

          {/* Chart 3 — Wait Time Trends (Line + ReferenceLine) */}
          <Card>
            <CardHeader>
              <CardTitle>Wait Time Trends</CardTitle>
            </CardHeader>
            <CardContent>
              <ResponsiveContainer width="100%" height={260}>
                <LineChart
                  data={waitTimeData}
                  margin={{ top: 8, right: 16, left: 0, bottom: 0 }}
                >
                  <CartesianGrid strokeDasharray="3 3" stroke="#333" />
                  <XAxis
                    dataKey="name"
                    tick={{ fill: '#9CA3AF', fontSize: 12 }}
                    axisLine={false}
                    tickLine={false}
                  />
                  <YAxis
                    tick={{ fill: '#9CA3AF', fontSize: 12 }}
                    axisLine={false}
                    tickLine={false}
                    unit=" min"
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
                    type="monotone"
                    dataKey="wait"
                    stroke="#1A73E8"
                    strokeWidth={2}
                    dot={false}
                    activeDot={{ r: 4 }}
                  />
                </LineChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>

          {/* Chart 4 — Average Ratings (Line, driver + rider) */}
          <Card>
            <CardHeader>
              <CardTitle>Average Ratings</CardTitle>
            </CardHeader>
            <CardContent>
              <ResponsiveContainer width="100%" height={260}>
                <LineChart
                  data={ratingsData}
                  margin={{ top: 8, right: 16, left: 0, bottom: 0 }}
                >
                  <CartesianGrid strokeDasharray="3 3" stroke="#333" />
                  <XAxis
                    dataKey="name"
                    tick={{ fill: '#9CA3AF', fontSize: 12 }}
                    axisLine={false}
                    tickLine={false}
                  />
                  <YAxis
                    tick={{ fill: '#9CA3AF', fontSize: 12 }}
                    axisLine={false}
                    tickLine={false}
                    domain={[1, 5]}
                  />
                  <Tooltip {...DARK_TOOLTIP} />
                  <Legend />
                  <Line
                    type="monotone"
                    dataKey="driver"
                    name="Driver Rating"
                    stroke="#1A73E8"
                    strokeWidth={2}
                    dot={false}
                    activeDot={{ r: 4 }}
                  />
                  <Line
                    type="monotone"
                    dataKey="rider"
                    name="Rider Rating"
                    stroke="#34A853"
                    strokeWidth={2}
                    dot={false}
                    activeDot={{ r: 4 }}
                  />
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

import React, { useMemo, useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/Table';
import { Badge } from '@/components/ui/Badge';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Download, Wallet, ArrowUpRight, ArrowDownRight, CheckCircle, Search, Lock } from 'lucide-react';
import { formatPHP } from '@/lib/utils';
import { usePermissions } from '@/hooks/usePermissions';
import {
  usePaymentSummary, useTransactions, usePayouts, useApprovePayout,
} from '@/hooks/usePayments';
import { useExportReport } from '@/hooks/useReports';
import { useIsCashlessEnabled } from '@/hooks/useSystem';

const CASHLESS_METHODS = new Set(['gcash', 'paymaya', 'card']);
import type { Transaction, DriverPayout } from '@/types/super-admin';
import { DateRangePicker, getDefaultRange, type DateRange } from '@/components/shared/DateRangePicker';
import { ConfirmModal } from '@/components/shared/ConfirmModal';
import { PaginationFooter } from '@/components/shared/PaginationFooter';

const TRANSACTIONS_PER_PAGE = 20;

function toIsoDate(d: Date): string {
  // YYYY-MM-DD in local time so the backend treats the lower/upper bound as
  // the admin's calendar day, not UTC-shifted.
  const y = d.getFullYear();
  const m = String(d.getMonth() + 1).padStart(2, '0');
  const day = String(d.getDate()).padStart(2, '0');
  return `${y}-${m}-${day}`;
}

function txnStatusVariant(status: string): 'success' | 'warning' | 'danger' | 'default' {
  switch (status) {
    case 'settled': return 'success';
    case 'pending': return 'warning';
    case 'failed':
    case 'refunded': return 'danger';
    default: return 'default';
  }
}

function paymentMethodLabel(method: string): string {
  switch (method) {
    case 'gcash': return 'GCash';
    case 'paymaya': return 'PayMaya';
    case 'card': return 'Card';
    case 'cash': return 'Cash';
    default: return method;
  }
}

export function Payments() {
  const { can } = usePermissions();
  const canWrite = can('payments', 'write');
  const canExportReports = can('reports', 'read');
  const writeDisabledTitle = canWrite ? undefined : 'You do not have write access';
  const exportDisabledTitle = canExportReports ? undefined : 'You do not have reports access';
  const [search, setSearch] = useState('');
  const [range, setRange] = useState<DateRange>(() => getDefaultRange('30d'));
  const [page, setPage] = useState(1);
  const [payoutConfirm, setPayoutConfirm] = useState<{ open: boolean; payout: DriverPayout | null }>({ open: false, payout: null });
  const summaryQuery = usePaymentSummary();
  const transactionsQuery = useTransactions({
    from: toIsoDate(range.from),
    to: toIsoDate(range.to),
  });
  const payoutsQuery = usePayouts();
  const approvePayout = useApprovePayout();
  const exportReport = useExportReport();

  const transactions = (transactionsQuery.data ?? []) as Transaction[];
  const payouts = (payoutsQuery.data ?? []) as DriverPayout[];
  const summary = summaryQuery.data;
  const loading = summaryQuery.isPending || transactionsQuery.isPending || payoutsQuery.isPending;
  const cashlessEnabled = useIsCashlessEnabled();

  const openPayoutConfirm = (payout: DriverPayout) => {
    setPayoutConfirm({ open: true, payout });
  };

  const confirmApprovePayout = () => {
    if (payoutConfirm.payout) approvePayout.mutate(payoutConfirm.payout.id);
    setPayoutConfirm({ open: false, payout: null });
  };

  const handleExport = async () => {
    const res = await exportReport.mutateAsync({ type: 'financial' }).catch(() => null);
    if (res?.url) window.open(res.url, '_blank');
  };

  const q = search.toLowerCase();
  const fromMs = useMemo(() => {
    const d = new Date(range.from);
    d.setHours(0, 0, 0, 0);
    return d.getTime();
  }, [range.from]);
  const toMs = useMemo(() => {
    const d = new Date(range.to);
    d.setHours(23, 59, 59, 999);
    return d.getTime();
  }, [range.to]);

  const filtered = useMemo(() => {
    return transactions.filter(txn => {
      if (!cashlessEnabled && CASHLESS_METHODS.has(txn.payment_method)) return false;
      if (q) {
        const matchesSearch =
          txn.id.toLowerCase().includes(q) ||
          (txn.ride_id ?? '').toLowerCase().includes(q) ||
          (txn.rider_name ?? '').toLowerCase().includes(q) ||
          (txn.driver_name ?? '').toLowerCase().includes(q) ||
          txn.payment_method.toLowerCase().includes(q) ||
          txn.status.toLowerCase().includes(q);
        if (!matchesSearch) return false;
      }
      if (!txn.created_at) return true;
      const ts = new Date(txn.created_at).getTime();
      return ts >= fromMs && ts <= toMs;
    });
  }, [transactions, q, fromMs, toMs, cashlessEnabled]);

  const pageCount = Math.max(1, Math.ceil(filtered.length / TRANSACTIONS_PER_PAGE));
  const clampedPage = Math.min(page, pageCount);
  const paginated = filtered.slice(
    (clampedPage - 1) * TRANSACTIONS_PER_PAGE,
    clampedPage * TRANSACTIONS_PER_PAGE,
  );

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap justify-between items-center gap-3">
        <h1 className="text-2xl font-bold text-text-main">Payments & Earnings</h1>
        <div className="flex flex-wrap items-center gap-2">
          <DateRangePicker value={range} onChange={(r) => { setRange(r); setPage(1); }} />
          <Button
            variant="outline"
            className="gap-2"
            onClick={handleExport}
            disabled={!canExportReports}
            title={exportDisabledTitle}
          >
            <Download className="w-4 h-4" /> Export Weekly Report
          </Button>
        </div>
      </div>

      {!cashlessEnabled && (
        <div
          role="status"
          className="flex items-start gap-2 p-3 bg-danger/10 border border-danger/20 rounded-lg"
        >
          <Lock className="w-4 h-4 text-danger flex-shrink-0 mt-0.5" />
          <p className="text-sm text-danger">
            Cashless payments are disabled. Showing cash transactions only. Toggle the
            <strong> cashless_payments </strong>
            flag in System Config &rarr; Feature Flags to re-enable.
          </p>
        </div>
      )}

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-2 gap-6">
        <SummaryCard
          title="Total Revenue (30d)"
          amount={summary ? formatPHP(summary.total_revenue ?? 0) : '—'}
          icon={<Wallet className="w-5 h-5 text-primary" />}
        />
        <SummaryCard
          title="Driver Payouts (30d)"
          amount={summary ? formatPHP(summary.payouts ?? 0) : '—'}
          icon={<ArrowUpRight className="w-5 h-5 text-danger" />}
        />
        <SummaryCard
          title="Platform Commission"
          amount={summary ? formatPHP(summary.commission ?? 0) : '—'}
          icon={<ArrowDownRight className="w-5 h-5 text-success" />}
        />
        <SummaryCard
          title="Pending Settlements"
          amount={summary ? formatPHP(summary.pending_settlements ?? 0) : '—'}
          icon={<CheckCircle className="w-5 h-5 text-warning" />}
        />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <Card className="lg:col-span-2">
          <CardHeader className="flex flex-row items-center justify-between gap-4 flex-wrap">
            <CardTitle>Recent Transactions</CardTitle>
            <div className="w-full sm:w-56">
              <Input
                placeholder="Search transactions..."
                icon={<Search className="w-4 h-4" />}
                value={search}
                onChange={(e) => setSearch(e.target.value)}
              />
            </div>
          </CardHeader>
          <CardContent className="p-0 overflow-x-auto">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Transaction ID</TableHead>
                  <TableHead>Rider / Driver</TableHead>
                  <TableHead>Amount</TableHead>
                  <TableHead>Method</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead>Date</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {loading ? (
                  <TableRow>
                    <TableCell colSpan={6} className="text-center py-10 text-text-muted">Loading...</TableCell>
                  </TableRow>
                ) : filtered.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={6} className="text-center py-10 text-text-muted">
                      No transactions match your search.
                    </TableCell>
                  </TableRow>
                ) : paginated.map((txn) => (
                  <TableRow key={txn.id}>
                    <TableCell>
                      <p className="font-medium text-text-main">{txn.id}</p>
                      {txn.ride_id && <p className="text-xs text-text-muted">Ride: {txn.ride_id}</p>}
                    </TableCell>
                    <TableCell>
                      <div className="space-y-0.5">
                        {txn.rider_name && <p className="text-xs"><span className="text-text-muted">R:</span> {txn.rider_name}</p>}
                        {txn.driver_name && <p className="text-xs"><span className="text-text-muted">D:</span> {txn.driver_name}</p>}
                      </div>
                    </TableCell>
                    <TableCell className="font-medium text-success">
                      {formatPHP(txn.amount)}
                    </TableCell>
                    <TableCell>{paymentMethodLabel(txn.payment_method)}</TableCell>
                    <TableCell>
                      <Badge variant={txnStatusVariant(txn.status)}>
                        {txn.status.charAt(0).toUpperCase() + txn.status.slice(1)}
                      </Badge>
                    </TableCell>
                    <TableCell className="text-sm text-text-muted">
                      {txn.created_at ? new Date(txn.created_at).toLocaleString('en-PH', { dateStyle: 'short', timeStyle: 'short' }) : '—'}
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
            <PaginationFooter
              meta={{
                current_page: clampedPage,
                limit: TRANSACTIONS_PER_PAGE,
                total_items: filtered.length,
                total_pages: pageCount,
              }}
              page={clampedPage}
              onPageChange={setPage}
              label="transactions"
              className="flex items-center justify-between px-4 md:px-6 py-3 border-t border-border text-sm text-text-muted"
            />
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Pending Driver Payouts</CardTitle>
          </CardHeader>
          <CardContent>
            {loading ? (
              <p className="text-sm text-text-muted text-center py-6">Loading...</p>
            ) : payouts.length === 0 ? (
              <p className="text-sm text-text-muted text-center py-6">No pending payouts.</p>
            ) : (
              <div className="space-y-4">
                <p className="text-sm text-text-muted">Approve weekly payouts for drivers who have reached the minimum threshold.</p>
                {payouts.map(payout => (
                  <div key={payout.id} className="bg-surface-hover p-4 rounded-lg border border-border flex justify-between items-center">
                    <div>
                      <p className="text-sm font-medium">Batch {payout.batch}</p>
                      <p className="text-xs text-text-muted">{payout.driver_count} Drivers • {formatPHP(payout.total_amount)}</p>
                      {payout.period && <p className="text-xs text-text-muted">{payout.period}</p>}
                    </div>
                    <Button
                      size="sm"
                      onClick={() => openPayoutConfirm(payout)}
                      disabled={!canWrite}
                      title={writeDisabledTitle}
                    >
                      Approve
                    </Button>
                  </div>
                ))}
              </div>
            )}
          </CardContent>
        </Card>
      </div>

      <ConfirmModal
        open={payoutConfirm.open}
        title="Approve payout?"
        message={
          payoutConfirm.payout
            ? `Approve batch ${payoutConfirm.payout.batch} — ${payoutConfirm.payout.driver_count} drivers · ${formatPHP(payoutConfirm.payout.total_amount ?? 0)}?`
            : ''
        }
        confirmLabel="Approve"
        variant="success"
        onConfirm={confirmApprovePayout}
        onClose={() => setPayoutConfirm({ open: false, payout: null })}
      />
    </div>
  );
}

function SummaryCard({ title, amount, icon }: { title: string; amount: string; icon: React.ReactNode }) {
  return (
    <Card>
      <CardContent className="p-5 flex flex-col justify-between h-full">
        <div className="flex justify-between items-start mb-4">
          <p className="text-sm font-medium text-text-muted">{title}</p>
          <div className="p-2 bg-surface-hover rounded-lg flex items-center justify-center flex-shrink-0">
            {icon}
          </div>
        </div>
        <div>
          <h4 className="text-2xl sm:text-3xl font-bold text-text-main tracking-tight leading-none break-words">
            {amount}
          </h4>
        </div>
      </CardContent>
    </Card>
  );
}

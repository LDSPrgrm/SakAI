import React, { useState } from 'react';
import {
  Wallet,
  ArrowUpRight,
  ArrowDownRight,
  Clock,
  Search,
  Download,
} from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/Table';
import { Badge } from '@/components/ui/Badge';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { ConfirmModal } from '@/components/shared/ConfirmModal';
import { SummaryCard } from '@/components/shared/SummaryCard';
import { StatusBadge } from '@/components/shared/StatusBadge';
import type { PaymentSummary } from '@/api/super-admin/payments';
import {
  useTransactions, usePayouts, usePaymentSummary,
  useCommissionConfig, useApprovePayout,
  useBatchApprovePayouts, useUpdateCommissionConfig,
} from '@/hooks/usePayments';
import { useUpdateIntegration } from '@/hooks/useSystem';
import type { Transaction, DriverPayout, PaymentMethod } from '@/types/super-admin';
import { formatPHP } from '@/lib/utils';
import {
  GatewayProvidersSection, type GatewayProvider,
} from '@/components/super-admin/payments/GatewayProvidersSection';
import { CommissionConfigCard } from '@/components/super-admin/payments/CommissionConfigCard';

interface ConfirmState {
  open: boolean;
  payoutId: string;
  batchName: string;
}

// ── Helpers ───────────────────────────────────────────────────────────────────

function methodVariant(method: PaymentMethod): 'info' | 'warning' | 'default' {
  if (method === 'gcash') return 'info';
  if (method === 'paymaya') return 'warning';
  return 'default';
}

// ── Component ─────────────────────────────────────────────────────────────────

export function SAPayments() {
  const transactionsQuery = useTransactions();
  const payoutsQuery = usePayouts();
  const summaryQuery = usePaymentSummary();
  const commissionQuery = useCommissionConfig();
  const approvePayout = useApprovePayout();
  const batchApprovePayouts = useBatchApprovePayouts();
  const updateCommissionConfig = useUpdateCommissionConfig();
  const updateIntegration = useUpdateIntegration();

  const transactions = (transactionsQuery.data ?? []) as Transaction[];
  const payouts = (payoutsQuery.data ?? []) as DriverPayout[];
  const summary: PaymentSummary = summaryQuery.data ?? {
    total_revenue: 0,
    payouts: 0,
    commission: 0,
    pending_settlements: 0,
  };

  const [search, setSearch] = useState('');
  const [confirmModal, setConfirmModal] = useState<ConfirmState>({
    open: false,
    payoutId: '',
    batchName: '',
  });
  const [providers, setProviders] = useState<GatewayProvider[]>([]);
  const savingCommission = updateCommissionConfig.isPending;

  const [selectedPayoutIds, setSelectedPayoutIds] = useState<Set<string>>(new Set());
  const batchApproving = batchApprovePayouts.isPending;

  // ── Filtered transactions ──────────────────────────────────────────────────

  const filtered = transactions.filter((t) => {
    const q = search.toLowerCase();
    return (
      (t.id ?? '').toLowerCase().includes(q) ||
      (t.ride_id ?? '').toLowerCase().includes(q) ||
      (t.rider_name ?? '').toLowerCase().includes(q) ||
      (t.driver_name ?? '').toLowerCase().includes(q)
    );
  });

  // ── Payout approval ───────────────────────────────────────────────────────

  function openApproveModal(payout: DriverPayout) {
    setConfirmModal({ open: true, payoutId: payout.id, batchName: payout.batch });
  }

  async function handleApprovePayout() {
    await approvePayout.mutateAsync(confirmModal.payoutId);
  }

  async function handleBatchApprove() {
    const ids = [...selectedPayoutIds];
    try {
      await batchApprovePayouts.mutateAsync(ids);
      setSelectedPayoutIds(new Set());
    } catch {
      // Error surfaced via batchApprovePayouts.isError / .error in the UI.
    }
  }

  // ── Gateway provider helpers ───────────────────────────────────────────────

  async function saveProvider(provider: GatewayProvider) {
    const fields: Record<string, string> = {};
    if (provider.apiKey) fields.api_key = provider.apiKey;
    if (provider.secret) fields.secret = provider.secret;
    if (provider.merchantId) fields.merchant_id = provider.merchantId;
    if (provider.webhookUrl) fields.webhook_url = provider.webhookUrl;
    if (provider.publishableKey) fields.publishable_key = provider.publishableKey;
    if (provider.secretKey) fields.secret_key = provider.secretKey;
    if (provider.webhookSecret) fields.webhook_secret = provider.webhookSecret;
    await updateIntegration.mutateAsync({ service: provider.id, data: fields }).catch(() => {});
  }

  async function saveCommission(values: Parameters<typeof updateCommissionConfig.mutateAsync>[0]) {
    await updateCommissionConfig.mutateAsync(values).catch(() => {});
  }

  // ── CSV download ───────────────────────────────────────────────────────────

  function downloadCsv() {
    const headers = 'Transaction ID,Ride ID,Rider,Driver,Amount,Commission,Method,Status,Date\n';
    const rows = filtered
      .map(
        (t) =>
          `${t.id},${t.ride_id},${t.rider_name},${t.driver_name},${t.amount},${t.commission},${t.payment_method},${t.status},${t.created_at}`
      )
      .join('\n');
    const blob = new Blob([headers + rows], { type: 'text/csv' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `transactions-${Date.now()}.csv`;
    a.click();
    URL.revokeObjectURL(url);
  }

  // ── Render ─────────────────────────────────────────────────────────────────

  return (
    <div className="space-y-6 p-6">

      {/* Page title */}
      <h1 className="text-2xl font-bold text-text-main">Payments</h1>

      {/* Section 1 — Summary cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
        <SummaryCard
          title="Total Revenue"
          value={formatPHP(summary.total_revenue ?? 0)}
          icon={<Wallet className="w-5 h-5 text-primary" />}
        />
        <SummaryCard
          title="Driver Payouts"
          value={formatPHP(summary.payouts ?? 0)}
          icon={<ArrowUpRight className="w-5 h-5 text-danger" />}
        />
        <SummaryCard
          title="Platform Commission"
          value={formatPHP(summary.commission ?? 0)}
          icon={<ArrowDownRight className="w-5 h-5 text-success" />}
        />
        <SummaryCard
          title="Pending Settlements"
          value={formatPHP(summary.pending_settlements ?? 0)}
          icon={<Clock className="w-5 h-5 text-warning" />}
        />
      </div>

      {/* Section 2 — Transaction History + Pending Driver Payouts */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">

        {/* Transaction History */}
        <Card className="lg:col-span-2">
          <CardHeader>
            <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3">
              <CardTitle>Transaction History</CardTitle>
              <div className="flex items-center gap-2">
                <Input
                  placeholder="Search transactions..."
                  value={search}
                  onChange={(e) => setSearch(e.target.value)}
                  icon={<Search className="w-4 h-4" />}
                  className="w-52"
                />
                <Button variant="outline" size="sm" onClick={downloadCsv}>
                  <Download className="w-4 h-4 mr-1.5" />
                  Download
                </Button>
              </div>
            </div>
          </CardHeader>
          <CardContent className="p-0">
            <div className="overflow-x-auto">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Transaction</TableHead>
                    <TableHead>Parties</TableHead>
                    <TableHead className="text-right">Amount</TableHead>
                    <TableHead className="text-right">Commission</TableHead>
                    <TableHead>Method</TableHead>
                    <TableHead>Status</TableHead>
                    <TableHead>Date</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {filtered.length === 0 ? (
                    <TableRow>
                      <TableCell
                        colSpan={6}
                        className="text-center text-text-muted py-10"
                      >
                        No transactions found.
                      </TableCell>
                    </TableRow>
                  ) : (
                    filtered.map((t) => (
                      <TableRow key={t.id}>
                        {/* Transaction ID + Ride ID */}
                        <TableCell>
                          <span className="text-sm font-medium text-text-main">
                            {t.id}
                          </span>
                          <br />
                          <span className="text-xs text-text-muted">
                            Ride {t.ride_id}
                          </span>
                        </TableCell>

                        {/* Rider + Driver names */}
                        <TableCell>
                          <span className="text-sm text-text-main">
                            {t.rider_name ?? '—'}
                          </span>
                          <br />
                          <span className="text-xs text-text-muted">
                            {t.driver_name ?? '—'}
                          </span>
                        </TableCell>

                        {/* Amount — positive = success, negative = danger */}
                        <TableCell className="text-right">
                          <span
                            className={
                              t.amount >= 0
                                ? 'text-success font-medium'
                                : 'text-danger font-medium'
                            }
                          >
                            {t.amount >= 0 ? '+' : ''}
                            {formatPHP(t.amount)}
                          </span>
                        </TableCell>

                        {/* Commission */}
                        <TableCell className="text-right text-sm text-text-muted">
                          {formatPHP(t.commission)}
                        </TableCell>

                        {/* Payment Method */}
                        <TableCell>
                          {t.payment_method ? (
                            <Badge variant={methodVariant(t.payment_method)}>
                              {t.payment_method.toUpperCase()}
                            </Badge>
                          ) : '—'}
                        </TableCell>

                        {/* Status */}
                        <TableCell>
                          <StatusBadge status={t.status} />
                        </TableCell>

                        {/* Date */}
                        <TableCell className="text-sm text-text-muted whitespace-nowrap">
                          {t.created_at
                            ? new Date(t.created_at).toLocaleDateString('en-PH', {
                              month: 'short',
                              day: 'numeric',
                              year: 'numeric',
                            })
                            : '—'}
                        </TableCell>
                      </TableRow>
                    ))
                  )}
                </TableBody>
              </Table>
            </div>
          </CardContent>
        </Card>

        {/* Pending Driver Payouts */}
        <Card>
          <CardHeader>
            <div className="flex items-center justify-between gap-2">
              <CardTitle>Pending Driver Payouts</CardTitle>
              {selectedPayoutIds.size > 0 && (
                <Button
                  variant="success"
                  size="sm"
                  onClick={handleBatchApprove}
                  disabled={batchApproving}
                >
                  {batchApproving ? 'Approving…' : `Approve Selected (${selectedPayoutIds.size})`}
                </Button>
              )}
            </div>
          </CardHeader>
          <CardContent className="space-y-3">
            {payouts.length === 0 ? (
              <p className="text-sm text-text-muted text-center py-6">
                No payouts found.
              </p>
            ) : (
              payouts.map((payout) => (
                <div
                  key={payout.id}
                  className="p-3 bg-surface-hover rounded-lg border border-border space-y-2"
                >
                  <div className="flex items-start justify-between gap-2">
                    <div className="flex items-center gap-2 min-w-0">
                      {payout.status === 'pending' && (
                        <input
                          type="checkbox"
                          className="w-4 h-4 flex-shrink-0 rounded border-border accent-primary"
                          checked={selectedPayoutIds.has(payout.id)}
                          onChange={(e) => {
                            setSelectedPayoutIds((prev) => {
                              const next = new Set(prev);
                              if (e.target.checked) next.add(payout.id);
                              else next.delete(payout.id);
                              return next;
                            });
                          }}
                          aria-label={`Select payout ${payout.batch}`}
                        />
                      )}
                      <span className="text-sm font-medium text-text-main">
                        {payout.batch}
                      </span>
                    </div>
                    <StatusBadge status={payout.status} />
                  </div>
                  <p className="text-xs text-text-muted">
                    {payout.driver_count} drivers &middot;{' '}
                    {formatPHP(payout.total_amount)}
                  </p>
                  {payout.status === 'pending' && (
                    <Button
                      variant="success"
                      size="sm"
                      className="w-full"
                      onClick={() => openApproveModal(payout)}
                    >
                      Approve Payout
                    </Button>
                  )}
                </div>
              ))
            )}
          </CardContent>
        </Card>
      </div>

      {/* Section 3 & 4 Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <GatewayProvidersSection
          providers={providers}
          onChange={setProviders}
          onSave={saveProvider}
        />
        <CommissionConfigCard
          config={commissionQuery.data}
          onSave={saveCommission}
          saving={savingCommission}
        />
      </div>

      {/* Approve Payout Confirm Modal */}
      <ConfirmModal
        open={confirmModal.open}
        title="Approve Payout"
        message={`Are you sure you want to approve the payout batch "${confirmModal.batchName}"? This action cannot be undone.`}
        variant="success"
        confirmLabel="Approve"
        onConfirm={handleApprovePayout}
        onClose={() => setConfirmModal((s) => ({ ...s, open: false }))}
      />
    </div>
  );
}

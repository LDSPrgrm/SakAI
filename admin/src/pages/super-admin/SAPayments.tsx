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
import { Checkbox } from '@/components/ui/Checkbox';
import { ConfirmationModal } from '@/components/shared/ConfirmationModal';
import { EntityId } from '@/components/ui/EntityId';
import { SummaryCard } from '@/components/shared/SummaryCard';
import { StatusBadge } from '@/components/shared/StatusBadge';
import { PageHeader } from '@/components/shared/PageHeader';
import type { PaymentSummary } from '@/api/super-admin/payments';
import {
  useTransactions, usePayouts, usePaymentSummary,
  useCommissionConfig, useApprovePayout,
  useBatchApprovePayouts, useUpdateCommissionConfig,
  useGatewayConfigs, useUpdatePaymentConfig,
} from '@/hooks/usePayments';
import type { Transaction, DriverPayout, PaymentMethod } from '@/types/super-admin';
import { formatPHP } from '@/lib/utils';
import { csvRow } from '@/utils/csv';
import { CommissionConfigCard } from '@/components/super-admin/payments/CommissionConfigCard';
import { GatewayProvidersSection } from '@/components/super-admin/payments/GatewayProvidersSection';
import { TransactionDetailModal } from '@/components/super-admin/modals/TransactionDetailModal';

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
  const gatewayQuery = useGatewayConfigs();
  const approvePayout = useApprovePayout();
  const batchApprovePayouts = useBatchApprovePayouts();
  const updateCommissionConfig = useUpdateCommissionConfig();
  const updatePaymentConfig = useUpdatePaymentConfig();

  const gatewayConfigs = gatewayQuery.data ?? [];

  async function saveGatewayConfig(provider: string, payload: { config_fields: Record<string, string>; is_active: boolean }) {
    await updatePaymentConfig.mutateAsync({ provider, payload });
  }

  const transactions = (transactionsQuery.data ?? []) as Transaction[];
  const payouts = (payoutsQuery.data ?? []) as DriverPayout[];
  const summary: PaymentSummary = summaryQuery.data ?? {
    total_revenue: 0,
    payouts: 0,
    commission: 0,
    pending_settlements: 0,
  };

  const [search, setSearch] = useState('');
  const [selectedTxn, setSelectedTxn] = useState<Transaction | null>(null);
  const [confirmModal, setConfirmModal] = useState<ConfirmState>({
    open: false,
    payoutId: '',
    batchName: '',
  });
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

  async function saveCommission(values: Parameters<typeof updateCommissionConfig.mutateAsync>[0]) {
    await updateCommissionConfig.mutateAsync(values).catch(() => {});
  }

  // ── CSV download ───────────────────────────────────────────────────────────

  function downloadCsv() {
    const header = csvRow([
      'Transaction ID', 'Ride ID', 'Rider', 'Driver',
      'Amount', 'Commission', 'Method', 'Status', 'Date',
    ]);
    const rows = filtered.map((t) =>
      csvRow([
        t.id, t.ride_id, t.rider_name, t.driver_name,
        t.amount, t.commission, t.payment_method, t.status, t.created_at,
      ]),
    );
    const blob = new Blob([[header, ...rows].join('\n')], { type: 'text/csv' });
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

      <PageHeader title="Financial Controls" />

      {/* Section 1 — Summary cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
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
      <div className="space-y-6">

        {/* Transaction History */}
        <Card>
          <CardHeader>
            <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3">
              <CardTitle>Transaction History</CardTitle>
              <div className="flex items-center gap-2">
                <Input
                  placeholder="Search transactions..."
                  value={search}
                  onChange={(e) => setSearch(e.target.value)}
                  icon={<Search className="w-4 h-4" />}
                  className="w-full sm:w-72 lg:w-80"
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
                  {transactionsQuery.isPending && filtered.length === 0 ? (
                    Array.from({ length: 4 }).map((_, i) => (
                      <TableRow key={`txn-skel-${i}`}>
                        <TableCell colSpan={7} className="py-3">
                          <div className="h-4 bg-surface-hover rounded animate-pulse" />
                        </TableCell>
                      </TableRow>
                    ))
                  ) : filtered.length === 0 ? (
                    <TableRow>
                      <TableCell
                        colSpan={7}
                        className="text-center text-text-muted py-10"
                      >
                        No transactions found.
                      </TableCell>
                    </TableRow>
                  ) : (
                    filtered.map((t) => (
                      <TableRow
                        key={t.id}
                        className="cursor-pointer hover:bg-surface-hover/80"
                        onClick={() => setSelectedTxn(t)}
                      >
                        {/* Transaction ID + Ride ID */}
                        <TableCell className="whitespace-nowrap">
                          <div className="flex flex-col items-start gap-1">
                            <EntityId displayId={(t as any).display_id} uuid={t.id} fallbackPrefix="TXN" />
                            <EntityId displayId={(t as any).ride_display_id} uuid={t.ride_id} fallbackPrefix="RIDE" />
                          </div>
                        </TableCell>

                        {/* Rider + Driver names */}
                        <TableCell className="whitespace-nowrap">
                          <span className="block text-sm text-text-main truncate max-w-[12rem]">
                            {t.rider_name ?? '—'}
                          </span>
                          <span className="block text-xs text-text-muted truncate max-w-[12rem]">
                            {t.driver_name ?? '—'}
                          </span>
                        </TableCell>

                        {/* Amount — positive = success, negative = danger */}
                        <TableCell className="text-right whitespace-nowrap">
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
                        <TableCell className="text-right text-sm text-text-muted whitespace-nowrap">
                          {formatPHP(t.commission)}
                        </TableCell>

                        {/* Payment Method */}
                        <TableCell className="whitespace-nowrap">
                          {t.payment_method ? (
                            <Badge variant={methodVariant(t.payment_method)}>
                              {t.payment_method.toUpperCase()}
                            </Badge>
                          ) : '—'}
                        </TableCell>

                        {/* Status */}
                        <TableCell className="whitespace-nowrap">
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
          <CardContent className="p-0">
            {(() => {
              const pendingIds = payouts
                .filter((p) => p.status === 'pending')
                .map((p) => p.id);
              const allSelected =
                pendingIds.length > 0 &&
                pendingIds.every((id) => selectedPayoutIds.has(id));
              const someSelected =
                pendingIds.some((id) => selectedPayoutIds.has(id)) && !allSelected;

              return (
                <>
                  {/* Column header strip — visible only when there are payouts */}
                  {payouts.length > 0 && (
                    <div className="flex items-center gap-4 px-6 py-3 border-b border-border text-xs uppercase tracking-wide text-text-muted">
                      <div className="w-5 flex-shrink-0">
                        <Checkbox
                          disabled={pendingIds.length === 0}
                          checked={allSelected}
                          indeterminate={someSelected}
                          onCheckedChange={(checked) => {
                            setSelectedPayoutIds(
                              checked ? new Set(pendingIds) : new Set(),
                            );
                          }}
                          aria-label="Select all pending payouts"
                        />
                      </div>
                      <div className="flex-1">Batch / Period</div>
                      <div className="w-20 text-right">Drivers</div>
                      <div className="w-32 text-right">Amount</div>
                      <div className="w-24 text-center">Status</div>
                      <div className="w-28" aria-hidden />
                    </div>
                  )}

                  {payoutsQuery.isPending && payouts.length === 0 ? (
                    <div className="space-y-3 p-6">
                      {Array.from({ length: 3 }).map((_, i) => (
                        <div
                          key={`payout-skel-${i}`}
                          className="h-10 bg-surface-hover rounded animate-pulse"
                        />
                      ))}
                    </div>
                  ) : payouts.length === 0 ? (
                    <p className="text-center text-text-muted py-10">
                      No payouts found.
                    </p>
                  ) : (
                    <ul className="divide-y divide-border">
                      {payouts.map((payout) => (
                        <li
                          key={payout.id}
                          className="flex items-center gap-4 px-6 py-4 hover:bg-surface-hover/40 transition-colors"
                        >
                          <div className="w-5 flex-shrink-0">
                            {payout.status === 'pending' ? (
                              <Checkbox
                                checked={selectedPayoutIds.has(payout.id)}
                                onCheckedChange={(checked) => {
                                  setSelectedPayoutIds((prev) => {
                                    const next = new Set(prev);
                                    if (checked) next.add(payout.id);
                                    else next.delete(payout.id);
                                    return next;
                                  });
                                }}
                                aria-label={`Select payout ${payout.batch}`}
                              />
                            ) : null}
                          </div>

                          <div className="flex-1 min-w-0">
                            <p className="text-sm font-medium text-text-main truncate">
                              {payout.batch}
                            </p>
                            {payout.period && (
                              <p className="text-xs text-text-muted truncate">
                                {payout.period}
                              </p>
                            )}
                          </div>

                          <div className="w-20 text-right text-sm text-text-muted whitespace-nowrap">
                            {payout.driver_count}
                          </div>

                          <div className="w-32 text-right text-sm font-semibold text-text-main whitespace-nowrap">
                            {formatPHP(payout.total_amount)}
                          </div>

                          <div className="w-24 flex justify-center">
                            <StatusBadge status={payout.status} />
                          </div>

                          <div className="w-28 flex justify-end">
                            {payout.status === 'pending' ? (
                              <Button
                                variant="success"
                                size="sm"
                                onClick={() => openApproveModal(payout)}
                              >
                                Approve
                              </Button>
                            ) : (
                              <span className="text-xs text-text-muted" aria-hidden>—</span>
                            )}
                          </div>
                        </li>
                      ))}
                    </ul>
                  )}
                </>
              );
            })()}
          </CardContent>
        </Card>
      </div>

      {/* Section 3 — Commission Config */}
      <CommissionConfigCard
        config={commissionQuery.data}
        onSave={saveCommission}
        saving={savingCommission}
      />

      {/* Section 4 — Payment Gateway Providers */}
      <GatewayProvidersSection
        configs={gatewayConfigs}
        onSave={saveGatewayConfig}
      />

      <TransactionDetailModal
        open={Boolean(selectedTxn)}
        transaction={selectedTxn}
        onClose={() => setSelectedTxn(null)}
      />

      {/* Approve Payout Confirm Modal */}
      <ConfirmationModal
        open={confirmModal.open}
        title="Approve Payout"
        description={`Are you sure you want to approve the payout batch "${confirmModal.batchName}"? This action cannot be undone.`}
        variant="success"
        confirmLabel="Approve"
        onConfirm={() => {
          handleApprovePayout();
          setConfirmModal((s) => ({ ...s, open: false }));
        }}
        onCancel={() => setConfirmModal((s) => ({ ...s, open: false }))}
      />
    </div>
  );
}

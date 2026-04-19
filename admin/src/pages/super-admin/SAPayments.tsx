import React, { useEffect, useState } from 'react';
import {
  Wallet,
  ArrowUpRight,
  ArrowDownRight,
  Clock,
  AlertCircle,
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
import { paymentsApi, type PaymentSummary } from '@/api/super-admin/payments';
import { systemApi } from '@/api/super-admin/system';
import type { Transaction, DriverPayout, PaymentMethod } from '@/types/super-admin';
import { formatPHP } from '@/lib/utils';

interface GatewayProvider {
  id: string;
  label: string;
  type: 'ewallet' | 'card';
  apiKey?: string;
  secret?: string;
  merchantId?: string;
  webhookUrl?: string;
  publishableKey?: string;
  secretKey?: string;
  webhookSecret?: string;
}

interface ConfirmState {
  open: boolean;
  payoutId: string;
  batchName: string;
}

// ── Helpers ───────────────────────────────────────────────────────────────────

function maskKey(k?: string): string {
  if (!k || k.length <= 4) return k || '';
  return '••••••••' + k.slice(-4);
}

function methodVariant(method: PaymentMethod): 'info' | 'warning' | 'default' {
  if (method === 'gcash') return 'info';
  if (method === 'paymaya') return 'warning';
  return 'default';
}

const DEFAULT_PROVIDERS: GatewayProvider[] = [
  {
    id: 'gcash',
    label: 'GCash',
    type: 'ewallet',
    apiKey: 'gcash_live_xK9mP2qR7nL4wT1yZ5vA8sD',
    secret: 'gsec_live_9384jsdf83',
    merchantId: 'M-12345',
    webhookUrl: 'https://api.sakai.ph/webhooks/gcash',
  },
  {
    id: 'paymaya',
    label: 'PayMaya',
    type: 'ewallet',
    apiKey: 'pm_live_3bN8cX6hJ0eQ4uI2oW7fY9kM',
    secret: 'pm_sec_live_9jdf934f',
    merchantId: 'P-98765',
    webhookUrl: 'https://api.sakai.ph/webhooks/paymaya',
  },
  {
    id: 'card',
    label: 'Stripe (Cards)',
    type: 'card',
    publishableKey: 'pk_live_5aG1dV4jR8mU3oS7pL9wB2xZ',
    secretKey: 'sk_live_39dsf93kdfvj94jg',
    webhookSecret: 'whsec_38sjd8fu4ndsf',
  },
];

// ── Component ─────────────────────────────────────────────────────────────────

export function SAPayments() {
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [payouts, setPayouts] = useState<DriverPayout[]>([]);
  const [summary, setSummary] = useState<PaymentSummary>({
    total_revenue: 0,
    payouts: 0,
    commission: 0,
    pending_settlements: 0,
  });
  const [search, setSearch] = useState('');
  const [confirmModal, setConfirmModal] = useState<ConfirmState>({
    open: false,
    payoutId: '',
    batchName: '',
  });
  const [providers, setProviders] = useState<GatewayProvider[]>(DEFAULT_PROVIDERS);
  const [savingProvider, setSavingProvider] = useState<string | null>(null);

  const [commissionConfig, setCommissionConfig] = useState<any>(null);
  const [savingCommission, setSavingCommission] = useState(false);

  // ── Load data on mount ─────────────────────────────────────────────────────

  useEffect(() => {
    async function load() {
      const [txns, pouts, sum, comm] = await Promise.all([
        paymentsApi.getTransactions(),
        paymentsApi.getPayouts(),
        paymentsApi.getSummary(),
        paymentsApi.getCommissionConfig(),
      ]);
      setTransactions(txns);
      setPayouts(pouts);
      setSummary(sum);
      setCommissionConfig(comm);
    }
    void load();
  }, []);

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
    await paymentsApi.approvePayout(confirmModal.payoutId);
    setPayouts((prev) =>
      prev.map((p) =>
        p.id === confirmModal.payoutId ? { ...p, status: 'approved' } : p
      )
    );
  }

  // ── Gateway provider helpers ───────────────────────────────────────────────

  function updateProvider(
    id: string,
    field: keyof Omit<GatewayProvider, 'id' | 'label'>,
    value: string
  ) {
    setProviders((prev) =>
      prev.map((p) => (p.id === id ? { ...p, [field]: value } : p))
    );
  }

  async function saveProvider(id: string) {
    setSavingProvider(id);
    const provider = providers.find((p) => p.id === id);
    if (provider) {
      const fields: Record<string, string> = {};
      if (provider.apiKey) fields.api_key = provider.apiKey;
      if (provider.secret) fields.secret = provider.secret;
      if (provider.merchantId) fields.merchant_id = provider.merchantId;
      if (provider.webhookUrl) fields.webhook_url = provider.webhookUrl;
      if (provider.publishableKey) fields.publishable_key = provider.publishableKey;
      if (provider.secretKey) fields.secret_key = provider.secretKey;
      if (provider.webhookSecret) fields.webhook_secret = provider.webhookSecret;
      await systemApi.updateIntegration(id, fields).catch(() => {});
    }
    setSavingProvider(null);
  }

  async function saveCommission() {
    setSavingCommission(true);
    await paymentsApi.updateCommissionConfig(commissionConfig).catch(() => {});
    setSavingCommission(false);
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
            <CardTitle>Pending Driver Payouts</CardTitle>
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
                    <span className="text-sm font-medium text-text-main">
                      {payout.batch}
                    </span>
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

        {/* Payment Gateway Configuration */}
        <Card>
          <CardHeader>
            <CardTitle>Payment Gateway Configuration</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="flex items-start gap-2 p-3 bg-warning/10 border border-warning/20 rounded-lg">
              <AlertCircle className="w-4 h-4 text-warning flex-shrink-0 mt-0.5" />
              <p className="text-sm text-warning">
                API keys are masked for security. Only the last 4 characters are visible.
              </p>
            </div>

            <div className="space-y-4">
              {providers.map((provider) => (
                <div key={provider.id} className="p-4 bg-surface-hover rounded-lg border border-border">
                  <h4 className="text-sm font-semibold text-text-main mb-3">{provider.label}</h4>

                  {provider.type === 'ewallet' ? (
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                      <div>
                        <label className="block text-xs text-text-muted mb-1">API Key</label>
                        <Input value={maskKey(provider.apiKey)} onChange={e => updateProvider(provider.id, 'apiKey', e.target.value)} />
                      </div>
                      <div>
                        <label className="block text-xs text-text-muted mb-1">Secret</label>
                        <Input value={maskKey(provider.secret)} type="password" onChange={e => updateProvider(provider.id, 'secret', e.target.value)} />
                      </div>
                      <div>
                        <label className="block text-xs text-text-muted mb-1">Merchant ID</label>
                        <Input value={provider.merchantId} onChange={e => updateProvider(provider.id, 'merchantId', e.target.value)} />
                      </div>
                      <div>
                        <label className="block text-xs text-text-muted mb-1">Webhook URL</label>
                        <Input value={provider.webhookUrl || ''} onChange={e => updateProvider(provider.id, 'webhookUrl', e.target.value)} />
                      </div>
                    </div>
                  ) : (
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                      <div className="sm:col-span-2">
                        <label className="block text-xs text-text-muted mb-1">Publishable Key</label>
                        <Input value={maskKey(provider.publishableKey)} onChange={e => updateProvider(provider.id, 'publishableKey', e.target.value)} />
                      </div>
                      <div>
                        <label className="block text-xs text-text-muted mb-1">Secret Key</label>
                        <Input value={maskKey(provider.secretKey)} type="password" onChange={e => updateProvider(provider.id, 'secretKey', e.target.value)} />
                      </div>
                      <div>
                        <label className="block text-xs text-text-muted mb-1">Webhook Secret</label>
                        <Input value={maskKey(provider.webhookSecret)} type="password" onChange={e => updateProvider(provider.id, 'webhookSecret', e.target.value)} />
                      </div>
                    </div>
                  )}

                  <div className="mt-3 flex justify-end">
                    <Button variant="primary" size="sm" onClick={() => saveProvider(provider.id)} disabled={savingProvider === provider.id}>
                      {savingProvider === provider.id ? 'Saving...' : 'Save'}
                    </Button>
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>

        {/* Commission Settings */}
        <Card>
          <CardHeader>
            <CardTitle>Commission Settings</CardTitle>
          </CardHeader>
          <CardContent>
            {commissionConfig ? (
              <div className="space-y-4">
                <div className="p-4 bg-surface-hover rounded-lg border border-border space-y-4">
                  <h4 className="text-sm font-semibold text-text-main">Platform Commission Rate</h4>
                  <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
                    <div>
                      <label className="block text-xs text-text-muted mb-1">Motorcycle (%)</label>
                      <Input
                        type="number"
                        value={commissionConfig.rates.motorcycle}
                        onChange={e => setCommissionConfig({ ...commissionConfig, rates: { ...commissionConfig.rates, motorcycle: Number(e.target.value) } })}
                      />
                    </div>
                    <div>
                      <label className="block text-xs text-text-muted mb-1">Tricycle (%)</label>
                      <Input
                        type="number"
                        value={commissionConfig.rates.tricycle}
                        onChange={e => setCommissionConfig({ ...commissionConfig, rates: { ...commissionConfig.rates, tricycle: Number(e.target.value) } })}
                      />
                    </div>
                    <div>
                      <label className="block text-xs text-text-muted mb-1">Other (%)</label>
                      <Input
                        type="number"
                        value={commissionConfig.rates.other}
                        onChange={e => setCommissionConfig({ ...commissionConfig, rates: { ...commissionConfig.rates, other: Number(e.target.value) } })}
                      />
                    </div>
                  </div>
                </div>

                <div className="p-4 bg-surface-hover rounded-lg border border-border space-y-4">
                  <h4 className="text-sm font-semibold text-text-main">Pricing Floors & Promos</h4>
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                    <div>
                      <label className="block text-xs text-text-muted mb-1">Minimum Commission (₱)</label>
                      <Input
                        type="number"
                        value={commissionConfig.minimum_commission}
                        onChange={e => setCommissionConfig({ ...commissionConfig, minimum_commission: Number(e.target.value) })}
                      />
                    </div>
                    <div>
                      <label className="block text-xs text-text-muted mb-1">Promotional Override (%)</label>
                      <Input
                        type="number"
                        value={commissionConfig.promotional_override}
                        onChange={e => setCommissionConfig({ ...commissionConfig, promotional_override: Number(e.target.value) })}
                      />
                    </div>
                  </div>
                </div>

                <div className="flex justify-end pt-2">
                  <Button variant="primary" onClick={saveCommission} disabled={savingCommission}>
                    {savingCommission ? 'Saving...' : 'Save Commission Settings'}
                  </Button>
                </div>
              </div>
            ) : (
              <div className="text-sm text-text-muted text-center py-6">Loading config...</div>
            )}
          </CardContent>
        </Card>
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

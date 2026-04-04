import React, { useEffect, useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/Table';
import { Badge } from '@/components/ui/Badge';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Download, Wallet, ArrowUpRight, ArrowDownRight, CheckCircle, Search } from 'lucide-react';
import { formatPHP } from '@/lib/utils';
import { adminApi, Transaction, DriverPayout } from '@/lib/admin-api';

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
  const [search, setSearch] = useState('');
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [payouts, setPayouts] = useState<DriverPayout[]>([]);
  const [summary, setSummary] = useState<{ total_revenue: number; payouts: number; commission: number; pending_settlements: number } | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    setLoading(true);
    Promise.all([
      adminApi.payments.getTransactions(),
      adminApi.payments.getPayouts(),
      adminApi.payments.getSummary(),
    ]).then(([txns, pouts, sum]) => {
      setTransactions(txns);
      setPayouts(pouts);
      setSummary(sum);
    }).catch(() => {}).finally(() => setLoading(false));
  }, []);

  const handleApprovePayout = (id: string) => {
    adminApi.payments.approvePayout(id)
      .then(() => setPayouts(prev => prev.filter(p => p.id !== id)))
      .catch(() => {});
  };

  const handleExport = () => {
    adminApi.reports.exportCsv('financial').then(url => {
      if (url) window.open(url, '_blank');
    }).catch(() => {});
  };

  const q = search.toLowerCase();
  const filtered = transactions.filter(txn =>
    !q ||
    txn.id.toLowerCase().includes(q) ||
    (txn.ride_id ?? '').toLowerCase().includes(q) ||
    (txn.rider_name ?? '').toLowerCase().includes(q) ||
    (txn.driver_name ?? '').toLowerCase().includes(q) ||
    txn.payment_method.toLowerCase().includes(q) ||
    txn.status.toLowerCase().includes(q)
  );

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap justify-between items-center gap-3">
        <h1 className="text-2xl font-bold text-text-main">Payments & Earnings</h1>
        <Button variant="outline" className="gap-2" onClick={handleExport}>
          <Download className="w-4 h-4" /> Export Weekly Report
        </Button>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-2 gap-6">
        <SummaryCard
          title="Total Revenue (30d)"
          amount={summary ? formatPHP(summary.total_revenue) : '—'}
          icon={<Wallet className="w-5 h-5 text-primary" />}
        />
        <SummaryCard
          title="Driver Payouts (30d)"
          amount={summary ? formatPHP(summary.payouts) : '—'}
          icon={<ArrowUpRight className="w-5 h-5 text-danger" />}
        />
        <SummaryCard
          title="Platform Commission"
          amount={summary ? formatPHP(summary.commission) : '—'}
          icon={<ArrowDownRight className="w-5 h-5 text-success" />}
        />
        <SummaryCard
          title="Pending Settlements"
          amount={summary ? formatPHP(summary.pending_settlements) : '—'}
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
                ) : filtered.map((txn) => (
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
                    <Button size="sm" onClick={() => handleApprovePayout(payout.id)}>Approve</Button>
                  </div>
                ))}
              </div>
            )}
          </CardContent>
        </Card>
      </div>
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

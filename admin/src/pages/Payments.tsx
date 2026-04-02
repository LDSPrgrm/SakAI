import React, { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/Table';
import { Badge } from '@/components/ui/Badge';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Download, Wallet, ArrowUpRight, ArrowDownRight, CheckCircle, Search } from 'lucide-react';
import { formatPHP } from '@/lib/utils';

const transactions = [
  { id: 'TXN-001', rideId: 'RD-99281', amount: 150, type: 'Ride Fare', method: 'GCash', status: 'Settled', date: '2026-04-01 14:35' },
  { id: 'TXN-002', rideId: 'RD-99282', amount: 50, type: 'Ride Fare', method: 'Cash', status: 'Settled', date: '2026-04-01 15:20' },
  { id: 'TXN-003', rideId: '-', amount: -2500, type: 'Driver Payout', method: 'Bank Transfer', status: 'Pending', date: '2026-04-01 10:00' },
  { id: 'TXN-004', rideId: 'RD-99284', amount: 180, type: 'Ride Fare', method: 'Card', status: 'Failed', date: '2026-04-01 16:50' },
];

export function Payments() {
  const [search, setSearch] = useState('');

  const q = search.toLowerCase();
  const filtered = transactions.filter(txn =>
    !q ||
    txn.id.toLowerCase().includes(q) ||
    txn.rideId.toLowerCase().includes(q) ||
    txn.type.toLowerCase().includes(q) ||
    txn.method.toLowerCase().includes(q) ||
    txn.status.toLowerCase().includes(q)
  );

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap justify-between items-center gap-3">
        <h1 className="text-2xl font-bold text-text-main">Payments & Earnings</h1>
        <Button variant="outline" className="gap-2">
          <Download className="w-4 h-4" /> Export Weekly Report
        </Button>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-2 gap-6">
        <SummaryCard title="Total Revenue (30d)" amount={formatPHP(4520000)} icon={<Wallet className="w-5 h-5 text-primary" />} />
        <SummaryCard title="Driver Payouts (30d)" amount={formatPHP(3616000)} icon={<ArrowUpRight className="w-5 h-5 text-danger" />} />
        <SummaryCard title="Platform Commission" amount={formatPHP(904000)} icon={<ArrowDownRight className="w-5 h-5 text-success" />} />
        <SummaryCard title="Pending Settlements" amount={formatPHP(125000)} icon={<CheckCircle className="w-5 h-5 text-warning" />} />
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
                  <TableHead>Type</TableHead>
                  <TableHead>Amount</TableHead>
                  <TableHead>Method</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead>Date</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {filtered.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={6} className="text-center py-10 text-text-muted">
                      No transactions match your search.
                    </TableCell>
                  </TableRow>
                ) : filtered.map((txn) => (
                  <TableRow key={txn.id}>
                    <TableCell>
                      <p className="font-medium text-text-main">{txn.id}</p>
                      {txn.rideId !== '-' && <p className="text-xs text-text-muted">Ride: {txn.rideId}</p>}
                    </TableCell>
                    <TableCell>{txn.type}</TableCell>
                    <TableCell className={`font-medium ${txn.amount > 0 ? 'text-success' : 'text-danger'}`}>
                      {txn.amount > 0 ? '+' : ''}{formatPHP(txn.amount)}
                    </TableCell>
                    <TableCell>{txn.method}</TableCell>
                    <TableCell>
                      <Badge variant={
                        txn.status === 'Settled' ? 'success' :
                          txn.status === 'Pending' ? 'warning' : 'danger'
                      }>
                        {txn.status}
                      </Badge>
                    </TableCell>
                    <TableCell className="text-sm text-text-muted">{txn.date}</TableCell>
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
            <div className="space-y-4">
              <p className="text-sm text-text-muted">Approve weekly payouts for drivers who have reached the minimum threshold.</p>

              <div className="bg-surface-hover p-4 rounded-lg border border-border flex justify-between items-center">
                <div>
                  <p className="text-sm font-medium">Batch #492</p>
                  <p className="text-xs text-text-muted">142 Drivers • {formatPHP(450000)}</p>
                </div>
                <Button size="sm">Approve</Button>
              </div>

              <div className="bg-surface-hover p-4 rounded-lg border border-border flex justify-between items-center">
                <div>
                  <p className="text-sm font-medium">Batch #491</p>
                  <p className="text-xs text-text-muted">89 Drivers • {formatPHP(210000)}</p>
                </div>
                <Button size="sm">Approve</Button>
              </div>
            </div>
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

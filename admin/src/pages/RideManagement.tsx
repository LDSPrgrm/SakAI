import React, { useEffect, useState } from 'react';
import { Card, CardContent } from '@/components/ui/Card';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/Table';
import { Badge } from '@/components/ui/Badge';
import { Input } from '@/components/ui/Input';
import { Search } from 'lucide-react';
import { formatPHP } from '@/lib/utils';
import { useRides } from '@/hooks/useRides';
import type { AdminRideItem, RideStatus } from '@/types/super-admin';
import { PaginationFooter } from '@/components/shared/PaginationFooter';

const STATUS_OPTIONS: Array<{ label: string; value: string }> = [
  { label: 'All Statuses', value: '' },
  { label: 'Completed', value: 'completed' },
  { label: 'In Progress', value: 'in_progress' },
  { label: 'Cancelled', value: 'cancelled' },
  { label: 'Requested', value: 'requested' },
  { label: 'Accepted', value: 'accepted' },
  { label: 'Arrived', value: 'arrived' },
];

function getStatusVariant(status: RideStatus): 'success' | 'info' | 'default' | 'warning' | 'danger' {
  switch (status) {
    case 'completed': return 'success';
    case 'in_progress': return 'info';
    case 'cancelled': return 'default';
    case 'requested': return 'warning';
    case 'accepted':
    case 'arrived': return 'info';
    default: return 'default';
  }
}

function statusLabel(status: RideStatus): string {
  return status.replace('_', ' ').replace(/\b\w/g, c => c.toUpperCase());
}

function paymentBadgeLabel(method: string | null): string {
  if (!method) return '—';
  switch (method) {
    case 'gcash': return 'GCash';
    case 'paymaya': return 'PayMaya';
    case 'card': return 'Card';
    case 'cash': return 'Cash';
    default: return method;
  }
}

const PAGE_SIZE = 20;

export function RideManagement() {
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('');
  const [page, setPage] = useState(1);

  const ridesQuery = useRides({ status: statusFilter || undefined, page, limit: PAGE_SIZE });
  const rides = (ridesQuery.data?.items ?? []) as AdminRideItem[];
  const meta = ridesQuery.data?.meta;
  const loading = ridesQuery.isPending;

  // Reset to page 1 when filter changes.
  useEffect(() => { setPage(1); }, [statusFilter]);

  const q = search.toLowerCase();
  const filtered = rides.filter(ride => {
    if (!q) return true;
    return (
      ride.id.toLowerCase().includes(q) ||
      (ride.passenger_name ?? '').toLowerCase().includes(q) ||
      (ride.driver_name ?? '').toLowerCase().includes(q) ||
      (ride.origin_address ?? '').toLowerCase().includes(q) ||
      (ride.destination_address ?? '').toLowerCase().includes(q)
    );
  });

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h1 className="text-2xl font-bold text-text-main">Ride Management</h1>
      </div>

      <Card>
        <div className="px-4 md:px-6 py-4 border-b border-border flex flex-col sm:flex-row justify-between items-stretch sm:items-center gap-3 flex-wrap">
          <div className="flex-1 min-w-0">
            <Input
              placeholder="Search by Ride ID, Rider, or Driver..."
              icon={<Search className="w-4 h-4" />}
              value={search}
              onChange={(e) => setSearch(e.target.value)}
            />
          </div>
          <div className="flex gap-3">
            <select
              aria-label="Filter by status"
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
              className="bg-surface border border-border rounded-lg px-3 py-2 text-sm text-text-main focus:outline-none focus:ring-2 focus:ring-primary"
            >
              {STATUS_OPTIONS.map(s => (
                <option key={s.value} value={s.value}>{s.label}</option>
              ))}
            </select>
          </div>
        </div>
        <CardContent className="p-0 overflow-x-auto">
          <PaginationFooter
            meta={meta}
            page={page}
            onPageChange={setPage}
            label="rides"
            className="flex items-center justify-between px-4 md:px-6 py-3 border-b border-border text-sm text-text-muted"
          />
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Ride ID</TableHead>
                <TableHead>Rider & Driver</TableHead>
                <TableHead>Route</TableHead>
                <TableHead>Fare & Payment</TableHead>
                <TableHead>Status</TableHead>
                <TableHead>Date & Time</TableHead>
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
                    No rides match your search or filter.
                  </TableCell>
                </TableRow>
              ) : filtered.map((ride) => (
                <TableRow key={ride.id} className="cursor-pointer hover:bg-surface-hover/80">
                  <TableCell className="font-medium text-primary">{ride.id}</TableCell>
                  <TableCell>
                    <div className="space-y-1">
                      <p className="text-sm"><span className="text-text-muted">R:</span> {ride.passenger_name ?? ride.passenger?.name ?? '—'}</p>
                      <p className="text-sm"><span className="text-text-muted">D:</span> {ride.driver_name ?? ride.driver?.name ?? '—'}</p>
                    </div>
                  </TableCell>
                  <TableCell>
                    <div className="space-y-1 max-w-[200px]">
                      <p className="text-xs truncate text-success">A: {ride.origin_address ?? '—'}</p>
                      <p className="text-xs truncate text-danger">B: {ride.destination_address ?? '—'}</p>
                    </div>
                  </TableCell>
                  <TableCell>
                    <div className="space-y-1">
                      <p className="font-medium text-text-main">
                        {ride.total_fare != null ? formatPHP(ride.total_fare) : '—'}
                      </p>
                      {ride.payment_method && (
                        <Badge variant="default" className="text-[10px]">{paymentBadgeLabel(ride.payment_method)}</Badge>
                      )}
                    </div>
                  </TableCell>
                  <TableCell>
                    <Badge variant={getStatusVariant(ride.status as RideStatus)}>{statusLabel(ride.status as RideStatus)}</Badge>
                  </TableCell>
                  <TableCell className="text-sm text-text-muted">
                    {ride.created_at ? new Date(ride.created_at).toLocaleString('en-PH', { dateStyle: 'short', timeStyle: 'short' }) : '—'}
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
          <PaginationFooter
            meta={meta}
            page={page}
            onPageChange={setPage}
            label="rides"
            className="flex items-center justify-between px-4 md:px-6 py-3 border-b border-border text-sm text-text-muted"
          />
        </CardContent>
      </Card>
    </div>
  );
}


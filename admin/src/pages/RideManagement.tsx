import React, { useState } from 'react';
import { Card, CardContent } from '@/components/ui/Card';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/Table';
import { Badge } from '@/components/ui/Badge';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Search, Map } from 'lucide-react';
import { formatPHP } from '@/lib/utils';

const rides = [
  { id: 'RD-99281', rider: 'Maria Santos', driver: 'Juan Dela Cruz', vehicle: 'Motorcycle', pickup: 'SM Megamall, Mandaluyong', dropoff: 'BGC, Taguig', fare: 150, payment: 'GCash', status: 'Completed', date: '2026-04-01 14:30' },
  { id: 'RD-99282', rider: 'Jose Rizal', driver: 'Pedro Penduko', vehicle: 'Tricycle', pickup: 'Intramuros, Manila', dropoff: 'Ermita, Manila', fare: 50, payment: 'Cash', status: 'In Progress', date: '2026-04-01 15:15' },
  { id: 'RD-99283', rider: 'Andres Bonifacio', driver: 'Cardo Dalisay', vehicle: 'Car (4-seater)', pickup: 'Trinoma, Quezon City', dropoff: 'UP Diliman', fare: 220, payment: 'PayMaya', status: 'Cancelled', date: '2026-04-01 16:00' },
  { id: 'RD-99284', rider: 'Emilio Aguinaldo', driver: 'Antonio Luna', vehicle: 'Motorcycle', pickup: 'Makati CBD', dropoff: 'Pasay City', fare: 180, payment: 'Card', status: 'Disputed', date: '2026-04-01 16:45' },
];

const STATUS_OPTIONS = ['All Statuses', 'Completed', 'In Progress', 'Cancelled', 'Disputed'] as const;

export function RideManagement() {
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('All Statuses');

  const getStatusVariant = (status: string) => {
    switch (status) {
      case 'Completed': return 'success';
      case 'In Progress': return 'info';
      case 'Cancelled': return 'default';
      case 'Disputed': return 'danger';
      default: return 'default';
    }
  };

  const q = search.toLowerCase();
  const filtered = rides.filter(ride => {
    const matchesSearch = !q ||
      ride.id.toLowerCase().includes(q) ||
      ride.rider.toLowerCase().includes(q) ||
      ride.driver.toLowerCase().includes(q) ||
      ride.pickup.toLowerCase().includes(q) ||
      ride.dropoff.toLowerCase().includes(q);
    const matchesStatus = statusFilter === 'All Statuses' || ride.status === statusFilter;
    return matchesSearch && matchesStatus;
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
              {STATUS_OPTIONS.map(s => <option key={s} value={s}>{s}</option>)}
            </select>
          </div>
        </div>
        <CardContent className="p-0 overflow-x-auto">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Ride ID</TableHead>
                <TableHead>Rider & Driver</TableHead>
                <TableHead>Route</TableHead>
                <TableHead>Fare & Payment</TableHead>
                <TableHead>Status</TableHead>
                <TableHead>Date & Time</TableHead>
                <TableHead className="text-right">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {filtered.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={7} className="text-center py-10 text-text-muted">
                    No rides match your search or filter.
                  </TableCell>
                </TableRow>
              ) : filtered.map((ride) => (
                <TableRow key={ride.id} className="cursor-pointer hover:bg-surface-hover/80">
                  <TableCell className="font-medium text-primary">{ride.id}</TableCell>
                  <TableCell>
                    <div className="space-y-1">
                      <p className="text-sm"><span className="text-text-muted">R:</span> {ride.rider}</p>
                      <p className="text-sm"><span className="text-text-muted">D:</span> {ride.driver}</p>
                    </div>
                  </TableCell>
                  <TableCell>
                    <div className="space-y-1 max-w-[200px]">
                      <p className="text-xs truncate text-success">A: {ride.pickup}</p>
                      <p className="text-xs truncate text-danger">B: {ride.dropoff}</p>
                    </div>
                  </TableCell>
                  <TableCell>
                    <div className="space-y-1">
                      <p className="font-medium text-text-main">{formatPHP(ride.fare)}</p>
                      <Badge variant="default" className="text-[10px]">{ride.payment}</Badge>
                    </div>
                  </TableCell>
                  <TableCell>
                    <Badge variant={getStatusVariant(ride.status) as any}>{ride.status}</Badge>
                  </TableCell>
                  <TableCell className="text-sm text-text-muted">{ride.date}</TableCell>
                  <TableCell className="text-right">
                    <Button variant="ghost" size="icon" aria-label="View map route">
                      <Map className="w-4 h-4" />
                    </Button>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </CardContent>
      </Card>
    </div>
  );
}

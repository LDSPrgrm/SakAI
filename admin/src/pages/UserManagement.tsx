import React, { useEffect, useState } from 'react';
import { Card, CardContent } from '@/components/ui/Card';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/Table';
import { Badge } from '@/components/ui/Badge';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/Tabs';
import { Search, Eye, Ban, CheckCircle, AlertTriangle } from 'lucide-react';
import { usersApi } from '@/api/admin/users';
import type { PassengerUser, DriverUser, AdminStatus } from '@/types/super-admin';

function vehicleLabel(v: DriverUser['vehicle']): string {
  if (!v) return '—';
  return `${v.make} ${v.model} (${v.plate})`;
}

function statusVariant(status: string): 'success' | 'warning' | 'danger' | 'default' {
  switch (status) {
    case 'active': return 'success';
    case 'suspended': return 'danger';
    case 'deactivated': return 'default';
    default: return 'default';
  }
}

function statusLabel(status: string): string {
  return status.charAt(0).toUpperCase() + status.slice(1);
}

interface ConfirmDialog {
  open: boolean;
  title: string;
  message: string;
  onConfirm: () => void;
}

function ConfirmModal({ dialog, onClose }: { dialog: ConfirmDialog; onClose: () => void }) {
  if (!dialog.open) return null;
  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60" role="dialog" aria-modal="true">
      <div className="bg-surface border border-border rounded-xl p-6 w-full max-w-sm shadow-xl space-y-4">
        <div className="flex items-center gap-3">
          <AlertTriangle className="w-5 h-5 text-warning flex-shrink-0" />
          <h2 className="text-base font-semibold text-text-main">{dialog.title}</h2>
        </div>
        <p className="text-sm text-text-muted">{dialog.message}</p>
        <div className="flex gap-3 justify-end">
          <Button variant="outline" size="sm" onClick={onClose}>Cancel</Button>
          <Button variant="danger" size="sm" onClick={() => { dialog.onConfirm(); onClose(); }}>Confirm</Button>
        </div>
      </div>
    </div>
  );
}

export function UserManagement() {
  const [search, setSearch] = useState('');
  const [riderList, setRiderList] = useState<PassengerUser[]>([]);
  const [driverList, setDriverList] = useState<DriverUser[]>([]);
  const [loading, setLoading] = useState(true);
  const [confirm, setConfirm] = useState<ConfirmDialog>({ open: false, title: '', message: '', onConfirm: () => {} });

  useEffect(() => {
    setLoading(true);
    Promise.all([
      usersApi.getPassengers(),
      usersApi.getDrivers(),
    ]).then(([passengers, drivers]) => {
      setRiderList(passengers);
      setDriverList(drivers);
    }).catch(() => {}).finally(() => setLoading(false));
  }, []);

  const closeConfirm = () => setConfirm(prev => ({ ...prev, open: false }));

  const suspendUser = (id: string, name: string, type: 'Rider' | 'Driver') => {
    setConfirm({
      open: true,
      title: `Suspend ${type}`,
      message: `Are you sure you want to suspend ${name}? They will no longer be able to ${type === 'Rider' ? 'book rides' : 'accept rides'}.`,
      onConfirm: () => {
        usersApi.updateStatus(id, { status: 'suspended' }).catch(() => {});
        if (type === 'Rider') {
          setRiderList(prev => prev.map(r => r.id === id ? { ...r, status: 'suspended' as any } : r));
        } else {
          setDriverList(prev => prev.map(d => d.id === id ? { ...d, status: 'suspended' as any } : d));
        }
      },
    });
  };

  const q = search.toLowerCase();

  const filteredRiders = riderList.filter(r =>
    !q || r.name.toLowerCase().includes(q) || r.id.toLowerCase().includes(q) || (r.phone ?? '').includes(q)
  );

  const filteredDrivers = driverList.filter(d =>
    !q || d.name.toLowerCase().includes(q) || d.id.toLowerCase().includes(q) || vehicleLabel(d.vehicle).toLowerCase().includes(q)
  );

  return (
    <div className="space-y-6">
      <ConfirmModal dialog={confirm} onClose={closeConfirm} />

      <div className="flex justify-between items-center">
        <h1 className="text-2xl font-bold text-text-main">User Management</h1>
        <Button>Add New User</Button>
      </div>

      <Card>
        <CardContent className="p-0">
          <Tabs defaultValue="riders" className="w-full">
            <div className="px-4 md:px-6 pt-4 border-b border-border flex flex-col sm:flex-row sm:justify-between sm:items-center gap-3">
              <TabsList>
                <TabsTrigger value="riders">Riders</TabsTrigger>
                <TabsTrigger value="drivers">Drivers</TabsTrigger>
              </TabsList>

              <div className="pb-3 sm:pb-4 w-full sm:w-64">
                <Input
                  placeholder="Search users..."
                  icon={<Search className="w-4 h-4" />}
                  value={search}
                  onChange={(e) => setSearch(e.target.value)}
                />
              </div>
            </div>

            <TabsContent value="riders" className="m-0 overflow-x-auto">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Name</TableHead>
                    <TableHead>Contact</TableHead>
                    <TableHead>Status</TableHead>
                    <TableHead>Date Registered</TableHead>
                    <TableHead className="text-right">Actions</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {loading ? (
                    <TableRow>
                      <TableCell colSpan={5} className="text-center py-10 text-text-muted">Loading...</TableCell>
                    </TableRow>
                  ) : filteredRiders.length === 0 ? (
                    <TableRow>
                      <TableCell colSpan={5} className="text-center py-10 text-text-muted">
                        No riders match your search.
                      </TableCell>
                    </TableRow>
                  ) : filteredRiders.map((rider) => (
                    <TableRow key={rider.id}>
                      <TableCell>
                        <div>
                          <p className="font-medium text-text-main">{rider.name}</p>
                          <p className="text-xs text-text-muted">{rider.id}</p>
                        </div>
                      </TableCell>
                      <TableCell>
                        <div>
                          {rider.phone && <p className="text-sm">{rider.phone}</p>}
                          <p className="text-xs text-text-muted">{rider.email}</p>
                        </div>
                      </TableCell>
                      <TableCell>
                        <Badge variant={statusVariant((rider as any).status ?? 'active')}>
                          {statusLabel((rider as any).status ?? 'active')}
                        </Badge>
                      </TableCell>
                      <TableCell className="text-sm text-text-muted">
                        {rider.created_at ? new Date(rider.created_at).toLocaleDateString('en-PH') : '—'}
                      </TableCell>
                      <TableCell className="text-right">
                        <div className="flex justify-end gap-2">
                          <Button variant="ghost" size="icon" aria-label="View Profile"><Eye className="w-4 h-4" /></Button>
                          {(rider as any).status !== 'suspended' && (rider as any).status !== 'deactivated' && (
                            <Button
                              variant="ghost"
                              size="icon"
                              className="text-danger"
                              aria-label="Suspend rider"
                              onClick={() => suspendUser(rider.id, rider.name, 'Rider')}
                            >
                              <Ban className="w-4 h-4" />
                            </Button>
                          )}
                        </div>
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </TabsContent>

            <TabsContent value="drivers" className="m-0 overflow-x-auto">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Name</TableHead>
                    <TableHead>Contact</TableHead>
                    <TableHead>Vehicle</TableHead>
                    <TableHead>Status</TableHead>
                    <TableHead className="text-right">Actions</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {loading ? (
                    <TableRow>
                      <TableCell colSpan={5} className="text-center py-10 text-text-muted">Loading...</TableCell>
                    </TableRow>
                  ) : filteredDrivers.length === 0 ? (
                    <TableRow>
                      <TableCell colSpan={5} className="text-center py-10 text-text-muted">
                        No drivers match your search.
                      </TableCell>
                    </TableRow>
                  ) : filteredDrivers.map((driver) => (
                    <TableRow key={driver.id}>
                      <TableCell>
                        <div>
                          <p className="font-medium text-text-main">{driver.name}</p>
                          <p className="text-xs text-text-muted">{driver.id}</p>
                        </div>
                      </TableCell>
                      <TableCell>
                        <div>
                          {driver.phone && <p className="text-sm">{driver.phone}</p>}
                          <p className="text-xs text-text-muted">{driver.email}</p>
                        </div>
                      </TableCell>
                      <TableCell className="text-sm">{vehicleLabel(driver.vehicle)}</TableCell>
                      <TableCell>
                        <Badge variant={statusVariant((driver as any).status ?? 'active')}>
                          {statusLabel((driver as any).status ?? 'active')}
                        </Badge>
                      </TableCell>
                      <TableCell className="text-right">
                        <div className="flex justify-end gap-2">
                          <Button variant="ghost" size="icon" aria-label="Review Documents"><CheckCircle className="w-4 h-4 text-success" /></Button>
                          <Button variant="ghost" size="icon" aria-label="View Profile"><Eye className="w-4 h-4" /></Button>
                          {(driver as any).status !== 'suspended' && (driver as any).status !== 'deactivated' && (
                            <Button
                              variant="ghost"
                              size="icon"
                              className="text-danger"
                              aria-label="Suspend driver"
                              onClick={() => suspendUser(driver.id, driver.name, 'Driver')}
                            >
                              <Ban className="w-4 h-4" />
                            </Button>
                          )}
                        </div>
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </TabsContent>
          </Tabs>
        </CardContent>
      </Card>
    </div>
  );
}

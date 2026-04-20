import React, { useState } from 'react';
import { Card, CardContent } from '@/components/ui/Card';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/Table';
import { Badge } from '@/components/ui/Badge';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/Tabs';
import { Search, Eye, Ban, CheckCircle } from 'lucide-react';
import { usePermissions } from '@/hooks/usePermissions';
import { usePassengers, useDrivers, useUpdateUserStatus } from '@/hooks/useUsers';
import { ConfirmationModal } from '@/components/shared/ConfirmationModal';
import { PaginationFooter } from '@/components/shared/PaginationFooter';
import type { PassengerUser, DriverUser } from '@/types/super-admin';

const PAGE_SIZE = 20;

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

export function UserManagement() {
  const { can } = usePermissions();
  const canWrite = can('user_management', 'write');
  const writeDisabledTitle = canWrite ? undefined : 'You do not have write access';
  const [search, setSearch] = useState('');
  const [riderPage, setRiderPage] = useState(1);
  const [driverPage, setDriverPage] = useState(1);
  const [confirm, setConfirm] = useState<ConfirmDialog>({ open: false, title: '', message: '', onConfirm: () => {} });

  const passengersQuery = usePassengers({ page: riderPage, limit: PAGE_SIZE, q: search || undefined });
  const driversQuery = useDrivers({ page: driverPage, limit: PAGE_SIZE, q: search || undefined });
  const updateStatus = useUpdateUserStatus();

  const riderList = (passengersQuery.data?.items ?? []) as PassengerUser[];
  const driverList = (driversQuery.data?.items ?? []) as DriverUser[];
  const riderMeta = passengersQuery.data?.meta;
  const driverMeta = driversQuery.data?.meta;
  const loading = passengersQuery.isPending || driversQuery.isPending;

  const closeConfirm = () => setConfirm(prev => ({ ...prev, open: false }));

  const suspendUser = (id: string, name: string, type: 'Rider' | 'Driver') => {
    setConfirm({
      open: true,
      title: `Suspend ${type}`,
      message: `Are you sure you want to suspend ${name}? They will no longer be able to ${type === 'Rider' ? 'book rides' : 'accept rides'}.`,
      onConfirm: () => {
        updateStatus.mutate({ id, status: 'suspended' });
      },
    });
  };

  // Server already applies `q` as a filter; keep client-side narrowing for name/vehicle
  // fields the backend may not cover.
  const q = search.toLowerCase();

  const filteredRiders = riderList.filter(r =>
    !q || r.name.toLowerCase().includes(q) || r.id.toLowerCase().includes(q) || (r.phone ?? '').includes(q)
  );

  const filteredDrivers = driverList.filter(d =>
    !q || d.name.toLowerCase().includes(q) || d.id.toLowerCase().includes(q) || vehicleLabel(d.vehicle).toLowerCase().includes(q)
  );

  return (
    <div className="space-y-6">
      <ConfirmationModal
        open={confirm.open}
        title={confirm.title}
        description={confirm.message}
        onConfirm={() => { confirm.onConfirm(); closeConfirm(); }}
        onCancel={closeConfirm}
      />

      <div className="flex justify-between items-center">
        <h1 className="text-2xl font-bold text-text-main">User Management</h1>
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
                        <Badge variant={statusVariant(rider.status ?? 'active')}>
                          {statusLabel(rider.status ?? 'active')}
                        </Badge>
                      </TableCell>
                      <TableCell className="text-sm text-text-muted">
                        {rider.created_at ? new Date(rider.created_at).toLocaleDateString('en-PH') : '—'}
                      </TableCell>
                      <TableCell className="text-right">
                        <div className="flex justify-end gap-2">
                          <Button variant="ghost" size="icon" aria-label="View Profile"><Eye className="w-4 h-4" /></Button>
                          {rider.status !== 'suspended' && rider.status !== 'deactivated' && (
                            <Button
                              variant="ghost"
                              size="icon"
                              className="text-danger"
                              aria-label="Suspend rider"
                              disabled={!canWrite}
                              title={writeDisabledTitle}
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
              <PaginationFooter
                meta={riderMeta}
                page={riderPage}
                onPageChange={setRiderPage}
                label="riders"
                className="flex items-center justify-between px-4 md:px-6 py-3 border-t border-border text-sm text-text-muted"
              />
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
                        <Badge variant={statusVariant(driver.status ?? 'active')}>
                          {statusLabel(driver.status ?? 'active')}
                        </Badge>
                      </TableCell>
                      <TableCell className="text-right">
                        <div className="flex justify-end gap-2">
                          <Button variant="ghost" size="icon" aria-label="Review Documents"><CheckCircle className="w-4 h-4 text-success" /></Button>
                          <Button variant="ghost" size="icon" aria-label="View Profile"><Eye className="w-4 h-4" /></Button>
                          {driver.status !== 'suspended' && driver.status !== 'deactivated' && (
                            <Button
                              variant="ghost"
                              size="icon"
                              className="text-danger"
                              aria-label="Suspend driver"
                              disabled={!canWrite}
                              title={writeDisabledTitle}
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
              <PaginationFooter
                meta={driverMeta}
                page={driverPage}
                onPageChange={setDriverPage}
                label="drivers"
                className="flex items-center justify-between px-4 md:px-6 py-3 border-t border-border text-sm text-text-muted"
              />
            </TabsContent>
          </Tabs>
        </CardContent>
      </Card>
    </div>
  );
}


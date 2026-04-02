import React, { useState } from 'react';
import { Card, CardContent } from '@/components/ui/Card';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/Table';
import { Badge } from '@/components/ui/Badge';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/Tabs';
import { Search, Eye, Ban, CheckCircle, AlertTriangle } from 'lucide-react';

const riders = [
  { id: 'R-1001', name: 'Maria Santos', phone: '+63 917 123 4567', email: 'maria@example.com', status: 'Active', date: '2023-10-12', rating: 4.8 },
  { id: 'R-1002', name: 'Jose Rizal', phone: '+63 918 987 6543', email: 'jose@example.com', status: 'Active', date: '2023-11-05', rating: 4.9 },
  { id: 'R-1003', name: 'Andres Bonifacio', phone: '+63 919 456 7890', email: 'andres@example.com', status: 'Suspended', date: '2024-01-20', rating: 3.2 },
];

const drivers = [
  { id: 'D-2001', name: 'Juan Dela Cruz', phone: '+63 920 111 2222', email: 'juan@example.com', vehicle: 'Motorcycle', status: 'Active', kyc: 'Verified', rating: 4.7 },
  { id: 'D-2002', name: 'Pedro Penduko', phone: '+63 921 333 4444', email: 'pedro@example.com', vehicle: 'Tricycle', status: 'Pending', kyc: 'Pending', rating: 0 },
  { id: 'D-2003', name: 'Cardo Dalisay', phone: '+63 922 555 6666', email: 'cardo@example.com', vehicle: 'Car (4-seater)', status: 'Suspended', kyc: 'Rejected', rating: 4.1 },
];

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
  const [riderList, setRiderList] = useState(riders);
  const [driverList, setDriverList] = useState(drivers);
  const [confirm, setConfirm] = useState<ConfirmDialog>({ open: false, title: '', message: '', onConfirm: () => {} });

  const closeConfirm = () => setConfirm(prev => ({ ...prev, open: false }));

  const suspendRider = (id: string, name: string) => {
    setConfirm({
      open: true,
      title: 'Suspend Rider',
      message: `Are you sure you want to suspend ${name}? They will no longer be able to book rides.`,
      onConfirm: () => setRiderList(prev => prev.map(r => r.id === id ? { ...r, status: 'Suspended' } : r)),
    });
  };

  const suspendDriver = (id: string, name: string) => {
    setConfirm({
      open: true,
      title: 'Suspend Driver',
      message: `Are you sure you want to suspend ${name}? They will no longer be able to accept rides.`,
      onConfirm: () => setDriverList(prev => prev.map(d => d.id === id ? { ...d, status: 'Suspended' } : d)),
    });
  };

  const q = search.toLowerCase();

  const filteredRiders = riderList.filter(r =>
    !q || r.name.toLowerCase().includes(q) || r.id.toLowerCase().includes(q) || r.phone.includes(q)
  );

  const filteredDrivers = driverList.filter(d =>
    !q || d.name.toLowerCase().includes(q) || d.id.toLowerCase().includes(q) || d.vehicle.toLowerCase().includes(q)
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
                    <TableHead>Rating</TableHead>
                    <TableHead className="text-right">Actions</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {filteredRiders.length === 0 ? (
                    <TableRow>
                      <TableCell colSpan={6} className="text-center py-10 text-text-muted">
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
                          <p className="text-sm">{rider.phone}</p>
                          <p className="text-xs text-text-muted">{rider.email}</p>
                        </div>
                      </TableCell>
                      <TableCell>
                        <Badge variant={rider.status === 'Active' ? 'success' : 'danger'}>
                          {rider.status}
                        </Badge>
                      </TableCell>
                      <TableCell>{rider.date}</TableCell>
                      <TableCell>⭐ {rider.rating}</TableCell>
                      <TableCell className="text-right">
                        <div className="flex justify-end gap-2">
                          <Button variant="ghost" size="icon" aria-label="View Profile"><Eye className="w-4 h-4" /></Button>
                          {rider.status !== 'Suspended' && (
                            <Button
                              variant="ghost"
                              size="icon"
                              className="text-danger"
                              aria-label="Suspend rider"
                              onClick={() => suspendRider(rider.id, rider.name)}
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
                    <TableHead>KYC Status</TableHead>
                    <TableHead>Rating</TableHead>
                    <TableHead className="text-right">Actions</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {filteredDrivers.length === 0 ? (
                    <TableRow>
                      <TableCell colSpan={6} className="text-center py-10 text-text-muted">
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
                          <p className="text-sm">{driver.phone}</p>
                          <p className="text-xs text-text-muted">{driver.email}</p>
                        </div>
                      </TableCell>
                      <TableCell>{driver.vehicle}</TableCell>
                      <TableCell>
                        <Badge variant={
                          driver.kyc === 'Verified' ? 'success' :
                          driver.kyc === 'Pending' ? 'warning' : 'danger'
                        }>
                          {driver.kyc}
                        </Badge>
                      </TableCell>
                      <TableCell>{driver.rating > 0 ? `⭐ ${driver.rating}` : '—'}</TableCell>
                      <TableCell className="text-right">
                        <div className="flex justify-end gap-2">
                          <Button variant="ghost" size="icon" aria-label="Review Documents"><CheckCircle className="w-4 h-4 text-success" /></Button>
                          <Button variant="ghost" size="icon" aria-label="View Profile"><Eye className="w-4 h-4" /></Button>
                          {driver.status !== 'Suspended' && (
                            <Button
                              variant="ghost"
                              size="icon"
                              className="text-danger"
                              aria-label="Suspend driver"
                              onClick={() => suspendDriver(driver.id, driver.name)}
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
